import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class RateCustomerScreen extends StatefulWidget {
  final String requestId;
  final double? collectedAmount;
  const RateCustomerScreen({super.key, required this.requestId, this.collectedAmount});

  @override
  State<RateCustomerScreen> createState() => _RateCustomerScreenState();
}

class _RateCustomerScreenState extends State<RateCustomerScreen> {
  int _selectedStars = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorText;
  double? _commissionCharged;

  @override
  void initState() {
    super.initState();
    _loadCommission();
  }

  // completeDelivery.js already wrote commissionCharged onto the request doc
  // (order_history_screen.dart reads the same field) — a plain read here, no
  // need to change the Cloud Function's return contract for this.
  Future<void> _loadCommission() async {
    final doc = await FirebaseFirestore.instance.collection('delivery_requests').doc(widget.requestId).get();
    if (!mounted) return;
    setState(() => _commissionCharged = (doc.data()?['commissionCharged'] as num?)?.toDouble());
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedStars == 0) {
      setState(() => _errorText = l10n.tapStarToRateCustomerError);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      final callable = FirebaseFunctions.instance.httpsCallable('submitCustomerRating');
      await callable.call({
        'requestId': widget.requestId,
        'stars': _selectedStars,
        'comment': _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context);
    } on FirebaseFunctionsException catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorText = e.message ?? l10n.submitRatingError;
      });
    }
  }

  // Marks the delivery as handled (no rating) via a Cloud Function — clients
  // can never write delivery_requests directly (firestore.rules), and
  // without this, ratedByRider stays false forever and
  // home_screen.dart's _watchForUnratedDelivery re-prompts this exact same
  // screen for this exact same old delivery on every future login.
  Future<void> _skip() async {
    if (!mounted) return;
    Navigator.pop(context);
    try {
      await FirebaseFunctions.instance.httpsCallable('skipCustomerRating').call({'requestId': widget.requestId});
    } catch (_) {
      // Already popped — a failure here just means the next login prompts
      // again, which is the pre-existing (if annoying) behavior, not a new
      // failure mode worth surfacing to the rider after they've moved on.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final collected = widget.collectedAmount;
    final commission = _commissionCharged;
    final net = (collected != null && commission != null) ? collected - commission : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.deliveryCompleteTitle),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: const BoxDecoration(color: AppColors.successTint, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: AppColors.success, size: 32),
            ),
            const SizedBox(height: 16),
            Text(l10n.deliveryCompleteTitle, style: AppTypography.title(size: 22)),
            if (collected != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  border: Border.all(color: AppColors.borderAlt),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.collectedWord, style: AppTypography.body(size: 13, color: AppColors.muted)),
                        Text(collected.toStringAsFixed(0), style: AppTypography.amount(size: 17, color: AppColors.ink)),
                      ],
                    ),
                    if (commission != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.transactionCommissionLabel, style: AppTypography.body(size: 13, color: AppColors.muted)),
                          Text('−${commission.toStringAsFixed(0)}', style: AppTypography.amount(size: 14, color: AppColors.danger)),
                        ],
                      ),
                      const SizedBox(height: 11),
                      const Divider(height: 1),
                      const SizedBox(height: 11),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.netWord, style: AppTypography.body(size: 13, color: AppColors.ink).copyWith(fontWeight: FontWeight.w500)),
                          Text(net!.toStringAsFixed(0), style: AppTypography.amount(size: 19, color: AppColors.success)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),
            Text(l10n.howWasCustomerTitle, style: AppTypography.heading()),
            const SizedBox(height: 16),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starNumber = index + 1;
                  final filled = starNumber <= _selectedStars;
                  return IconButton(
                    iconSize: 40,
                    icon: Icon(
                      filled ? Icons.star : Icons.star_border,
                      color: filled ? AppColors.accent : AppColors.starInactive,
                    ),
                    style: filled
                        ? IconButton.styleFrom(backgroundColor: AppColors.accentTintAlt, shape: const CircleBorder())
                        : null,
                    onPressed: _isSubmitting ? null : () => setState(() => _selectedStars = starNumber),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 2,
              decoration: InputDecoration(hintText: l10n.optionalCommentAboutCustomerHint),
            ),
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_errorText!, style: const TextStyle(color: AppColors.danger)),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(l10n.submitRatingButton),
              ),
            ),
            TextButton(onPressed: _isSubmitting ? null : _skip, child: Text(l10n.skipButton)),
          ],
        ),
      ),
    );
  }
}
