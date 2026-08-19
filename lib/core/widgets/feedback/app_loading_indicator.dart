import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AppLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;

  const AppLoadingIndicator({
    super.key,
    this.color,
    this.size = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2.8,
          color: color ?? AppColors.primary,
        ),
      ),
    );
  }
}
