import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CategoryFilterChips extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelect;

  const CategoryFilterChips({
    super.key,
    required this.selectedCategory,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'key': 'all', 'label': 'dashboard.donor.all_categories'},
      {'key': 'food', 'label': 'dashboard.donor.cat_food'},
      {'key': 'health', 'label': 'dashboard.donor.cat_health'},
      {'key': 'orphans', 'label': 'dashboard.donor.cat_orphans'},
      {'key': 'water', 'label': 'dashboard.donor.cat_water'},
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = categories[index];
          final isSelected = selectedCategory == item['key'];

          return InkWell(
            onTap: () => onSelect(item['key']!),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                ),
              ),
              child: Center(
                child: Text(
                  item['label']!.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
