import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../constants/app_colors.dart';

class AppHeroCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? badgeText;
  final IconData? icon;
  final String? imageAssetPath;
  final Gradient? gradient;
  final List<Widget>? extraChildren;
  final double iconSize;

  const AppHeroCard({
    super.key,
    required this.title,
    this.subtitle,
    this.badgeText,
    this.icon,
    this.imageAssetPath,
    this.gradient,
    this.extraChildren,
    this.iconSize = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imageAssetPath != null)
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accentLight.withValues(alpha: 0.9),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(iconSize / 2),
                child: Image.asset(
                  imageAssetPath!,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Icon(
                    icon ?? Icons.spa_rounded,
                    size: iconSize * 0.5,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else if (icon != null)
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize * 0.52,
                color: Colors.white,
              ),
            ),

          const Gap(14),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const Gap(6),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ],

          if (badgeText != null && badgeText!.isNotEmpty) ...[
            const Gap(12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                badgeText!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentLight,
                ),
              ),
            ),
          ],

          if (extraChildren != null && extraChildren!.isNotEmpty) ...[
            const Gap(12),
            ...extraChildren!,
          ],
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.08, end: 0);
  }
}
