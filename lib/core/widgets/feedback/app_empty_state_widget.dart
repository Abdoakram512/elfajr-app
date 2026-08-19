import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../constants/app_colors.dart';

class AppEmptyStateWidget extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final Widget? actionButton;

  const AppEmptyStateWidget({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.inbox_rounded,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primarySubtle,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.primary),
            ),
            const Gap(16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            if (description != null) ...[
              const Gap(6),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                  height: 1.4,
                ),
              ),
            ],
            if (actionButton != null) ...[const Gap(20), actionButton!],
          ],
        ),
      ),
    );
  }
}
