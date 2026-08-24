import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';

enum ReceiptFilter { all, pending, confirmed }

class ReceiptsFilterBar extends StatelessWidget {
  final ReceiptFilter selectedFilter;
  final int totalCount;
  final int pendingCount;
  final int confirmedCount;
  final ValueChanged<ReceiptFilter> onFilterChanged;

  const ReceiptsFilterBar({
    super.key,
    required this.selectedFilter,
    required this.totalCount,
    required this.pendingCount,
    required this.confirmedCount,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildFilterTab(
          ReceiptFilter.all,
          'الكل ($totalCount)',
        ),
        const Gap(8),
        _buildFilterTab(
          ReceiptFilter.pending,
          'بانتظار التأكيد ($pendingCount)',
          hasAlert: pendingCount > 0,
        ),
        const Gap(8),
        _buildFilterTab(
          ReceiptFilter.confirmed,
          'المؤكدة ($confirmedCount)',
        ),
      ],
    );
  }

  Widget _buildFilterTab(ReceiptFilter filter, String label,
      {bool hasAlert = false}) {
    final isSelected = selectedFilter == filter;
    return Expanded(
      child: InkWell(
        onTap: () => onFilterChanged(filter),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasAlert && !isSelected) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.accentDark,
                    shape: BoxShape.circle,
                  ),
                ),
                const Gap(5),
              ],
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
      ),
    );
  }
}
