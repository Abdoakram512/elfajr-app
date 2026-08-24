import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';

class BeneficiaryMonthlyStatement extends StatelessWidget {
  final double initialMonthEstimate;
  final double thisMonthSpent;
  final double availableBalance;
  final int foodBasketsQuota;
  final int thisMonthBasketsSpent;
  final DateTime now;
  final VoidCallback? onOpenFullAnalytics;

  const BeneficiaryMonthlyStatement({
    super.key,
    required this.initialMonthEstimate,
    required this.thisMonthSpent,
    required this.availableBalance,
    required this.foodBasketsQuota,
    required this.thisMonthBasketsSpent,
    required this.now,
    this.onOpenFullAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'ar');
    final totalBudget = initialMonthEstimate > 0 ? initialMonthEstimate : (availableBalance + thisMonthSpent);
    final consumptionRatio = totalBudget > 0 ? (thisMonthSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
    final isLowBalance = availableBalance > 0 && totalBudget > 0 && ((availableBalance / totalBudget) <= 0.20);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: Text(
                        'dashboard.beneficiary.monthly_statement'.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  DateFormat('MMMM yyyy', 'ar').format(now),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const Gap(16),

          // Financial Breakdown Row
          Row(
            children: [
              // Initial Balance
              Expanded(
                child: _buildStatementBox(
                  label: 'dashboard.beneficiary.monthly_initial'.tr(),
                  value: '${currencyFormatter.format(initialMonthEstimate)} ${'common.currency'.tr()}',
                  valueColor: AppColors.textPrimaryLight,
                ),
              ),
              const Gap(10),

              // Spent this month
              Expanded(
                child: _buildStatementBox(
                  label: 'dashboard.beneficiary.monthly_spent'.tr(),
                  value: '-${currencyFormatter.format(thisMonthSpent)} ${'common.currency'.tr()}',
                  valueColor: AppColors.error,
                ),
              ),
            ],
          ),
          const Gap(12),

          // Remaining Balance & Baskets Row
          Row(
            children: [
              // Remaining Cash
              Expanded(
                child: _buildStatementBox(
                  label: 'dashboard.beneficiary.monthly_remaining'.tr(),
                  value: '${currencyFormatter.format(availableBalance)} ${'common.currency'.tr()}',
                  valueColor: AppColors.primary,
                  isHighlight: true,
                ),
              ),
              const Gap(10),

              // Baskets Breakdown
              Expanded(
                child: _buildStatementBox(
                  label: 'dashboard.beneficiary.monthly_baskets'.tr(),
                  value: '$foodBasketsQuota ${'digital_card.baskets_unit'.tr()}',
                  valueColor: const Color(0xFFD97706),
                  subtitle: thisMonthBasketsSpent > 0
                      ? 'dashboard.beneficiary.baskets_spent_sub'.tr(namedArgs: {'spent': '$thisMonthBasketsSpent'})
                      : null,
                ),
              ),
            ],
          ),

          const Gap(14),

          // Progress Bar & Consumption Rate
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${'dashboard.beneficiary.consumption_rate'.tr()}: ${(consumptionRatio * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isLowBalance ? AppColors.error : AppColors.textSecondaryLight,
                    ),
                  ),
                  if (onOpenFullAnalytics != null)
                    InkWell(
                      onTap: onOpenFullAnalytics,
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        children: [
                          Text(
                            'dashboard.beneficiary.analytics_title'.tr(),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const Gap(2),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 10,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const Gap(6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: consumptionRatio,
                  minHeight: 7,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isLowBalance ? AppColors.error : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms);
  }

  Widget _buildStatementBox({
    required String label,
    required String value,
    required Color valueColor,
    String? subtitle,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlight ? AppColors.primarySubtle.withValues(alpha: 0.4) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlight ? AppColors.primary.withValues(alpha: 0.3) : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const Gap(4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
          if (subtitle != null) ...[
            const Gap(2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9.5,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
