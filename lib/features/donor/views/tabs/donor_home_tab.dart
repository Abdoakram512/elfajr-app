import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../view_models/donor_cubit.dart';
import '../../view_models/donor_state.dart';
import '../../widgets/category_filter_chips.dart';
import '../../widgets/impact_summary_card.dart';
import '../../widgets/urgent_campaign_card.dart';

class DonorHomeTab extends StatelessWidget {
  const DonorHomeTab({super.key});

  void _showQuickDonateSheet(BuildContext context, CampaignItem campaign) {
    final cubit = context.read<DonorCubit>();
    final amounts = [50.0, 100.0, 250.0, 500.0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Gap(18),
              Text(
                'dashboard.donor.quick_donate_title'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const Gap(6),
              Text(
                campaign.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const Gap(20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: amounts.map((amount) {
                  return SizedBox(
                    width: (MediaQuery.of(context).size.width - 60) / 2,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(bottomSheetContext);
                        cubit.donateToCampaign(campaign.id, amount);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        '${amount.toInt()} ${'common.currency'.tr()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return BlocConsumer<DonorCubit, DonorState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'dashboard.donor.donation_success'.tr(args: [state.successMessage!]),
              ),
              backgroundColor: AppColors.success,
            ),
          );
          context.read<DonorCubit>().clearSuccessMessage();
        }
      },
      builder: (context, state) {
        final cubit = context.read<DonorCubit>();

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar (Brand + Language Switcher)
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
                              Icons.volunteer_activism_rounded,
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
                                'dashboard.donor.greeting'.tr(),
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

                  const Gap(22),

                  // Impact Summary Card
                  ImpactSummaryCard(
                    totalDonated: state.totalDonated,
                    casesSupported: state.casesSupported,
                  ),

                  const Gap(28),

                  // Section Title: Urgent Campaigns
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'dashboard.donor.urgent_campaigns'.tr(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      TextButton(
                        onPressed: () => cubit.setTab(1),
                        child: Text(
                          'dashboard.tabs.explore'.tr(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Gap(12),

                  // Horizontal Urgent Campaigns Carousel
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.campaigns.length,
                      itemBuilder: (context, index) {
                        final campaign = state.campaigns[index];
                        return UrgentCampaignCard(
                          campaign: campaign,
                          onDonate: () => _showQuickDonateSheet(context, campaign),
                        );
                      },
                    ),
                  ),

                  const Gap(28),

                  // Category Filter Chips
                  CategoryFilterChips(
                    selectedCategory: state.selectedCategory,
                    onSelect: cubit.setCategory,
                  ),

                  const Gap(18),

                  // Filtered Campaigns List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.filteredCampaigns.length,
                    separatorBuilder: (context, index) => const Gap(14),
                    itemBuilder: (context, index) {
                      final campaign = state.filteredCampaigns[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.borderLight, width: 0.8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              campaign.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            const Gap(8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: campaign.progress,
                                minHeight: 5,
                                backgroundColor: AppColors.borderLight,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                            const Gap(8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${campaign.progressPercent}% (${campaign.raisedAmount.toInt()} ${'common.currency'.tr()})',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      _showQuickDonateSheet(context, campaign),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(50, 30),
                                  ),
                                  child: Text(
                                    'dashboard.donor.donate_now'.tr(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
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
