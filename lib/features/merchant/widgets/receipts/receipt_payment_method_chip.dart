import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';

class ReceiptPaymentMethodChip extends StatelessWidget {
  final String method;

  const ReceiptPaymentMethodChip({super.key, required this.method});

  @override
  Widget build(BuildContext context) {
    final (name, color, bgColor, icon) = _getMethodConfig(method);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const Gap(6),
          Text(
            name,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, Color, IconData) _getMethodConfig(String method) {
    switch (method.toLowerCase()) {
      case 'instapay':
        return (
          'merchant.receipts.method_instapay'.tr(),
          AppColors.instapayPurple,
          AppColors.instapayBg,
          AppIcons.instapay,
        );
      case 'vodafone_cash':
        return (
          'merchant.receipts.method_vodafone_cash'.tr(),
          AppColors.vodafoneCashRed,
          AppColors.vodafoneCashBg,
          AppIcons.vodafoneCash,
        );
      case 'bank_transfer':
        return (
          'merchant.receipts.method_bank_transfer'.tr(),
          AppColors.bankTransferBlue,
          AppColors.bankTransferBg,
          AppIcons.bankTransfer,
        );
      default:
        return (
          'merchant.receipts.method_cash'.tr(),
          AppColors.cashGreen,
          AppColors.cashBg,
          AppIcons.cash,
        );
    }
  }
}
