import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';

class ProfileLanguageTile extends StatelessWidget {
  final bool showDivider;

  const ProfileLanguageTile({super.key, this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return Column(
      children: [
        InkWell(
          onTap: () {
            final newLocale = isArabic
                ? AppConstants.englishLocale
                : AppConstants.arabicLocale;
            context.setLocale(newLocale);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.language_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    'common.language'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                Text(
                  isArabic ? 'العربية (AR)' : 'English (EN)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Gap(6),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textMutedLight,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: AppColors.borderLight),
      ],
    );
  }
}
