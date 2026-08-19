import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../view_models/donor_cubit.dart';
import '../../view_models/donor_state.dart';
import '../../widgets/category_filter_chips.dart';

class DonorExploreTab extends StatelessWidget {
  const DonorExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');

    return BlocBuilder<DonorCubit, DonorState>(
      builder: (context, state) {
        final cubit = context.read<DonorCubit>();

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: Text('dashboard.tabs.explore'.tr()),
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                CategoryFilterChips(
                  selectedCategory: state.selectedCategory,
                  onSelect: cubit.setCategory,
                ),
                const Gap(16),
                Expanded(
                  child: ListView.separated(
                    itemCount: state.filteredCampaigns.length,
                    separatorBuilder: (context, index) => const Gap(14),
                    itemBuilder: (context, index) {
                      final campaign = state.filteredCampaigns[index];
                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  campaign.location,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMutedLight,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySubtle,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${campaign.progressPercent}%',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(8),
                            Text(
                              campaign.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            const Gap(12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: campaign.progress,
                                minHeight: 6,
                                backgroundColor: AppColors.borderLight,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                            const Gap(10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${'dashboard.donor.raised'.tr()}: ${currencyFormatter.format(campaign.raisedAmount)} ${'common.currency'.tr()}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                                Text(
                                  '${'dashboard.donor.target'.tr()}: ${currencyFormatter.format(campaign.targetAmount)} ${'common.currency'.tr()}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
