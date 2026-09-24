import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'delivery_detail_screen.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('delivery_requests')
            .where('assignedRiderId', isEqualTo: uid)
            .where('status', isEqualTo: 'delivered')
            // Sorted client-side below, not via .orderBy() — see the same
            // note in rider_app/lib/screens/home_screen.dart's open-requests
            // feed query for why.
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs.toList()
            ..sort((a, b) {
              final aAt = (a.data() as Map<String, dynamic>)['deliveredAt'] as Timestamp?;
              final bAt = (b.data() as Map<String, dynamic>)['deliveredAt'] as Timestamp?;
              if (aAt == null || bAt == null) return 0;
              return bAt.compareTo(aAt); // descending
            });

          double totalEarned = 0;
          double totalCommission = 0;
          // Daily totals for the last 7 days, oldest first — used by the
          // week chart below. Computed from the same already-fetched
          // all-time list rather than a second query.
          final now = DateTime.now();
          final dayStarts = List.generate(
            7,
            (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i)),
          );
          final dailyTotals = List<double>.filled(7, 0);

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final price = (data['finalPrice'] as num?)?.toDouble() ?? 0;
            final commission = (data['commissionCharged'] as num?)?.toDouble() ?? 0;
            totalEarned += price;
            totalCommission += commission;

            final deliveredAt = (data['deliveredAt'] as Timestamp?)?.toDate();
            if (deliveredAt != null) {
              final day = DateTime(deliveredAt.year, deliveredAt.month, deliveredAt.day);
              final dayIndex = dayStarts.indexWhere((d) => d == day);
              if (dayIndex != -1) dailyTotals[dayIndex] += price;
            }
          }
          final netEarned = totalEarned - totalCommission;
          final maxDaily = dailyTotals.fold<double>(0, (a, b) => a > b ? a : b);

          return Column(
            children: [
              Container(
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
                          Text(l10n.earningsTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        totalEarned.toStringAsFixed(0),
                        style: AppTypography.amount(size: 38, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.commissionNetSummary(totalCommission.toStringAsFixed(0), netEarned.toStringAsFixed(0)),
                        style: const TextStyle(color: AppColors.mutedOnDark, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 64,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (var i = 0; i < 7; i++) ...[
                              if (i > 0) const SizedBox(width: 6),
                              Expanded(
                                child: _WeekBar(
                                  fraction: maxDaily > 0 ? dailyTotals[i] / maxDaily : 0,
                                  isHighest: maxDaily > 0 && dailyTotals[i] == maxDaily,
                                  dayInitial: DateFormat('E').format(dayStarts[i])[0],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: docs.isEmpty
                    ? Center(child: Text(l10n.noCompletedDeliveriesYet))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                            child: RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: [
                                  TextSpan(text: l10n.completedDeliveriesCount(docs.length)),
                                  const TextSpan(text: '  '),
                                  TextSpan(
                                    text: totalEarned.toStringAsFixed(0),
                                    style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final data = docs[index].data() as Map<String, dynamic>;
                                final packageInfo = data['packageInfo'] as Map<String, dynamic>? ?? {};
                                final description =
                                    packageInfo['description'] as String? ?? l10n.noDescriptionPlaceholder;
                                final price = (data['finalPrice'] as num?)?.toDouble() ?? 0;
                                final commission = (data['commissionCharged'] as num?)?.toDouble() ?? 0;
                                final deliveredAt = data['deliveredAt'] as Timestamp?;
                                final dateLabel = deliveredAt != null
                                    ? DateFormat('MMM d, y • h:mm a').format(deliveredAt.toDate())
                                    : '';

                                return ListTile(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => DeliveryDetailScreen(data: data)),
                                  ),
                                  title: Text(description),
                                  subtitle: Text(dateLabel, style: const TextStyle(color: AppColors.mutedLight)),
                                  trailing: SizedBox(
                                    width: 90,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          l10n.priceSdgLabel(price.toStringAsFixed(0)),
                                          style: AppTypography.amount(size: 14, color: AppColors.ink),
                                        ),
                                        Text(
                                          l10n.feeDeductedLabel(commission.toStringAsFixed(0)),
                                          style: AppTypography.caption(size: 11, color: AppColors.danger),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }
}

class _WeekBar extends StatelessWidget {
  final double fraction;
  final bool isHighest;
  final String dayInitial;
  const _WeekBar({required this.fraction, required this.isHighest, required this.dayInitial});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: fraction.clamp(0.04, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isHighest ? AppColors.accent : Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(dayInitial, style: const TextStyle(color: AppColors.mutedOnDark, fontSize: 9.5)),
      ],
    );
  }
}
