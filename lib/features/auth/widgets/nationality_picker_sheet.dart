import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/arabic_normalizer.dart';
import '../../../../core/utils/nationality_formatter.dart';
import '../../../../core/widgets/sheets/app_sheet_scaffold.dart';

class NationalityPickerSheet extends StatefulWidget {
  final List<String> nationalities;
  final String selectedNationality;
  final ValueChanged<String> onSelected;

  const NationalityPickerSheet({
    super.key,
    required this.nationalities,
    required this.selectedNationality,
    required this.onSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required List<String> nationalities,
    required String selectedNationality,
    required ValueChanged<String> onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NationalityPickerSheet(
        nationalities: nationalities,
        selectedNationality: selectedNationality,
        onSelected: onSelected,
      ),
    );
  }

  @override
  State<NationalityPickerSheet> createState() => _NationalityPickerSheetState();
}

class _NationalityPickerSheetState extends State<NationalityPickerSheet> {
  late String _searchQuery;

  @override
  void initState() {
    super.initState();
    _searchQuery = '';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.nationalities.where((n) {
      if (_searchQuery.isEmpty) return true;
      final mas = n.toMasculineNationality();
      return ArabicNormalizer.matches(mas, _searchQuery) ||
          ArabicNormalizer.matches(n, _searchQuery);
    }).toList();

    return AppSheetScaffold(
      title: 'auth.select_nationality'.tr(),
      subtitle: 'auth.search_nationalities'.tr(),
      icon: Icons.flag_rounded,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'auth.search_nationalities'.tr(),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: AppColors.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'common.no_results'.tr(),
                      style: const TextStyle(color: AppColors.textSecondaryLight),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    itemCount: filtered.length,
                    separatorBuilder: (ctx, i) => const Divider(height: 1, color: AppColors.borderLight),
                    itemBuilder: (ctx, idx) {
                      final item = filtered[idx].toMasculineNationality();
                      final isSel = item == widget.selectedNationality.toMasculineNationality();
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        leading: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.primarySubtle : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.public_rounded,
                            color: isSel ? AppColors.primary : Colors.grey.shade600,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          item,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                            color: isSel ? AppColors.primary : AppColors.textPrimaryLight,
                          ),
                        ),
                        trailing: isSel
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                            : null,
                        onTap: () {
                          widget.onSelected(item);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
