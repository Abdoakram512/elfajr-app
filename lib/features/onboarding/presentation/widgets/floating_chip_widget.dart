import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

class FloatingChipWidget extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color accentColor;
  final int animationDelay;
  final bool isLeft;

  const FloatingChipWidget({
    super.key,
    required this.text,
    required this.icon,
    required this.accentColor,
    this.animationDelay = 0,
    this.isLeft = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 14,
              color: accentColor,
            ),
          ),
          const Gap(8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: animationDelay.ms, duration: 500.ms)
        .scale(
          delay: animationDelay.ms,
          duration: 500.ms,
          curve: Curves.easeOutBack,
        )
        .then()
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .slideY(
          begin: 0,
          end: isLeft ? -0.08 : 0.08,
          duration: 1800.ms,
          curve: Curves.easeInOut,
        );
  }
}
