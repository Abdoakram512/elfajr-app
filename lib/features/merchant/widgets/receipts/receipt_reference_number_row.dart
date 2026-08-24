import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/utils/haptic_feedback_helper.dart';

class ReceiptReferenceNumberRow extends StatelessWidget {
  final String referenceNumber;

  const ReceiptReferenceNumberRow({super.key, required this.referenceNumber});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(
                Icons.tag_rounded,
                size: 17,
                color: AppColors.textSecondaryLight,
              ),
              const Gap(6),
              Expanded(
                child: Text(
                  'merchant.receipts.ref_label'
                      .tr(namedArgs: {'ref': referenceNumber}),
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    color: AppColors.slate900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: referenceNumber));
            HapticHelper.light();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم نسخ رقم المرجع: $referenceNumber'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  AppIcons.copy,
                  size: 14,
                  color: AppColors.primary,
                ),
                const Gap(5),
                Text(
                  'نسخ',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
