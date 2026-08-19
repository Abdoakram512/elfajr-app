import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../app/service_locator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/widgets/primary_button.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/floating_chip_widget.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingCubit(prefs: sl()),
      child: const _OnboardingViewBody(),
    );
  }
}

class _OnboardingViewBody extends StatefulWidget {
  const _OnboardingViewBody();

  @override
  State<_OnboardingViewBody> createState() => _OnboardingViewBodyState();
}

class _OnboardingViewBodyState extends State<_OnboardingViewBody> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final cubit = context.read<OnboardingCubit>();

    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingCompleted) {
          context.go(RouteNames.roleSelection);
        }
      },
      builder: (context, state) {
        final currentPage = state.currentPage;
        final isLastPage = currentPage == 2;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: SafeArea(
            child: Column(
              children: [
                // 1. Top Navigation Bar (Language Switcher Pill & Skip Button)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Frosted Glass Language Toggle
                      InkWell(
                        onTap: () {
                          final newLocale = isArabic
                              ? AppConstants.englishLocale
                              : AppConstants.arabicLocale;
                          context.setLocale(newLocale);
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySubtle,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.language_rounded,
                                  size: 15,
                                  color: AppColors.primary,
                                ),
                              ),
                              const Gap(8),
                              Text(
                                isArabic ? 'English' : 'العربية',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Skip Button
                      if (!isLastPage)
                        TextButton(
                          onPressed: () => cubit.completeOnboarding(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'common.skip'.tr(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),

                // 2. Interactive Carousel PageView
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: cubit.onPageChanged,
                    children: [
                      // Slide 1: Donor Experience
                      _OnboardingSlide(
                        icon: Icons.favorite_rounded,
                        accentColor: AppColors.primary,
                        gradientColors: const [
                          Color(0xFFE6F5EF),
                          Color(0xFFC7EBDD),
                        ],
                        titleKey: 'onboarding.title_1',
                        descKey: 'onboarding.desc_1',
                        chip1Text: 'onboarding.chip_transparency'.tr(),
                        chip1Icon: Icons.verified_rounded,
                        chip2Text: 'onboarding.chip_impact'.tr(),
                        chip2Icon: Icons.trending_up_rounded,
                      ),

                      // Slide 2: Beneficiary Dignity
                      _OnboardingSlide(
                        icon: Icons.shield_rounded,
                        accentColor: AppColors.accentDark,
                        gradientColors: const [
                          Color(0xFFFEF3C7),
                          Color(0xFFFDE68A),
                        ],
                        titleKey: 'onboarding.title_2',
                        descKey: 'onboarding.desc_2',
                        chip1Text: 'onboarding.chip_privacy'.tr(),
                        chip1Icon: Icons.lock_outline_rounded,
                        chip2Text: 'onboarding.chip_dignity'.tr(),
                        chip2Icon: Icons.volunteer_activism_rounded,
                      ),

                      // Slide 3: Volunteer Impact
                      _OnboardingSlide(
                        icon: Icons.groups_rounded,
                        accentColor: const Color(0xFF0284C7),
                        gradientColors: const [
                          Color(0xFFE0F2FE),
                          Color(0xFFBAE6FD),
                        ],
                        titleKey: 'onboarding.title_3',
                        descKey: 'onboarding.desc_3',
                        chip1Text: 'onboarding.chip_field'.tr(),
                        chip1Icon: Icons.location_on_rounded,
                        chip2Text: 'onboarding.chip_community'.tr(),
                        chip2Icon: Icons.handshake_rounded,
                      ),
                    ],
                  ),
                ),

                // 3. Bottom Indicator & Dynamic Call to Action
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      // Expanding Dots Indicator
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: 3,
                        effect: ExpandingDotsEffect(
                          activeDotColor: isLastPage
                              ? AppColors.accent
                              : AppColors.primary,
                          dotColor: const Color(0xFFD1D5DB),
                          dotHeight: 8,
                          dotWidth: 8,
                          expansionFactor: 4,
                          spacing: 6,
                        ),
                      ),

                      const Gap(28),

                      // Primary Call-to-Action Button with Pulse Animation on Last Step
                      PrimaryButton(
                        text: (isLastPage
                                ? 'common.get_started'
                                : 'common.next')
                            .tr(),
                        trailingIcon: Icons.arrow_forward_rounded,
                        onPressed: () {
                          if (isLastPage) {
                            cubit.completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: AppConstants.pageTransitionDuration,
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final List<Color> gradientColors;
  final String titleKey;
  final String descKey;
  final String chip1Text;
  final IconData chip1Icon;
  final String chip2Text;
  final IconData chip2Icon;

  const _OnboardingSlide({
    required this.icon,
    required this.accentColor,
    required this.gradientColors,
    required this.titleKey,
    required this.descKey,
    required this.chip1Text,
    required this.chip1Icon,
    required this.chip2Text,
    required this.chip2Icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 3D Hero Composition with Floating Chips
          SizedBox(
            height: 280,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Glowing Background Outer Aura
                Container(
                      width: 230,
                      height: 230,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.22),
                            blurRadius: 36,
                            spreadRadius: 4,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 124,
                          height: 124,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(icon, size: 58, color: accentColor),
                        ),
                      ),
                    )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.easeOutBack)
                    .fadeIn(duration: 500.ms),

                // Top-Right Floating Chip
                Positioned(
                  top: 16,
                  right: 12,
                  child: FloatingChipWidget(
                    text: chip1Text,
                    icon: chip1Icon,
                    accentColor: accentColor,
                    animationDelay: 200,
                    isLeft: false,
                  ),
                ),

                // Bottom-Left Floating Chip
                Positioned(
                  bottom: 16,
                  left: 12,
                  child: FloatingChipWidget(
                    text: chip2Text,
                    icon: chip2Icon,
                    accentColor: accentColor,
                    animationDelay: 400,
                    isLeft: true,
                  ),
                ),
              ],
            ),
          ),

          const Gap(28),

          // Slide Title
          Text(
                titleKey.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryLight,
                  letterSpacing: -0.3,
                ),
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.15, end: 0, duration: 400.ms),

          const Gap(12),

          // Slide Description
          Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  descKey.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideY(begin: 0.15, end: 0, duration: 400.ms),
        ],
      ),
    );
  }
}
