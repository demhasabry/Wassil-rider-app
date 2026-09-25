import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../models/delivery_request.dart';
import '../services/route_service.dart';
import '../services/callable_function.dart';
import '../widgets/locate_me_button.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';

class BidSubmitScreen extends StatefulWidget {
  final DeliveryRequest request;
  const BidSubmitScreen({super.key, required this.request});

  @override
  State<BidSubmitScreen> createState() => _BidSubmitScreenState();
}

class _BidSubmitScreenState extends State<BidSubmitScreen> {
  static const _step = 100.0;

  final _priceController = TextEditingController();
  final _priceFocusNode = FocusNode();
  bool _isSubmitting = false;
  String? _errorText;
  double _price = 0;
  MapboxMap? _mapboxMap;
  String? _myVehicleType;

  double get _minPrice => _step;
  double get _maxPrice {
    final base = widget.request.suggestedPrice;
    return base != null ? base * 3 : double.infinity;
  }

  @override
  void initState() {
    super.initState();
    // Seed the stepper at the base price (or one step above zero if there
    // isn't one) rather than starting empty — a rider almost always bids
    // somewhere near the suggested price, not from a blank field.
    _price = widget.request.suggestedPrice ?? _step;
    _syncController();
    FirebaseFirestore.instance
        .collection('riders')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((doc) => _myVehicleType = doc.data()?['vehicleType'] as String?);
    // Typing a price directly (rather than only stepping it in $100
    // increments) applies once the field loses focus — lets a rider punch
    // in an exact number while still going through the same clamping
    // _setPrice already applies to the +/- buttons.
    _priceFocusNode.addListener(() {
      if (!_priceFocusNode.hasFocus) _applyTypedPrice();
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }

  void _applyTypedPrice() {
    final parsed = double.tryParse(_priceController.text.trim());
    if (parsed != null) {
      _setPrice(parsed);
    } else {
      _syncController();
    }
  }

  void _syncController() {
    _priceController.text = _price.toStringAsFixed(0);
  }

  void _setPrice(double value) {
    var result = value < _minPrice ? _minPrice : value;
    if (_maxPrice.isFinite && result > _maxPrice) result = _maxPrice;
    setState(() {
      _price = result;
      _syncController();
    });
  }

  Future<void> _submitBid() async {
    final l10n = AppLocalizations.of(context)!;
    final price = double.tryParse(_priceController.text.trim());

    if (price == null || price <= 0) {
      setState(() => _errorText = l10n.enterValidPriceError);
      return;
    }

    final basePrice = widget.request.suggestedPrice;
    if (basePrice != null && price > basePrice * 3) {
      // Client-side check for immediate feedback — the server enforces this
      // regardless, so this can't be bypassed even if skipped here.
      setState(() => _errorText = l10n.maxAllowedBidError((basePrice * 3).toStringAsFixed(0)));
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await callFunction('submitBid', {
        'requestId': widget.request.id,
        'price': price,
      });

      if (!mounted) return;
      // The 30s "this offer is active" window is now purely a customer-side
      // concept (the draining-glass countdown on their bid card in
      // bid_list_screen.dart) — the rider isn't shown any cooldown UI for
      // it, so there's nothing left to stay on this screen for. If they try
      // to bid again before it clears, submitBid.js's own check rejects it
      // and _errorText below shows that like any other submit error.
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.bidSubmittedMessage)),
      );
    } on FirebaseFunctionsException catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorText = e.message ?? l10n.couldNotSubmitBidError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final basePrice = widget.request.suggestedPrice;
    // Three sensible quick-amounts tied to this request's actual base price
    // (not the design handoff's example numbers, which were specific to its
    // prototype data) — base price itself, and two steps above it.
    final quickAmounts = basePrice != null
        ? [basePrice, (basePrice * 1.3 / _step).round() * _step, (basePrice * 1.6 / _step).round() * _step]
        : <double>[];

    const mapHeight = 240.0;
    final midLat = (widget.request.pickup.latitude + widget.request.dropoff.latitude) / 2;
    final midLng = (widget.request.pickup.longitude + widget.request.dropoff.longitude) / 2;

    return Scaffold(
      // Every Stack child below is explicitly Positioned — see the same fix
      // in create_request_screen.dart / location_picker_screen.dart / active
      // _delivery_screen.dart for why an un-Positioned child would squash
      // the overlapping sheet to a sliver.
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: mapHeight,
            // bottom:false SafeArea — the map is an interactive Mapbox view,
            // and starting it right at the very top of the screen let its
            // own pan/zoom gesture recognizer swallow the system's
            // swipe-down-for-notifications gesture in that strip.
            child: SafeArea(
              bottom: false,
              child: MapWidget(
              key: ValueKey('bidSubmitMap-${widget.request.id}'),
              cameraOptions: CameraOptions(center: Point(coordinates: Position(midLng, midLat)), zoom: 12.5),
              styleUri: MapboxStyles.MAPBOX_STREETS,
              onMapCreated: (mapboxMap) async {
                _mapboxMap = mapboxMap;
                unawaited(mapboxMap.location.updateSettings(
                  LocationComponentSettings(enabled: true, pulsingEnabled: true),
                ));
                final pickup = Position(widget.request.pickup.longitude, widget.request.pickup.latitude);
                final dropoff = Position(widget.request.dropoff.longitude, widget.request.dropoff.latitude);
                final lineManager = await mapboxMap.annotations.createPolylineAnnotationManager();
                // Real road-following path, not a straight line cutting
                // through buildings — same fix already applied to the
                // customer app's equivalent preview map. Falls back to the
                // straight line only if the Directions call fails.
                final route = await fetchRoute(pickup, dropoff, profile: profileForVehicleType(_myVehicleType));
                await lineManager.create(PolylineAnnotationOptions(
                  geometry: LineString(coordinates: route?.coordinates ?? [pickup, dropoff]),
                  lineColor: AppColors.primary.toARGB32(),
                  lineWidth: 3.0,
                ));
                final manager = await mapboxMap.annotations.createCircleAnnotationManager();
                await manager.create(CircleAnnotationOptions(
                  geometry: Point(coordinates: pickup),
                  circleColor: AppColors.accent.toARGB32(),
                  circleRadius: 8.0,
                  circleStrokeColor: Colors.white.toARGB32(),
                  circleStrokeWidth: 2.0,
                ));
                await manager.create(CircleAnnotationOptions(
                  geometry: Point(coordinates: dropoff),
                  circleColor: AppColors.primary.toARGB32(),
                  circleRadius: 8.0,
                  circleStrokeColor: Colors.white.toARGB32(),
                  circleStrokeWidth: 2.0,
                ));
              },
              ),
            ),
          ),
          Positioned(
            top: mapHeight - 66,
            right: 12,
            child: LocateMeButton(mapboxMap: () => _mapboxMap),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: InkWell(
                  onTap: () => Navigator.maybePop(context),
                  borderRadius: BorderRadius.circular(21),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, boxShadow: AppShadows.mapFloat),
                    child: Icon(
                      Directionality.of(context) == TextDirection.rtl ? Icons.arrow_forward : Icons.arrow_back,
                      size: 20,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: mapHeight - 18,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.bottomSheetRadius,
                boxShadow: AppShadows.bottomSheet,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                      children: [
                        Text(l10n.placeYourBidTitle, style: AppTypography.title(size: 21)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(borderRadius: AppRadii.cardRadius, border: Border.all(color: AppColors.borderAlt)),
                          child: Column(
                            children: [
                              _addressRow(
                                indicator: Container(
                                  width: 11,
                                  height: 11,
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accent),
                                ),
                                text: widget.request.pickupAddress,
                              ),
                              const Padding(
                                padding: EdgeInsetsDirectional.only(start: 27),
                                child: Divider(height: 1, color: AppColors.borderAlt),
                              ),
                              _addressRow(
                                indicator: Container(
                                  width: 11,
                                  height: 11,
                                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
                                ),
                                text: widget.request.dropoffAddress,
                              ),
                            ],
                          ),
                        ),
                        if (widget.request.estimatedWeightKg != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.accentTint,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.accentBorder),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.scale_outlined, size: 15, color: AppColors.accent),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n.estimatedWeightLabel(widget.request.estimatedWeightKg!.toStringAsFixed(0)),
                                    style: AppTypography.label(size: 13, color: AppColors.accent)
                                        .copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (widget.request.purchaseBudget != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              l10n.purchaseBudgetWarning(widget.request.purchaseBudget!.toStringAsFixed(0)),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger),
                            ),
                          ),
                        const SizedBox(height: 16),
                        if (basePrice != null)
                          Row(
                            children: [
                              Expanded(child: _StatTile(label: l10n.basePriceLabel(basePrice.toStringAsFixed(0)))),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _StatTile(
                                  label: l10n.maxBidAllowedLabel((basePrice * 3).toStringAsFixed(0)),
                                  valueColor: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 20),
                        Text(l10n.yourPriceLabel, style: AppTypography.label(color: AppColors.muted)),
                          const SizedBox(height: 10),
                          _PriceStepper(
                            controller: _priceController,
                            focusNode: _priceFocusNode,
                            onSubmitted: _applyTypedPrice,
                            onDecrement: () => _setPrice(_price - _step),
                            onIncrement: () => _setPrice(_price + _step),
                          ),
                          if (quickAmounts.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                for (final amount in quickAmounts) ...[
                                  if (amount != quickAmounts.first) const SizedBox(width: 8),
                                  Expanded(
                                    child: _price == amount
                                        ? ElevatedButton(
                                            onPressed: () => _setPrice(amount),
                                            child: Text(amount.toStringAsFixed(0)),
                                          )
                                        : OutlinedButton(
                                            onPressed: () => _setPrice(amount),
                                            child: Text(amount.toStringAsFixed(0)),
                                          ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.accentTint,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                l10n.etaAutoCalculatedNote,
                                style: AppTypography.caption(color: AppColors.accentInk),
                              ),
                            ),
                          ),
                          if (_errorText != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(_errorText!, style: const TextStyle(color: AppColors.danger)),
                            ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitBid,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text(l10n.submitBidButton),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressRow({required Widget indicator, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          indicator,
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTypography.body(size: 14, color: AppColors.ink))),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final Color? valueColor;
  const _StatTile({required this.label, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: AppTypography.body(size: 13, color: valueColor ?? AppColors.ink)),
    );
  }
}

/// The design handoff's price stepper: -/+ buttons around a centred mono
/// value, step 100, clamped by the caller (base price..base price*3 — the
/// same server-enforced range as before, not the handoff's example numbers).
/// The value itself is also a live text field now — a rider punching in an
/// exact number shouldn't have to tap +/- dozens of times to get there.
class _PriceStepper extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmitted;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  const _PriceStepper({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryFocusBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StepperButton(icon: Icons.remove, onPressed: onDecrement),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textAlign: TextAlign.center,
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                style: AppTypography.amount(size: 27, color: AppColors.ink),
                decoration: const InputDecoration(border: InputBorder.none, isDense: true, isCollapsed: true),
                onSubmitted: (_) => onSubmitted(),
              ),
            ),
          ),
          _StepperButton(icon: Icons.add, onPressed: onIncrement),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _StepperButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color.fromRGBO(16, 21, 32, 0.1), offset: Offset(0, 1), blurRadius: 3)],
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.primary),
        ),
      ),
    );
  }
}
