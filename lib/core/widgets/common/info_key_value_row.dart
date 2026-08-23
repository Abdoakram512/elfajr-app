import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../constants/app_colors.dart';

class InfoKeyValueRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final bool isBold;
  final Color? valueColor;
  final Color? labelColor;
  final bool showDivider;
  final double fontSize;

  const InfoKeyValueRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.isBold = false,
    this.valueColor,
    this.labelColor,
    this.showDivider = false,
    this.fontSize = 13.0,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: fontSize + 3,
                color: labelColor ?? AppColors.textMutedLight,
              ),
              const Gap(8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                color: labelColor ?? AppColors.textSecondaryLight,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        const Gap(12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: isBold ? fontSize + 1 : fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? AppColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );

    if (!showDivider) {
      return row;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row,
        const Gap(8),
        const Divider(height: 1, color: AppColors.borderLight),
        const Gap(8),
      ],
    );
  }
}
