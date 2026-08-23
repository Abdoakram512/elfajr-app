import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:qout/core/constants/app_colors.dart';

import '../../../../app/service_locator.dart';
import '../../../../core/widgets/cards/app_hero_card.dart';
import '../../../../core/widgets/common/info_key_value_row.dart';
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
                  AppHeroCard(
                    imageAssetPath: 'assets/images/app_logo.png',
                    title: about.title(lang),
                    subtitle: about.tagline(lang),
                    badgeText: 'info_content.about.version_label'.tr(namedArgs: {'version': about.version}),
                    iconSize: 88,
                  ),

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
                        if (about.headquarters(lang).isNotEmpty)
                          InfoKeyValueRow(
                            icon: Icons.location_on_outlined,
                            label: 'info_content.about.headquarters'.tr(),
                            value: about.headquarters(lang),
                            showDivider: true,
                          ),
                        if (about.email.isNotEmpty)
                          InfoKeyValueRow(
                            icon: Icons.email_outlined,
                            label: 'info_content.about.official_email'.tr(),
                            value: about.email,
                            showDivider: about.phone.isNotEmpty,
                          ),
                        if (about.phone.isNotEmpty)
                          InfoKeyValueRow(
                            icon: Icons.phone_outlined,
                            label: 'info_content.about.hotline'.tr(),
                            value: about.phone,
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
}
