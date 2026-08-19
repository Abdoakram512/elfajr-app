import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/app_colors.dart';
import '../view_models/volunteer_state.dart';

class FieldTaskCard extends StatelessWidget {
  final FieldMissionTask task;
  final VoidCallback onComplete;

  const FieldTaskCard({
    super.key,
    required this.task,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: task.isCompleted
              ? AppColors.success.withValues(alpha: 0.4)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  task.id,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: task.isCompleted
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
              ),
              if (task.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check, size: 12, color: Colors.white),
                      const Gap(4),
                      Text(
                        'dashboard.beneficiary.step_completed'.tr(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const Gap(12),

          Text(
            task.beneficiaryName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),

          const Gap(6),

          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 15,
                color: AppColors.primary,
              ),
              const Gap(6),
              Expanded(
                child: Text(
                  task.aidPackage,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),

          const Gap(6),

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 15,
                color: AppColors.textMutedLight,
              ),
              const Gap(6),
              Expanded(
                child: Text(
                  task.address,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMutedLight,
                  ),
                ),
              ),
            ],
          ),

          if (!task.isCompleted) ...[
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone_rounded, size: 16),
                    label: Text(task.phone),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                    label: Text(
                      'dashboard.volunteer.deliver_aid'.tr(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
