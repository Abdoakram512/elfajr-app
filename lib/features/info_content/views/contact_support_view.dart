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

class ContactSupportView extends StatelessWidget {
  const ContactSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<InfoCubit>(),
      child: const _ContactSupportViewBody(),
    );
  }
}

class _ContactSupportViewBody extends StatelessWidget {
  const _ContactSupportViewBody();

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('info_content.contact.title'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<InfoCubit, InfoState>(
        builder: (context, state) {
          if (state.isLoading && state.contactSupport == null) {
            return const AppLoadingIndicator();
          }

          final contact = state.contactSupport;
          if (contact == null) {
            return AppErrorStateWidget(
              errorMessage: state.errorMessage ?? 'info_content.contact.failed_to_load'.tr(),
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
                  // 1. Hero Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
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
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.headset_mic_rounded,
                            size: 38,
                            color: Colors.white,
                          ),
                        ),
                        const Gap(14),
                        Text(
                          'info_content.contact.hero_title'.tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (contact.workingHours(lang).isNotEmpty) ...[
                          const Gap(6),
                          Text(
                            'info_content.contact.working_hours_label'.tr(namedArgs: {'hours': contact.workingHours(lang)}),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),

                  const Gap(20),

                  // 2. Direct Channels
                  if (contact.hotline.isNotEmpty) ...[
                    _buildChannelCard(
                      icon: Icons.phone_in_talk_rounded,
                      title: 'info_content.contact.hotline_title'.tr(),
                      subtitle: 'info_content.contact.hotline_subtitle'.tr(),
                      value: contact.hotline,
                      color: AppColors.primary,
                    ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                    const Gap(12),
                  ],

                  if (contact.emergencyPhone.isNotEmpty) ...[
                    _buildChannelCard(
                      icon: Icons.support_agent_rounded,
                      title: 'info_content.contact.emergency_title'.tr(),
                      subtitle: 'info_content.contact.emergency_subtitle'.tr(),
                      value: contact.emergencyPhone,
                      color: AppColors.accentDark,
                    ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
                    const Gap(12),
                  ],

                  if (contact.supportEmail.isNotEmpty) ...[
                    _buildChannelCard(
                      icon: Icons.email_rounded,
                      title: 'info_content.contact.email_title'.tr(),
                      subtitle: 'info_content.contact.email_subtitle'.tr(),
                      value: contact.supportEmail,
                      color: AppColors.primaryDark,
                    ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
                    const Gap(12),
                  ],

                  if (contact.partnersEmail.isNotEmpty) ...[
                    _buildChannelCard(
                      icon: Icons.store_mall_directory_rounded,
                      title: 'info_content.contact.partners_title'.tr(),
                      subtitle: 'info_content.contact.partners_subtitle'.tr(),
                      value: contact.partnersEmail,
                      color: AppColors.primary,
                    ).animate().fadeIn(delay: 400.ms, duration: 300.ms),
                    const Gap(16),
                  ],

                  // 3. Location Address Card
                  if (contact.address(lang).isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primarySubtle,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const Gap(14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'info_content.contact.address_title'.tr(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  contact.address(lang),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondaryLight,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms, duration: 300.ms),

                  const Gap(24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChannelCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const Gap(2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const Gap(4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
