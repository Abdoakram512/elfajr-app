import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:qout/core/constants/app_colors.dart';

import '../../../../app/service_locator.dart';
import '../../../../core/widgets/feedback/app_loading_indicator.dart';
import '../../../../core/widgets/feedback/alfajr_refresh_indicator.dart';
import '../models/faq_model.dart';
import '../view_models/info_cubit.dart';
import '../view_models/info_state.dart';

class FaqView extends StatelessWidget {
  const FaqView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<InfoCubit>(),
      child: const _FaqViewBody(),
    );
  }
}

class _FaqViewBody extends StatelessWidget {
  const _FaqViewBody();

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('info_content.faq.title'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<InfoCubit, InfoState>(
        builder: (context, state) {
          if (state.isLoading && state.faqs.isEmpty) {
            return const AppLoadingIndicator();
          }

          final cubit = context.read<InfoCubit>();
          final categories = state.availableFaqCategories(lang);
          final faqs = state.filteredFaqs(lang);

          return AlfajrRefreshIndicator(
            onRefresh: () => context.read<InfoCubit>().loadAllInfo(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // 1. Header description
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              const Icon(
                                Icons.help_outline_rounded,
                                color: AppColors.primary,
                                size: 28,
                              ),
                              const Gap(12),
                              Expanded(
                                child: Text(
                                  'info_content.faq.intro'.tr(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primaryDark,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(16),

                        // 2. Category Filter Chips
                        if (categories.length > 1)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: categories.map((cat) {
                                final isSelected =
                                    state.selectedFaqCategory == cat ||
                                    (cat == 'all' && (state.selectedFaqCategory == 'all' || state.selectedFaqCategory == 'الكل'));
                                final labelText = cat == 'all' ? 'info_content.faq.all'.tr() : cat;

                                return Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: ChoiceChip(
                                    label: Text(labelText),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        cubit.selectFaqCategory(cat);
                                      }
                                    },
                                    selectedColor: AppColors.primary,
                                    backgroundColor: Colors.white,
                                    labelStyle: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textSecondaryLight,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.borderLight,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // 3. FAQ Items List
                if (faqs.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'info_content.faq.empty'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = faqs[index];
                        return _buildFaqTile(item, index, lang);
                      }, childCount: faqs.length),
                    ),
                  ),

                const SliverToBoxAdapter(child: Gap(30)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFaqTile(FaqItemModel item, int index, String lang) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
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
        child: Theme(
          data: ThemeData().copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 6,
            ),
            childrenPadding: const EdgeInsets.only(
              left: 18,
              right: 18,
              bottom: 16,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.quiz_outlined,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            title: Text(
              item.question(lang),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
                height: 1.4,
              ),
            ),
            subtitle: item.category(lang).isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item.category(lang),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.accentDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : null,
            children: [
              const Divider(height: 1, color: AppColors.borderLight),
              const Gap(12),
              Text(
                item.answer(lang),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 60).ms, duration: 300.ms);
  }
}
