import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';

class ReceiptStatusBadge extends StatelessWidget {
  final bool isConfirmed;

  const ReceiptStatusBadge({super.key, required this.isConfirmed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isConfirmed ? AppColors.emerald50 : AppColors.amber100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConfirmed ? AppColors.emerald200 : AppColors.accentLight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConfirmed ? AppIcons.checkCircleOutline : AppIcons.schedule,
            size: 15,
            color: isConfirmed ? AppColors.emerald600 : AppColors.accentDark,
          ),
          const Gap(5),
          Text(
            isConfirmed
                ? 'merchant.receipts.status_confirmed'.tr()
                : 'merchant.receipts.status_pending'.tr(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isConfirmed ? AppColors.emerald800 : AppColors.amber800,
            ),
          ),
        ],
      ),
    );
  }
}
