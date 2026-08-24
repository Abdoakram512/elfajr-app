import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:qout/core/constants/app_colors.dart';

class ReceiptsSummaryHeader extends StatelessWidget {
  final double totalConfirmed;
  final double totalPending;
  final int pendingCount;

  const ReceiptsSummaryHeader({
    super.key,
    required this.totalConfirmed,
    required this.totalPending,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'ar');

    return Column(
      children: [
        // ── 1. Hero Confirmed Funds Banner (Imperial Emerald & Gold) ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: AppColors.receiptsHeaderGradient,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Color(0xFFFDE68A),
                      size: 20,
                    ),
                  ),
                  const Gap(10),
                  const Expanded(
                    child: Text(
                      'إجمالي الحوالات المعتمدة',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const Gap(8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 14,
                          color: Color(0xFFFDE68A),
                        ),
                        Gap(5),
                        Text(
                          'مؤكدة بالكامل',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Gap(18),

              // Large Amount Display
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    currencyFormatter.format(totalConfirmed),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'common.currency'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── 2. Pending Transfers Alert Banner (If pending funds exist) ──
        if (totalPending > 0) ...[
          const Gap(14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.amber50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accentLight, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentDark.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.amber100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.schedule_rounded,
                    color: AppColors.accentDark,
                    size: 22,
                  ),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'بانتظار تأكيدك ($pendingCount حوالات واردة)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF92400E),
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '${currencyFormatter.format(totalPending)} ${'common.currency'.tr()}',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
