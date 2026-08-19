import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../constants/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.backgroundColor,
    this.textColor,
    this.height = 56,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppColors.primary;
    final effectiveTextColor = textColor ?? Colors.white;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          alignment: Alignment.center,
          backgroundColor: effectiveBg,
          foregroundColor: effectiveTextColor,
          disabledBackgroundColor: effectiveBg.withValues(alpha: 0.6),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: effectiveBg.withValues(alpha: 0.4),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leadingIcon != null) ...[
                      Icon(leadingIcon, size: 20, color: effectiveTextColor),
                      const Gap(8),
                    ],
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: effectiveTextColor,
                        height: 1.0,
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      const Gap(8),
                      Transform.flip(
                        flipX:
                            isRtl &&
                            trailingIcon == Icons.arrow_forward_rounded,
                        child: Icon(
                          trailingIcon,
                          size: 20,
                          color: effectiveTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
