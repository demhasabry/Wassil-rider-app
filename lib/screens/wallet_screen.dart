import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'wallet_topup_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  String _statusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'verified':
        return l10n.txStatusVerified;
      case 'rejected':
        return l10n.txStatusRejected;
      default:
        return l10n.txStatusPending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final l10n = AppLocalizations.of(context)!;

    // The header below is a full-bleed AppColors.ink block behind the
    // status bar — nothing in this app sets status bar icon brightness, so
    // it silently keeps whatever the previous screen left it at, making the
    // clock/notification/signal icons invisible against black.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
      body: Column(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
            builder: (context, snapshot) {
              final balance = snapshot.hasData && snapshot.data!.exists
                  ? ((snapshot.data!.data() as Map<String, dynamic>)['walletBalance'] as num?)?.toDouble() ?? 0
                  : 0.0;
              final isLow = balance <= 0;
              // No real "quota" concept exists for commission balance — this
              // is a rough visual reference (1000 SDG ~ a comfortably funded
              // balance), not a business rule, purely so the track shows
              // *something* meaningful rather than always-empty/always-full.
              final fillFraction = (balance / 1000).clamp(0.0, 1.0);

              return Container(
                width: double.infinity,
                color: AppColors.ink,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          Text(l10n.commissionBalanceTitle,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(color: AppColors.inkPanel, borderRadius: BorderRadius.circular(20)),
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
                            if (isLow)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  l10n.balanceDepletedMessage,
                                  style: const TextStyle(color: AppColors.mutedOnDark, fontSize: 12.5),
                                ),
                              ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletTopupScreen()));
                                },
                                child: Text(l10n.topUpViaBankakButton),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.transactionHistoryTitle, style: AppTypography.heading()),
                const SizedBox(height: 4),
                Text(l10n.commissionDeductionNote, style: AppTypography.caption(color: AppColors.mutedLight)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('transactions')
                  .where('userId', isEqualTo: uid)
                  // Sorted client-side below, not via .orderBy() — see the
                  // note in home_screen.dart's open-requests feed query for
                  // why a compound where()+orderBy()-on-a-different-field
                  // query isn't safe here.
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs.toList()
                  ..sort((a, b) {
                    final aAt = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                    final bAt = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                    if (aAt == null || bAt == null) return 0;
                    return bAt.compareTo(aAt); // descending
                  });
                if (docs.isEmpty) {
                  return Center(child: Text(l10n.noTransactionsYet));
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final tx = docs[index].data() as Map<String, dynamic>;
                    final status = tx['status'] as String;
                    final type = tx['type'] as String;
                    final isDeduction = type == 'commission_deduction';
                    final isWaived = type == 'commission_waived';
                    final isCredit = !isDeduction; // top-up or waived commission both read as a credit
                    final statusColor = status == 'verified'
                        ? AppColors.success
                        : status == 'rejected'
                            ? AppColors.danger
                            : AppColors.accent;
                    final typeLabel = isWaived
                        ? l10n.commissionWaivedLabel
                        : isDeduction
                            ? l10n.transactionCommissionLabel
                            : l10n.transactionTopUpLabel;

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderAlt),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: isDeduction ? AppColors.accentTintAlt : AppColors.successTint,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isDeduction ? Icons.arrow_downward : Icons.arrow_upward,
                              size: 16,
                              color: isDeduction ? AppColors.accent : AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(typeLabel, style: AppTypography.body(size: 13.5)),
                                Text(
                                  tx['method'] == 'platform'
                                      ? l10n.autoDeductedLabel
                                      : l10n.viaMethodLabel(tx['method']),
                                  style: AppTypography.caption(color: AppColors.mutedLight),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isDeduction ? "-" : ""}${tx['amount']} SDG',
                                style: AppTypography.amount(
                                  size: 14,
                                  color: isCredit ? AppColors.success : AppColors.ink,
                                ),
                              ),
                              if (isWaived)
                                const Icon(Icons.check_circle_outline, size: 14, color: AppColors.success)
                              else if (!isDeduction)
                                Text(_statusLabel(l10n, status),
                                    style: AppTypography.caption(color: statusColor).copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}
