import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../app/service_locator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/arabic_normalizer.dart';
import '../../../../core/widgets/sheets/app_sheet_scaffold.dart';
import '../repositories/auth_repository.dart';

class DynamicNationalityPickerSheet extends StatefulWidget {
  final String? selectedNationality;
  final ValueChanged<String> onSelected;
  final Stream<List<String>>? nationalitiesStream;

  const DynamicNationalityPickerSheet({
    super.key,
    this.selectedNationality,
    required this.onSelected,
    this.nationalitiesStream,
  });

  static Future<void> show(
    BuildContext context, {
    String? selectedNationality,
    required ValueChanged<String> onSelected,
    Stream<List<String>>? nationalitiesStream,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DynamicNationalityPickerSheet(
        selectedNationality: selectedNationality,
        onSelected: onSelected,
        nationalitiesStream:
            nationalitiesStream ?? getIt<AuthRepository>().streamNationalities(),
      ),
    );
  }

  @override
  State<DynamicNationalityPickerSheet> createState() =>
      _DynamicNationalityPickerSheetState();
}

class _DynamicNationalityPickerSheetState
    extends State<DynamicNationalityPickerSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final stream = widget.nationalitiesStream ??
        getIt<AuthRepository>().streamNationalities();

    return AppSheetScaffold(
      title: 'auth.select_nationality'.tr(),
      subtitle: 'auth.search_nationalities'.tr(),
      icon: Icons.flag_rounded,
      child: StreamBuilder<List<String>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'common.error_occurred'.tr(),
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            );
          }

          final allNationalities = snapshot.data ?? [];

          final filtered = allNationalities.where((n) {
            if (_searchQuery.isEmpty) return true;
            return ArabicNormalizer.matches(n, _searchQuery);
          }).toList();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'auth.search_nationalities'.tr(),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
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
              Flexible(
                child: filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: Text(
                            'common.no_results'.tr(),
                            style: const TextStyle(
                              color: AppColors.textSecondaryLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (ctx, i) => const Divider(
                          height: 1,
                          color: AppColors.borderLight,
                        ),
                        itemBuilder: (ctx, idx) {
                          final item = filtered[idx];
                          final isSel = item == widget.selectedNationality;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? AppColors.primarySubtle
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.public_rounded,
                                color: isSel
                                    ? AppColors.primary
                                    : Colors.grey.shade600,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              item,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    isSel ? FontWeight.bold : FontWeight.w500,
                                color: isSel
                                    ? AppColors.primary
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            trailing: isSel
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  )
                                : null,
                            onTap: () {
                              widget.onSelected(item);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
              ),
              const Gap(10),
            ],
          );
        },
      ),
    );
  }
}
