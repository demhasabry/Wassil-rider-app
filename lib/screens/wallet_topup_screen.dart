import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radii.dart';
import 'wallet_screen.dart';

class WalletTopupScreen extends StatefulWidget {
  const WalletTopupScreen({super.key});

  @override
  State<WalletTopupScreen> createState() => _WalletTopupScreenState();
}

class _WalletTopupScreenState extends State<WalletTopupScreen> {
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorText;

  // Admin-managed (see admin dashboard's Payment Accounts tab) — which bank
  // the rider actually sent the transfer to, so admin can match it up when
  // verifying. Loaded once, same pattern as zones/vehicle types elsewhere.
  List<QueryDocumentSnapshot> _paymentAccounts = [];
  String? _selectedAccountId;
  bool _isLoadingAccounts = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentAccounts();
  }

  Future<void> _loadPaymentAccounts() async {
    final snap = await FirebaseFirestore.instance.collection('paymentAccounts').where('active', isEqualTo: true).get();
    if (!mounted) return;
    setState(() {
      _paymentAccounts = snap.docs;
      _selectedAccountId ??= _paymentAccounts.isNotEmpty ? _paymentAccounts.first.id : null;
      _isLoadingAccounts = false;
    });
  }

  Map<String, dynamic>? get _selectedAccountData {
    final match = _paymentAccounts.where((d) => d.id == _selectedAccountId);
    if (match.isEmpty) return null;
    return match.first.data() as Map<String, dynamic>;
  }

  Future<void> _submitTopup() async {
    final l10n = AppLocalizations.of(context)!;
    final amount = double.tryParse(_amountController.text.trim());
    final reference = _referenceController.text.trim();

    if (_selectedAccountId == null) {
      setState(() => _errorText = l10n.selectPaymentAccountError);
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() => _errorText = l10n.enterValidAmountError);
      return;
    }
    if (reference.isEmpty) {
      setState(() => _errorText = l10n.enterReferenceCodeError);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final account = _selectedAccountData;

    await FirebaseFirestore.instance.collection('transactions').add({
      'userId': uid,
      'type': 'wallet_topup',
      'amount': amount,
      'method': account?['bankName'] ?? 'bank',
      'status': 'pending_verification',
      'referenceCode': reference,
      'proofScreenshotUrl': null,
      'reviewedBy': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.topupSubmittedMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.topUpCommissionBalanceTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
            builder: (context, snapshot) {
              final balance = snapshot.hasData && snapshot.data!.exists
                  ? ((snapshot.data!.data() as Map<String, dynamic>)['walletBalance'] as num?)?.toDouble() ?? 0
                  : 0.0;
              final fillFraction = (balance / 1000).clamp(0.0, 1.0);
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.balanceLabel, style: const TextStyle(color: AppColors.mutedOnDark, fontSize: 12.5)),
                    const SizedBox(height: 6),
                    Text(balance.toStringAsFixed(0), style: AppTypography.amount(size: 34, color: Colors.white)),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: fillFraction,
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
                        },
                        child: Text(l10n.transactionHistoryTitle),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: AppColors.accentTint,
                border: Border.all(color: AppColors.accentBorder),
                borderRadius: AppRadii.cardRadius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.howToTopUpTitle, style: AppTypography.heading(size: 14, color: AppColors.ink)),
                  const SizedBox(height: AppSpacing.s8),
                  Text(l10n.topUpStep1, style: AppTypography.body(size: 13, color: AppColors.bodyText)),
                  Text(l10n.topUpStep2, style: AppTypography.body(size: 13, color: AppColors.bodyText)),
                  Text(l10n.topUpStep3, style: AppTypography.body(size: 13, color: AppColors.bodyText)),
                  Text(l10n.topUpStep4, style: AppTypography.body(size: 13, color: AppColors.bodyText)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoadingAccounts)
              const Center(child: CircularProgressIndicator())
            else if (_paymentAccounts.isEmpty)
              Text(l10n.noPaymentAccountsMessage, style: AppTypography.caption(color: AppColors.mutedLight))
            else ...[
              Text(l10n.selectAccountToTransferLabel, style: AppTypography.label(color: AppColors.mutedLight)),
              const SizedBox(height: 8),
              ..._paymentAccounts.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final bankName = data['bankName'] as String? ?? '';
                final accountNumber = data['accountNumber'] as String? ?? '';
                final initials = bankName.trim().isEmpty
                    ? '?'
                    : bankName.trim().split(RegExp(r'\s+')).take(2).map((w) => w[0]).join().toUpperCase();
                final selected = _selectedAccountId == doc.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => setState(() => _selectedAccountId = doc.id),
                    borderRadius: AppRadii.cardRadius,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.accentTint : AppColors.surface,
                        border: Border.all(color: selected ? AppColors.accent : AppColors.borderAlt, width: selected ? 1.5 : 1),
                        borderRadius: AppRadii.cardRadius,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? AppColors.accent : AppColors.surfaceAlt,
                              borderRadius: AppRadii.smallTileRadius,
                            ),
                            child: Text(
                              initials,
                              style: AppTypography.label(size: 13, color: selected ? Colors.white : AppColors.bodyText),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(bankName, style: AppTypography.body(size: 14.5, color: AppColors.ink).copyWith(fontWeight: FontWeight.w600)),
                                Text(
                                  accountNumber,
                                  style: const TextStyle(fontFamily: AppTypography.monoFamily, fontSize: 12.5, color: AppColors.mutedLight),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected ? AppColors.accent : Colors.transparent,
                              border: selected ? null : Border.all(color: AppColors.border, width: 1.5),
                            ),
                            child: selected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: AppSpacing.s12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.amountSdgLabel),
            ),
            const SizedBox(height: AppSpacing.s12),
            TextField(
              controller: _referenceController,
              decoration: InputDecoration(labelText: l10n.bankakReferenceLabel),
            ),
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.s8),
                child: Text(_errorText!, style: AppTypography.caption(color: AppColors.danger)),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitTopup,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(l10n.submitTopUpRequestButton),
            ),
            ],
          ),
        ],
      ),
    );
  }
}
