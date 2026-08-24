import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';

enum MerchantTimeframeFilter { today, thisWeek, thisMonth, all, custom }

class MerchantHistoryTimeframeSelector extends StatelessWidget {
  final MerchantTimeframeFilter selectedFilter;
  final DateTime? customSelectedDate;
  final ValueChanged<MerchantTimeframeFilter> onFilterChanged;
  final VoidCallback onSelectCustomDate;

  const MerchantHistoryTimeframeSelector({
    super.key,
    required this.selectedFilter,
    required this.customSelectedDate,
    required this.onFilterChanged,
    required this.onSelectCustomDate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(
            filter: MerchantTimeframeFilter.today,
            label: 'merchant.filter_today'.tr(),
            icon: AppIcons.schedule,
          ),
          const Gap(8),
          _buildChip(
            filter: MerchantTimeframeFilter.thisWeek,
            label: 'merchant.filter_week'.tr(),
            icon: Icons.calendar_view_week_rounded,
          ),
          const Gap(8),
          _buildChip(
            filter: MerchantTimeframeFilter.thisMonth,
            label: 'merchant.filter_month'.tr(),
            icon: Icons.calendar_month_rounded,
          ),
          const Gap(8),
          _buildChip(
            filter: MerchantTimeframeFilter.all,
            label: 'merchant.filter_all'.tr(),
            icon: Icons.all_inclusive_rounded,
          ),
          const Gap(8),
          _buildCustomChip(),
        ],
      ),
    );
  }

  Widget _buildChip({
    required MerchantTimeframeFilter filter,
    required String label,
    required IconData icon,
  }) {
    final isSelected = selectedFilter == filter;
    return InkWell(
      onTap: () => onFilterChanged(filter),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppColors.textSecondaryLight,
            ),
            const Gap(6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomChip() {
    final isSelected = selectedFilter == MerchantTimeframeFilter.custom;
    final label = customSelectedDate != null
        ? DateFormat('MM/dd').format(customSelectedDate!)
        : 'merchant.filter_custom'.tr();

    return InkWell(
      onTap: onSelectCustomDate,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range_rounded,
              size: 15,
              color: isSelected ? Colors.white : AppColors.textSecondaryLight,
            ),
            const Gap(6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
