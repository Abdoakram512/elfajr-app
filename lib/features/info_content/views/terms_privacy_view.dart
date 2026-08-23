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

class TermsPrivacyView extends StatelessWidget {
  const TermsPrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<InfoCubit>(),
      child: const _TermsPrivacyViewBody(),
    );
  }
}

class _TermsPrivacyViewBody extends StatelessWidget {
  const _TermsPrivacyViewBody();

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: Text('info_content.terms.title'.tr()),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondaryLight,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(text: 'info_content.terms.tab_terms'.tr()),
              Tab(text: 'info_content.terms.tab_privacy'.tr()),
            ],
          ),
        ),
        body: BlocBuilder<InfoCubit, InfoState>(
          builder: (context, state) {
            if (state.isLoading && state.termsPrivacy == null) {
              return const AppLoadingIndicator();
            }

            final data = state.termsPrivacy;
            if (data == null) {
              return AppErrorStateWidget(
                errorMessage: state.errorMessage ?? 'info_content.terms.failed_to_load'.tr(),
                onRetry: () => context.read<InfoCubit>().loadAllInfo(),
              );
            }

            return TabBarView(
              children: [
                // 1. Terms Tab
                _buildListTab(
                  context: context,
                  icon: Icons.gavel_rounded,
                  title: data.termsTitle(lang),
                  items: data.termsList(lang),
                  lastUpdated: data.lastUpdated(lang),
                ),

                // 2. Privacy Tab
                _buildListTab(
                  context: context,
                  icon: Icons.security_rounded,
                  title: data.privacyTitle(lang),
                  items: data.privacyList(lang),
                  lastUpdated: data.lastUpdated(lang),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildListTab({
    required BuildContext context,
    required IconData icon,
    required String title,
    required List<String> items,
    required String lastUpdated,
  }) {
    return AlfajrRefreshIndicator(
      onRefresh: () => context.read<InfoCubit>().loadAllInfo(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 28, color: AppColors.primary),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        if (lastUpdated.isNotEmpty) ...[
                          const Gap(2),
                          Text(
                            'info_content.terms.last_updated_label'.tr(namedArgs: {'date': lastUpdated}),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            const Gap(20),

            // Policy items
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'info_content.terms.empty'.tr(),
                    style: const TextStyle(color: AppColors.textSecondaryLight),
                  ),
                ),
              )
            else
              ...items.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final text = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$idx',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const Gap(14),
                      Expanded(
                        child: Text(
                          text,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: AppColors.textPrimaryLight,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const Gap(24),
          ],
        ),
      ),
    );
  }
}
