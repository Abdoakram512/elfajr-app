import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../view_models/volunteer_cubit.dart';
import '../../view_models/volunteer_state.dart';
import '../../widgets/field_task_card.dart';

class VolunteerHomeTab extends StatelessWidget {
  const VolunteerHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return BlocConsumer<VolunteerCubit, VolunteerState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!.tr()),
              backgroundColor: AppColors.success,
            ),
          );
          context.read<VolunteerCubit>().clearSuccessMessage();
        }
      },
      builder: (context, state) {
        final cubit = context.read<VolunteerCubit>();

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primarySubtle,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.groups_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const Gap(10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'app_name'.tr(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                'dashboard.volunteer.greeting'.tr(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Language Switcher Pill
                      InkWell(
                        onTap: () {
                          final newLocale = isArabic
                              ? AppConstants.englishLocale
                              : AppConstants.arabicLocale;
                          context.setLocale(newLocale);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Text(
                            isArabic ? 'English' : 'العربية',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Gap(20),

                  // Volunteer Stats Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${state.completedMissions}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'dashboard.volunteer.completed_missions'.tr(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                        Container(width: 1, height: 40, color: Colors.white24),
                        Column(
                          children: [
                            Text(
                              '${state.volunteerHours}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: AppColors.accentLight,
                              ),
                            ),
                            Text(
                              'dashboard.volunteer.volunteer_hours'.tr(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Gap(18),

                  // Digital Card Delivery Action Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primarySubtle,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.qr_code_2_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const Gap(14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'تسليم وتفعيل كارت إغاثي رقمي',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                              Gap(2),
                              Text(
                                'ربط وتفعيل الـ QR Code للمستفيد ميدانياً',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),

                  const Gap(24),

                  // Section Title: Today's Tasks
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'dashboard.volunteer.todays_tasks'.tr(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySubtle,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${state.pendingTasks.length} ${'dashboard.tabs.tasks'.tr()}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Gap(14),

                  // Tasks List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.tasks.length,
                    separatorBuilder: (context, index) => const Gap(14),
                    itemBuilder: (context, index) {
                      final task = state.tasks[index];
                      return FieldTaskCard(
                        task: task,
                        onComplete: () => cubit.completeTask(task.id),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
