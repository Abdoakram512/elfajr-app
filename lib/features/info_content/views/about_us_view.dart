import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:qout/core/constants/app_colors.dart';

import '../../../../app/service_locator.dart';
import '../../../../core/widgets/feedback/app_error_state_widget.dart';
import '../../../../core/widgets/feedback/app_loading_indicator.dart';
import '../../../../core/widgets/feedback/alfajr_refresh_indicator.dart';
import '../view_models/info_cubit.dart';
import '../view_models/info_state.dart';

class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<InfoCubit>(),
      child: const _AboutUsViewBody(),
    );
  }
}

class _AboutUsViewBody extends StatelessWidget {
  const _AboutUsViewBody();

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('info_content.about.title'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<InfoCubit, InfoState>(
        builder: (context, state) {
          if (state.isLoading && state.aboutUs == null) {
            return const AppLoadingIndicator();
          }

          final about = state.aboutUs;
          if (about == null) {
            return AppErrorStateWidget(
              errorMessage: state.errorMessage ?? 'info_content.about.failed_to_load'.tr(),
              onRetry: () => context.read<InfoCubit>().loadAllInfo(),
            );
          }

          return AlfajrRefreshIndicator(
            onRefresh: () => context.read<InfoCubit>().loadAllInfo(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Hero Brand Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
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
                            borderRadius: BorderRadius.circular(44),
                            child: Image.asset(
                              'assets/images/app_logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => const Icon(
                                Icons.spa_rounded,
                                size: 44,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const Gap(14),
                        Text(
                          about.title(lang),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (about.tagline(lang).isNotEmpty) ...[
                          const Gap(6),
                          Text(
                            about.tagline(lang),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.4,
                            ),
                          ),
                        ],
                        const Gap(14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            'info_content.about.version_label'.tr(namedArgs: {'version': about.version}),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                  if (about.description(lang).isNotEmpty) ...[
                    const Gap(20),
                    _buildCard(
                      icon: Icons.info_outline_rounded,
                      title: 'info_content.about.about_system'.tr(),
                      content: Text(
                        about.description(lang),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondaryLight,
                          height: 1.6,
                        ),
                      ),
                    ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                  ],

                  if (about.vision(lang).isNotEmpty) ...[
                    const Gap(16),
                    _buildCard(
                      icon: Icons.visibility_outlined,
                      title: 'info_content.about.our_vision'.tr(),
                      content: Text(
                        about.vision(lang),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondaryLight,
                          height: 1.6,
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  ],

                  if (about.mission(lang).isNotEmpty) ...[
                    const Gap(16),
                    _buildCard(
                      icon: Icons.flag_outlined,
                      title: 'info_content.about.our_mission'.tr(),
                      content: Text(
                        about.mission(lang),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondaryLight,
                          height: 1.6,
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                  ],

                  if (about.values(lang).isNotEmpty) ...[
                    const Gap(16),
                    _buildCard(
                      icon: Icons.diamond_outlined,
                      title: 'info_content.about.core_values'.tr(),
                      content: Column(
                        children: about.values(lang)
                            .map(
                              (val) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                    const Gap(10),
                                    Expanded(
                                      child: Text(
                                        val,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimaryLight,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                  ],

                  const Gap(16),
                  // Organization Contact Info
                  _buildCard(
                    icon: Icons.location_city_rounded,
                    title: 'info_content.about.hq_and_contact'.tr(),
                    content: Column(
                      children: [
                        if (about.headquarters(lang).isNotEmpty) ...[
                          _buildInfoRow(
                            Icons.location_on_outlined,
                            'info_content.about.headquarters'.tr(),
                            about.headquarters(lang),
                          ),
                          const Divider(height: 16, color: AppColors.borderLight),
                        ],
                        if (about.email.isNotEmpty) ...[
                          _buildInfoRow(
                            Icons.email_outlined,
                            'info_content.about.official_email'.tr(),
                            about.email,
                          ),
                          const Divider(height: 16, color: AppColors.borderLight),
                        ],
                        if (about.phone.isNotEmpty)
                          _buildInfoRow(
                            Icons.phone_outlined,
                            'info_content.about.hotline'.tr(),
                            about.phone,
                          ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                  const Gap(24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const Gap(10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const Gap(14),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMutedLight),
        const Gap(8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
