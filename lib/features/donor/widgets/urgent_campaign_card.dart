import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../view_models/donor_state.dart';

class UrgentCampaignCard extends StatelessWidget {
  final CampaignItem campaign;
  final VoidCallback onDonate;

  const UrgentCampaignCard({
    super.key,
    required this.campaign,
    required this.onDonate,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 290,
      margin: const EdgeInsets.only(left: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Tag & Location
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _getCategoryName(campaign.category).tr(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: AppColors.textMutedLight,
                  ),
                  const Gap(3),
                  Text(
                    campaign.location,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Gap(12),

          // Title
          Text(
            campaign.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              height: 1.35,
            ),
          ),

          const Spacer(),

          // Progress Bar with Percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${campaign.progressPercent}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '${'dashboard.donor.remaining'.tr()}: ${currencyFormatter.format(campaign.remaining)} ${'common.currency'.tr()}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),

          const Gap(6),

          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: campaign.progress,
              minHeight: 6,
              backgroundColor: AppColors.borderLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),

          const Gap(16),

          // Quick Donate Action Button
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: onDonate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'dashboard.donor.donate_now'.tr(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String cat) {
    switch (cat) {
      case 'food':
        return 'dashboard.donor.cat_food';
      case 'health':
        return 'dashboard.donor.cat_health';
      case 'water':
        return 'dashboard.donor.cat_water';
      case 'orphans':
        return 'dashboard.donor.cat_orphans';
      default:
        return 'dashboard.donor.all_categories';
    }
  }
}
