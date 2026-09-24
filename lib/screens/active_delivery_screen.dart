import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:async';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart' show Geolocator;
import '../models/delivery_request.dart';
import '../widgets/cancel_dialog.dart';
import '../widgets/report_problem_dialog.dart';
import '../widgets/locate_me_button.dart';
import '../services/route_service.dart';
import '../services/sound_service.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';

class ActiveDeliveryScreen extends StatefulWidget {
  final DeliveryRequest request;
  const ActiveDeliveryScreen({super.key, required this.request});

  @override
  State<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends State<ActiveDeliveryScreen> {
  bool _isUpdating = false;
  MapboxMap? _mapboxMap;

  // Matches startWaitingFee.js's GRACE_PERIOD_MS — the server is what
  // actually enforces this, this just decides when to show the countdown
  // and, once it's run out, the "charge waiting fee" button.
  static const _waitingFeeGracePeriod = Duration(minutes: 5);
  Timer? _waitingFeeTicker;

  // Set once, the first time hasArrived is observed true — deliberately
  // this device's own clock, not the server's arrivedAt timestamp compared
  // against DateTime.now() (a real phone can be meaningfully out of sync
  // with the machine running the emulator/backend — the same clock-skew
  // bug already found and fixed for the customer's countdown).
  DateTime? _arrivedAtLocalRef;

  @override
  void initState() {
    super.initState();
    // Nothing in Firestore changes just because time passes — without this,
    // the "charge waiting fee" button wouldn't appear until some unrelated
    // update (a GPS ping) happened to rebuild this screen after the
    // 5-minute mark. 1s (not 15s) so the M:SS display actually counts down
    // smoothly instead of jumping in 15-second steps.
    _waitingFeeTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _waitingFeeTicker?.cancel();
    super.dispose();
  }

  Future<void> _markPickedUp() async {
    setState(() => _isUpdating = true);
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('markPickedUp');
      await callable.call({'requestId': widget.request.id});
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? AppLocalizations.of(context)!.couldNotMarkPickedUpError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _markArrived() async {
    setState(() => _isUpdating = true);
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('markArrived');
      await callable.call({'requestId': widget.request.id});
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? AppLocalizations.of(context)!.couldNotMarkArrivedError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  String _formatMinSec(Duration d) {
    final clamped = d.isNegative ? Duration.zero : d;
    final minutes = clamped.inMinutes;
    final seconds = clamped.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _startWaitingFee() async {
    setState(() => _isUpdating = true);
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('startWaitingFee');
      await callable.call({'requestId': widget.request.id});
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? AppLocalizations.of(context)!.couldNotStartWaitingFeeError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<String?> _promptForConfirmationCode() {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.enterDeliveryCodeTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.deliveryCodeInstruction),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              autofocus: true,
              decoration: InputDecoration(hintText: l10n.deliveryCodeHint),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancelButton)),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.confirmButton),
          ),
        ],
      ),
    );
  }

  Future<void> _markDelivered() async {
    final code = await _promptForConfirmationCode();
    if (code == null || code.isEmpty) return;

    setState(() => _isUpdating = true);
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('completeDelivery');
      // Default to cash/Bankak settlement — the customer settles outside the
      // app and an admin verifies it later. Swap to 'wallet' once wallet
      // top-ups are wired into the customer app.
      await callable.call({
        'requestId': widget.request.id,
        'paymentMethod': 'cash',
        'confirmationCode': code,
      });
      SoundService.rideCompleted();
      // Nothing to navigate here — home_screen.dart's _watchForUnratedDelivery
      // reactively pushes RateCustomerScreen once the resulting Firestore
      // update (status: delivered, ratedByRider: false) arrives, which also
      // covers the case where that update reaches the client before this
      // callable's own HTTP response does (routinely the case on real
      // devices — the two travel over separate channels and the Firestore
      // write happens before the function returns).
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? AppLocalizations.of(context)!.couldNotCompleteDeliveryError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _openNavigation(double lat, double lng) async {
    // Deep-links to Google Maps' turn-by-turn navigation — no in-app SDK
    // needed, no extra cost. Falls back gracefully if Google Maps isn't
    // installed (rare on Android, but handled rather than assumed).
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenMapsError)),
      );
    }
  }

  Future<void> _cancelDelivery() async {
    final l10n = AppLocalizations.of(context)!;
    final reason = await showCancelReasonDialog(
      context,
      title: l10n.cancelDeliveryDialogTitle,
      reasons: [
        l10n.reasonVehicleIssue,
        l10n.reasonPersonalEmergency,
        l10n.reasonCustomerUnreachable,
        l10n.reasonDistanceTooFar,
        l10n.reasonOther,
      ],
    );
    if (reason == null) return;

    setState(() => _isUpdating = true);
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('cancelRequest');
      await callable.call({'requestId': widget.request.id, 'reason': reason});
      SoundService.cancellation();
      // No explicit navigation needed here — once status flips to
      // "cancelled", the home screen's live query stops matching this
      // request and automatically swaps back to the open-requests feed.
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? l10n.cancelDeliveryError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPickedUp = widget.request.status == RequestStatus.pickedUp;
    final destination = isPickedUp ? widget.request.dropoff : widget.request.pickup;
    final destinationLabel = isPickedUp ? l10n.dropoffLabel : l10n.pickupLabel;
    final destinationAddress = isPickedUp ? widget.request.dropoffAddress : widget.request.pickupAddress;
    final etaMinutes = isPickedUp ? widget.request.etaToDropoffMinutes : widget.request.etaToPickupMinutes;
    // Prefer the specific pickup/receiver contact (may be a different
    // person, e.g. someone else collecting the package) but fall back to
    // the customer's own number so there's always a way to reach them —
    // that field is optional and often left blank.
    final contactPhone = (isPickedUp ? widget.request.receiverContactPhone : widget.request.pickupContactPhone) ??
        widget.request.customerPhone;

    // Rising edge only — anchors the countdown to this device's clock the
    // first time arrival is observed, not on every rebuild (this screen
    // rebuilds often, e.g. on every GPS ping).
    if (widget.request.hasArrived && _arrivedAtLocalRef == null) {
      _arrivedAtLocalRef = DateTime.now();
    } else if (!widget.request.hasArrived) {
      _arrivedAtLocalRef = null;
    }
    final waitingElapsed = _arrivedAtLocalRef != null ? DateTime.now().difference(_arrivedAtLocalRef!) : Duration.zero;
    final waitingRemaining = _waitingFeeGracePeriod - waitingElapsed;

    const mapHeight = 340.0;
    return Scaffold(
      // Every Stack child below is explicitly Positioned — an un-Positioned
      // child instead sizes the whole Stack to itself (see the same fix in
      // create_request_screen.dart and location_picker_screen.dart), which
      // would squash the overlapping bottom sheet to a sliver.
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
              // Keying by destinationLabel means the map only recreates the ONE
              // time the rider transitions from heading-to-pickup to
              // heading-to-dropoff — an intentional, one-off change, not the
              // per-tap thrashing we hit (and fixed) on the create-request screen.
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('riders')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, riderSnap) {
                final riderData = riderSnap.data?.data() as Map<String, dynamic>?;
                final myLocation = riderData?['currentLocation'] as GeoPoint?;
                final vehicleType = riderData?['vehicleType'] as String?;
                  return _ActiveDeliveryMap(
                    key: ValueKey('activeDeliveryMap-$destinationLabel'),
                    destination: destination,
                    destinationColor: isPickedUp ? AppColors.primary : AppColors.accent,
                    myLocation: myLocation,
                    vehicleType: vehicleType,
                    onMapReady: (map) => _mapboxMap = map,
                  );
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
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration:
                                  BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l10n.headingToWord,
                                    style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                                  ),
                                  Text(
                                    destinationAddress,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (etaMinutes != null) ...[
                        const SizedBox(width: 8),
                        Text(l10n.etaApproxMinutes(etaMinutes), style: AppTypography.amount(size: 14, color: Colors.white)),
                      ],
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _isUpdating
                            ? null
                            : isPickedUp
                                ? () => showReportProblemDialog(
                                      context,
                                      requestId: widget.request.id,
                                      reporterRole: 'rider',
                                      reasons: [
                                        l10n.reasonCustomerUnreachable,
                                        l10n.reasonWrongAddress,
                                        l10n.reasonCustomerRefusedDelivery,
                                        l10n.reasonSafetyConcern,
                                        l10n.reasonOther,
                                      ],
                                    )
                                : _cancelDelivery,
                        child: Icon(
                          isPickedUp ? Icons.flag_outlined : Icons.close,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            // Anchored just below the map (with a slight overlap for the
            // rounded top corners), not just bottom:0 — without a top
            // constraint this sheet only sizes to its own content and
            // floats at the bottom, leaving a large empty gap between it
            // and the map above. Same convention as bid_submit_screen.dart.
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
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              child: SingleChildScrollView(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 23,
                        backgroundColor: AppColors.primaryTint,
                        backgroundImage: widget.request.customerPhotoUrl != null
                            ? NetworkImage(widget.request.customerPhotoUrl!)
                            : null,
                        child: widget.request.customerPhotoUrl == null
                            ? const Icon(Icons.person_outline, color: AppColors.primary)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.request.customerName ?? l10n.customerFallbackName,
                              style: AppTypography.heading(size: 14.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (contactPhone != null)
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  contactPhone,
                                  style: AppTypography.caption(size: 12, color: AppColors.mutedLight),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (contactPhone != null)
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFEAF6F0),
                              shape: const CircleBorder(),
                            ),
                            onPressed: () async => launchUrl(Uri.parse('tel:$contactPhone')),
                            icon: const Icon(Icons.call, size: 18, color: AppColors.success),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.packageLabel(widget.request.packageDescription), style: AppTypography.body(size: 13.5)),
                        if (widget.request.agreedPrice != null) ...[
                          const SizedBox(height: 10),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          Text(
                            l10n.amountToCollectLabel(widget.request.agreedPrice!.toStringAsFixed(0)),
                            style: AppTypography.amount(size: 19, color: AppColors.success),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _openNavigation(destination.latitude, destination.longitude),
                    icon: const Icon(Icons.navigation_outlined),
                    label: Text(l10n.navigateWithGoogleMapsButton),
                  ),
                  const SizedBox(height: 10),
                  // One button that steps through the three phases in order
                  // (arrived -> picked up -> delivered) rather than a
                  // separate "I've Arrived" button sitting alongside the
                  // main action — each tap advances to the next step.
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                    onPressed: _isUpdating
                        ? null
                        : (isPickedUp
                            ? _markDelivered
                            : (widget.request.hasArrived ? _markPickedUp : _markArrived)),
                    child: _isUpdating
                        ? const SizedBox(
                            width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(isPickedUp
                            ? l10n.markDeliveredButton
                            : (widget.request.hasArrived ? l10n.markPickedUpButton : l10n.markArrivedButton)),
                  ),
                  // Once 5 minutes have passed since arriving with the
                  // customer still a no-show, offer the waiting fee — the
                  // rider's cancel action above (with its existing "Customer
                  // Unreachable" reason) already covers the other half of
                  // "cancel or charge extra", so nothing new is needed there.
                  // Before that, show the same countdown the customer sees,
                  // so the rider knows how much longer they're waiting for.
                  if (!isPickedUp && widget.request.hasArrived) ...[
                    const SizedBox(height: 10),
                    if (widget.request.arrivalAcknowledgedAt != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(color: AppColors.successTintAlt, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.directions_walk, size: 16, color: AppColors.successText),
                              const SizedBox(width: 6),
                              Text(l10n.customerIsComingLabel, style: AppTypography.caption(color: AppColors.successText)),
                            ],
                          ),
                        ),
                      ),
                    if (widget.request.waitingFeeStartedAt != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: AppColors.accentTint, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.timer_outlined, size: 16, color: AppColors.accentInk),
                            const SizedBox(width: 6),
                            Text(l10n.waitingFeeActiveLabel, style: AppTypography.caption(color: AppColors.accentInk)),
                          ],
                        ),
                      )
                    else if (waitingRemaining > Duration.zero)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          l10n.waitingGracePeriodLabel(_formatMinSec(waitingRemaining)),
                          textAlign: TextAlign.center,
                          style: AppTypography.caption(color: AppColors.muted),
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: _isUpdating ? null : _startWaitingFee,
                        icon: const Icon(Icons.timer_outlined, size: 18),
                        label: Text(l10n.startWaitingFeeButton),
                      ),
                  ],
                ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The rider's own live position (a native Mapbox location puck, not a
/// manual circle) plus a real road-following route to the pickup/dropoff —
/// mirrors customer_app/tracking_screen.dart's _RiderLocationMap, duplicated
/// rather than shared since no package is shared between the two apps.
class _ActiveDeliveryMap extends StatefulWidget {
  final GeoPoint destination;
  final Color destinationColor;
  final GeoPoint? myLocation;
  final String? vehicleType;
  final ValueChanged<MapboxMap> onMapReady;
  const _ActiveDeliveryMap({
    super.key,
    required this.destination,
    required this.destinationColor,
    required this.onMapReady,
    this.myLocation,
    this.vehicleType,
  });

  @override
  State<_ActiveDeliveryMap> createState() => _ActiveDeliveryMapState();
}

class _ActiveDeliveryMapState extends State<_ActiveDeliveryMap> {
  PolylineAnnotationManager? _polylineAnnotationManager;
  PolylineAnnotation? _routeLine;

  // Same throttle reasoning as tracking_screen.dart's _RiderLocationMap —
  // the puck itself updates continuously via Mapbox's own location engine;
  // only the road-following line redraws at this cadence.
  Position? _lastRouteFetchOrigin;
  DateTime? _lastRouteFetchAt;
  static const _routeRefetchMinInterval = Duration(seconds: 20);
  static const _routeRefetchMinMeters = 60.0;

  Future<void> _drawLine(List<Position> coordinates) async {
    final lineManager = _polylineAnnotationManager;
    if (lineManager == null) return;
    if (_routeLine != null) {
      _routeLine!.geometry = LineString(coordinates: coordinates);
      await lineManager.update(_routeLine!);
    } else {
      _routeLine = await lineManager.create(
        PolylineAnnotationOptions(
          geometry: LineString(coordinates: coordinates),
          lineColor: AppColors.primary.toARGB32(),
          lineWidth: 3.0,
        ),
      );
    }
  }

  Future<void> _fetchAndDrawRoute(Position origin) async {
    if (_polylineAnnotationManager == null) return;
    _lastRouteFetchOrigin = origin;
    _lastRouteFetchAt = DateTime.now();
    final destPosition = Position(widget.destination.longitude, widget.destination.latitude);

    // A straight line first, drawn immediately with no network round trip —
    // see tracking_screen.dart's identical fix for why (a Directions fetch
    // that's slow or fails otherwise leaves the map blank, not "loading").
    await _drawLine([origin, destPosition]);

    final route = await fetchRoute(origin, destPosition, profile: profileForVehicleType(widget.vehicleType));
    if (!mounted || _polylineAnnotationManager == null || route == null) return;
    await _drawLine(route.coordinates);
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    widget.onMapReady(mapboxMap);
    unawaited(mapboxMap.compass.updateSettings(CompassSettings(enabled: false)));
    unawaited(mapboxMap.location.updateSettings(
      LocationComponentSettings(enabled: true, pulsingEnabled: true),
    ));

    final circleManager = await mapboxMap.annotations.createCircleAnnotationManager();
    await circleManager.create(
      CircleAnnotationOptions(
        geometry: Point(coordinates: Position(widget.destination.longitude, widget.destination.latitude)),
        circleColor: widget.destinationColor.toARGB32(),
        circleRadius: 9.0,
        circleStrokeColor: Colors.white.toARGB32(),
        circleStrokeWidth: 2.0,
      ),
    );

    _polylineAnnotationManager = await mapboxMap.annotations.createPolylineAnnotationManager();
    final myLocation = widget.myLocation;
    if (myLocation != null) {
      unawaited(_fetchAndDrawRoute(Position(myLocation.longitude, myLocation.latitude)));
    }
  }

  @override
  void didUpdateWidget(covariant _ActiveDeliveryMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final myLocation = widget.myLocation;
    if (myLocation == null) return;
    final newPosition = Position(myLocation.longitude, myLocation.latitude);

    final lastOrigin = _lastRouteFetchOrigin;
    final lastFetchAt = _lastRouteFetchAt;
    final movedMeters = lastOrigin == null
        ? double.infinity
        : Geolocator.distanceBetween(lastOrigin.lat.toDouble(), lastOrigin.lng.toDouble(), newPosition.lat.toDouble(), newPosition.lng.toDouble());
    final elapsed = lastFetchAt == null ? null : DateTime.now().difference(lastFetchAt);
    if (movedMeters > _routeRefetchMinMeters || elapsed == null || elapsed > _routeRefetchMinInterval) {
      unawaited(_fetchAndDrawRoute(newPosition));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      cameraOptions: CameraOptions(
        center: Point(coordinates: Position(widget.destination.longitude, widget.destination.latitude)),
        zoom: 15.0,
      ),
      styleUri: MapboxStyles.MAPBOX_STREETS,
      onMapCreated: _onMapCreated,
    );
  }
}
