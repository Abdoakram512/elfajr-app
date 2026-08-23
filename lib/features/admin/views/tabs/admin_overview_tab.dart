import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../app/service_locator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/cards/stat_kpi_card.dart';
import '../../../../core/widgets/feedback/app_empty_state_widget.dart';
import '../../../../core/widgets/feedback/alfajr_refresh_indicator.dart';
import '../../../../core/widgets/transactions/transaction_list_item.dart';
import '../../view_models/admin_overview_cubit.dart';
import '../../view_models/admin_overview_state.dart';

class AdminOverviewTab extends StatelessWidget {
  const AdminOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminOverviewCubit>(),
      child: const _AdminOverviewTabBody(),
    );
  }
}

class _AdminOverviewTabBody extends StatelessWidget {
  const _AdminOverviewTabBody();

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');

    return BlocBuilder<AdminOverviewCubit, AdminOverviewState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: SafeArea(
            child: AlfajrRefreshIndicator(
              onRefresh: () =>
                  context.read<AdminOverviewCubit>().refreshData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                                'admin.portal_title'.tr(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const Gap(6),
                            Text(
                              'admin.system_live'.tr(),
                              style: const TextStyle(
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

                  const Gap(24),

                  // Section Title: Executive Overview
                  Text(
                    'admin.executive_overview'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const Gap(14),

                  // Global Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: StatKpiCard(
                          title: 'admin.stats.total_disbursed'.tr(),
                          value:
                              '${currencyFormatter.format(state.totalFundsDisbursed)} ${'common.currency'.tr()}',
                          icon: Icons.account_balance_wallet_rounded,
                          accentColor: AppColors.primary,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: StatKpiCard(
                          title: 'admin.stats.total_redemptions'.tr(),
                          value: currencyFormatter.format(
                            state.totalRedemptionsCount,
                          ),
                          icon: Icons.receipt_long_rounded,
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
                          title: 'admin.stats.total_beneficiaries'.tr(),
                          value: currencyFormatter.format(
                            state.totalBeneficiariesCount,
                          ),
                          icon: Icons.people_alt_rounded,
                          accentColor: AppColors.info,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: StatKpiCard(
                          title: 'admin.stats.active_merchants'.tr(),
                          value: state.activeMerchantsCount.toString(),
                          icon: Icons.storefront_rounded,
                          accentColor: AppColors.success,
                        ),
                      ),
                    ],
                  ),

                  const Gap(28),

                  // Live Feed Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'admin.live_feed'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      Row(
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
                          Text(
                            'admin.live_sync'.tr(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Gap(14),

                  // Recent Redemptions Feed List
                  if (state.recentRedemptions.isEmpty)
                    AppEmptyStateWidget(
                      title: 'admin.empty_redemptions_title'.tr(),
                      description: 'admin.empty_redemptions_desc'.tr(),
                      icon: Icons.sync_rounded,
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.recentRedemptions.length,
                      separatorBuilder: (context, index) => const Gap(12),
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
                  const Gap(24),
                ],
              ),
            ),
          ),
          ),
        );
      },
    );
  }
}
