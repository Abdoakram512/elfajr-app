import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/cards/stat_kpi_card.dart';
import '../../../../core/widgets/feedback/app_empty_state_widget.dart';
import '../../../../core/widgets/transactions/transaction_list_item.dart';
import '../../view_models/admin_cubit.dart';
import '../../view_models/admin_state.dart';

class AdminOverviewTab extends StatelessWidget {
  const AdminOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');
    final isArabic = context.locale.languageCode == 'ar';

    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primarySubtle,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const Gap(10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'app_name'.tr(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                'dashboard.admin.greeting'.tr(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Language Switcher Pill
                      InkWell(
                        onTap: () {
                          final newLocale = isArabic
                              ? AppConstants.englishLocale
                              : AppConstants.arabicLocale;
                          context.setLocale(newLocale);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Text(
                            isArabic ? 'English' : 'العربية',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Gap(20),

                  // 2x2 KPI Grid using StatKpiCard
                  Row(
                    children: [
                      Expanded(
                        child: StatKpiCard(
                          title: 'إجمالي المبالغ المصروفة',
                          value:
                              '${currencyFormatter.format(state.totalFundsDisbursed)} ${'common.currency'.tr()}',
                          icon: Icons.account_balance_wallet_rounded,
                          accentColor: AppColors.primary,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: StatKpiCard(
                          title: 'الأسر المستفيدة',
                          value: '${state.totalBeneficiariesCount}',
                          icon: Icons.family_restroom_rounded,
                          accentColor: AppColors.accent,
                        ),
                      ),
                    ],
                  ),

                  const Gap(12),

                  Row(
                    children: [
                      Expanded(
                        child: StatKpiCard(
                          title: 'منافذ الصرف المعتمدة',
                          value: '${state.activeMerchantsCount}',
                          icon: Icons.storefront_rounded,
                          accentColor: const Color(0xFF0284C7),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: StatKpiCard(
                          title: 'إجمالي عمليات الصرف',
                          value: currencyFormatter.format(state.totalRedemptionsCount),
                          icon: Icons.receipt_long_rounded,
                          accentColor: const Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),

                  const Gap(28),

                  // Section Title: Live Redemptions Stream
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'عمليات الصرف اللحظية في المنافذ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const Gap(4),
                            const Text(
                              'بث مباشر',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Gap(14),

                  // List of Live Redemptions
                  if (state.recentRedemptions.isEmpty)
                    const AppEmptyStateWidget(
                      title: 'لا توجد عمليات صرف مسجلة حتى الآن',
                      description: 'ستظهر هنا كافة عمليات الخصم وسحب الإعانات فور تنفيذها في منافذ الصرف',
                      icon: Icons.receipt_long_outlined,
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.recentRedemptions.length,
                      separatorBuilder: (_, _) => const Gap(10),
                      itemBuilder: (context, index) {
                        final item = state.recentRedemptions[index];
                        return TransactionListItem(
                          cardId: item.cardId,
                          beneficiaryName: item.beneficiaryName,
                          merchantStoreName: item.merchantName,
                          amount: item.amount,
                          foodBaskets: item.foodBaskets,
                          city: item.city,
                          timestamp: item.timestamp,
                          showPrintButton: true,
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
