import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';

class MerchantHistoryMetricsCard extends StatelessWidget {
  final double totalDisbursed;
  final int opsCount;
  final int uniqueBeneficiaries;
  final String timeframeLabel;

  const MerchantHistoryMetricsCard({
    super.key,
    required this.totalDisbursed,
    required this.opsCount,
    required this.uniqueBeneficiaries,
    required this.timeframeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'ar');

    return Column(
      children: [
        // ── 1. Hero Revenue Disbursed Card (Imperial Emerald & Gold Glow) ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.accentLight.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Icon(
                          AppIcons.payment,
                          color: AppColors.accentLight,
                          size: 18,
                        ),
                      ),
                      const Gap(10),
                      Text(
                        'merchant.stats_total_amount'.tr(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      timeframeLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const Gap(14),

              // Main Amount Value
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    currencyFormatter.format(totalDisbursed),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Gap(6),
                  Text(
                    'common.currency'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),

              const Gap(16),

              // Bottom Sub-metric Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          AppIcons.checkCircleOutline,
                          size: 15,
                          color: AppColors.accentLight,
                        ),
                        const Gap(6),
                        Text(
                          '$opsCount عملية صرف معتمدة بالمنفذ',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentLight.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'محدّث لحظياً',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Gap(12),

        // ── 2. Secondary KPI Metric Grid (Beneficiaries & Operations) ──
        Row(
          children: [
            // Beneficiaries Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.groups_rounded,
                            color: Color(0xFF0284C7),
                            size: 18,
                          ),
                        ),
                        Text(
                          'merchant.stats_beneficiaries'.tr(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0369A1),
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    Text(
                      '$uniqueBeneficiaries ${'merchant.beneficiaries_cases_label'.tr()}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0369A1),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Gap(10),

            // Total Operations Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.instapayBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFDDD6FE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            AppIcons.history,
                            color: AppColors.instapayPurple,
                            size: 18,
                          ),
                        ),
                        Text(
                          'merchant.stats_operations'.tr(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5B21B6),
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    Text(
                      '$opsCount ${'merchant.txns_unit_label'.tr()}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF5B21B6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
