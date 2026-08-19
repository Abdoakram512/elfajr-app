import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../view_models/admin_cubit.dart';
import '../../view_models/admin_state.dart';
import '../../widgets/admin_kpi_card.dart';

class AdminOverviewTab extends StatelessWidget {
  const AdminOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');
    final dateFormatter = DateFormat('yyyy/MM/dd - HH:mm');
    final isArabic = context.locale.languageCode == 'ar';

    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        final cubit = context.read<AdminCubit>();

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
                            decoration: BoxDecoration(
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

                  // 2x2 KPI Grid
                  Row(
                    children: [
                      Expanded(
                        child: AdminKpiCard(
                          title: 'إجمالي المبالغ المصروفة',
                          value:
                              '${currencyFormatter.format(state.totalFundsDisbursed)} ${'common.currency'.tr()}',
                          icon: Icons.account_balance_wallet_rounded,
                          accentColor: AppColors.primary,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: AdminKpiCard(
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
                        child: AdminKpiCard(
                          title: 'منافذ الصرف المعتمدة',
                          value: '${state.activeMerchantsCount}',
                          icon: Icons.storefront_rounded,
                          accentColor: const Color(0xFF0284C7),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: AdminKpiCard(
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
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      TextButton(
                        onPressed: () => cubit.setTab(1),
                        child: const Text(
                          'إدارة المنافذ',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Gap(12),

                  if (state.recentRedemptions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'لا توجد عمليات صرف مسجلة حتى الآن.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMutedLight,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.recentRedemptions.length,
                      separatorBuilder: (context, index) => const Gap(12),
                      itemBuilder: (context, index) {
                        final item = state.recentRedemptions[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.borderLight),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primarySubtle,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.store_rounded,
                                          color: AppColors.primary,
                                          size: 18,
                                        ),
                                      ),
                                      const Gap(10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.merchantName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimaryLight,
                                            ),
                                          ),
                                          Text(
                                            'المستفيد: ${item.beneficiaryName}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondaryLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '-${currencyFormatter.format(item.amount)} ${'common.currency'.tr()}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.error,
                                        ),
                                      ),
                                      if (item.foodBaskets > 0)
                                        Text(
                                          '+${item.foodBaskets} سلة غذائية',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.accentDark,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              const Gap(12),
                              const Divider(height: 1, color: AppColors.borderLight),
                              const Gap(8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'الكارت: ${item.cardId} • ${item.city}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMutedLight,
                                    ),
                                  ),
                                  Text(
                                    dateFormatter.format(item.timestamp),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMutedLight,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
