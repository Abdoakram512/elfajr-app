import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../view_models/beneficiary_state.dart';

class BeneficiaryTimeframeFilterBar extends StatelessWidget {
  final BeneficiaryTimeframeFilter selectedTimeframe;
  final DateTimeRange? customDateRange;
  final ValueChanged<BeneficiaryTimeframeFilter> onTimeframeChanged;
  final ValueChanged<DateTimeRange?> onCustomRangeChanged;

  const BeneficiaryTimeframeFilterBar({
    super.key,
    required this.selectedTimeframe,
    required this.customDateRange,
    required this.onTimeframeChanged,
    required this.onCustomRangeChanged,
  });

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: customDateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onCustomRangeChanged(picked);
      onTimeframeChanged(BeneficiaryTimeframeFilter.custom);
    }
  }

  Widget _buildFilterChip({
    required BeneficiaryTimeframeFilter filter,
    required String label,
    required IconData icon,
  }) {
    final isSelected = selectedTimeframe == filter;

    return InkWell(
      onTap: () => onTimeframeChanged(filter),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
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
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondaryLight,
            ),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCustomSelected =
        selectedTimeframe == BeneficiaryTimeframeFilter.custom;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip(
            filter: BeneficiaryTimeframeFilter.thisMonth,
            label: 'dashboard.beneficiary.filter_month'.tr(),
            icon: Icons.calendar_month_rounded,
          ),
          const Gap(8),
          _buildFilterChip(
            filter: BeneficiaryTimeframeFilter.lastMonth,
            label: 'dashboard.beneficiary.filter_last_month'.tr(),
            icon: Icons.history_toggle_off_rounded,
          ),
          const Gap(8),
          _buildFilterChip(
            filter: BeneficiaryTimeframeFilter.allTime,
            label: 'dashboard.beneficiary.filter_all'.tr(),
            icon: Icons.all_inclusive_rounded,
          ),
          const Gap(8),
          // Custom Date Range Picker Chip
          InkWell(
            onTap: () => _selectCustomDateRange(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isCustomSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCustomSelected
                      ? AppColors.primary
                      : AppColors.borderLight,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_calendar_rounded,
                    size: 16,
                    color: isCustomSelected
                        ? Colors.white
                        : AppColors.textSecondaryLight,
                  ),
                  const Gap(8),
                  Text(
                    isCustomSelected && customDateRange != null
                        ? '${DateFormat('MM/dd').format(customDateRange!.start)} - ${DateFormat('MM/dd').format(customDateRange!.end)}'
                        : 'dashboard.beneficiary.filter_custom_range'.tr(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isCustomSelected
                          ? Colors.white
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
