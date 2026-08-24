import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/feedback/alfajr_refresh_indicator.dart';
import '../../../../core/widgets/feedback/alfajr_shimmer.dart';
import '../../../../core/widgets/feedback/app_empty_state_widget.dart';
import '../../view_models/beneficiary_cubit.dart';
import '../../view_models/beneficiary_state.dart';
import '../../widgets/beneficiary_analytics_hero_card.dart';
import '../../widgets/beneficiary_redemption_card.dart';
import '../../widgets/beneficiary_timeframe_filter_bar.dart';

class BeneficiaryRedemptionsTab extends StatefulWidget {
  const BeneficiaryRedemptionsTab({super.key});

  @override
  State<BeneficiaryRedemptionsTab> createState() =>
      _BeneficiaryRedemptionsTabState();
}

class _BeneficiaryRedemptionsTabState extends State<BeneficiaryRedemptionsTab> {
  BeneficiaryTimeframeFilter _selectedTimeframe =
      BeneficiaryTimeframeFilter.thisMonth;
  DateTimeRange? _customDateRange;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BeneficiaryCubit, BeneficiaryState>(
      builder: (context, state) {
        if (state.isLoading && state.redemptions.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              title: Text('dashboard.tabs.history'.tr()),
              automaticallyImplyLeading: false,
            ),
            body: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: 4,
              separatorBuilder: (context, index) => const Gap(14),
              itemBuilder: (context, index) => const AlfajrShimmer.card(),
            ),
          );
        }

        final card = state.activeCard;
        final currentBalance = card?.totalBalance ?? 0.0;
        final remainingBaskets = card?.foodBasketsQuota ?? 0;

        final filteredList = state.redemptions.filterByTimeframe(
          _selectedTimeframe,
          customRange: _customDateRange,
        );

        final totalDisbursed = filteredList.totalDisbursed;
        final totalBaskets = filteredList.totalBaskets;
        final operationsCount = filteredList.length;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: Text(
              'dashboard.tabs.history'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimaryLight,
              ),
            ),
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: AppColors.borderLight, height: 1),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      '$operationsCount ${'merchant.txns_unit_label'.tr()}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: AlfajrRefreshIndicator(
            onRefresh: () => context.read<BeneficiaryCubit>().refreshData(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              children: [
                // 1. Timeframe Filter Bar
                BeneficiaryTimeframeFilterBar(
                  selectedTimeframe: _selectedTimeframe,
                  customDateRange: _customDateRange,
                  onTimeframeChanged: (filter) {
                    setState(() => _selectedTimeframe = filter);
                  },
                  onCustomRangeChanged: (range) {
                    setState(() => _customDateRange = range);
                  },
                ),

                const Gap(16),

                // 2. Official Brand Hero Card
                BeneficiaryAnalyticsHeroCard(
                  totalDisbursed: totalDisbursed,
                  totalBaskets: totalBaskets,
                  currentBalance: currentBalance,
                  remainingBaskets: remainingBaskets,
                  timeframeLabel: _selectedTimeframe.getLabel(
                    customRange: _customDateRange,
                  ),
                  operationsCount: operationsCount,
                ),

                const Gap(20),

                // 3. Transactions Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'dashboard.beneficiary.redemptions_history'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySubtle,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'dashboard.beneficiary.txns_count_label'.tr(
                          namedArgs: {'count': '$operationsCount'},
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const Gap(12),

                // 4. Redemptions List / Empty State
                if (filteredList.isEmpty)
                  AppEmptyStateWidget(
                    title: 'merchant.no_matching_txns_title'.tr(),
                    description: 'merchant.no_matching_txns_desc'.tr(),
                    icon: Icons.receipt_long_outlined,
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    separatorBuilder: (context, index) => const Gap(12),
                    itemBuilder: (context, index) {
                      return BeneficiaryRedemptionCard(
                        transaction: filteredList[index],
                        card: card,
                      );
                    },
                  ),

                const Gap(24),
              ],
            ),
          ),
        );
      },
    );
  }
}
