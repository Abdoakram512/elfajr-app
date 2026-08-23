import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/service_locator.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SplashCubit>()..initApp(),
      child: const _SplashViewBody(),
    );
  }
}

class _SplashViewBody extends StatelessWidget {
  const _SplashViewBody();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashNavigateToOnboarding) {
          context.go(RouteNames.onboarding);
        } else if (state is SplashNavigateToLogin) {
          context.go(RouteNames.login);
        } else if (state is SplashNavigateToDashboard) {
          switch (state.role) {
            case 'suspended':
              context.go(RouteNames.accountSuspended);
              break;
            case 'admin':
              context.go(RouteNames.adminDashboard);
              break;
            case 'merchant':
              context.go(RouteNames.merchantDashboard);
              break;
            case 'beneficiary':
            default:
              context.go(RouteNames.beneficiaryDashboard);
              break;
          }
        }

      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A6847), Color(0xFF063A28), Color(0xFF042419)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: RepaintBoundary(
                child: Column(
                  children: [
                    // Optical Center Top Spacer (Places brand at the ideal 40-42% vertical eye-line)
                    const Spacer(flex: 5),

                  // 1. Central Brand Emblem
                  Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accentLight.withValues(alpha: 0.85),
                            width: 2.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: AppColors.goldGlow.withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 36,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(52),
                          child: Image.asset(
                            AppAssets.appIcon,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.primary,
                              child: const Icon(
                                Icons.volunteer_activism_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .scale(duration: 500.ms, curve: Curves.easeOutBack)
                      .fadeIn(duration: 400.ms),

                  const Gap(20),

                  // 2. Brand Name Typography
                  Text(
                        'app_name'.tr(),
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 150.ms, duration: 450.ms)
                      .slideY(begin: 0.2, end: 0, duration: 450.ms),

                  const Gap(8),

                  // 3. Slogan / Tagline
                  Text(
                        'app_tagline'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.8),
                          letterSpacing: 0.3,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 250.ms, duration: 450.ms)
                      .slideY(begin: 0.2, end: 0, duration: 450.ms),

                  // Bottom Balance Spacer
                  const Spacer(flex: 4),

                  // 4. Elegant Staggered 3-Dot Loading Pulse
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLoadingDot(delayMs: 0),
                      const Gap(8),
                      _buildLoadingDot(delayMs: 180),
                      const Gap(8),
                      _buildLoadingDot(delayMs: 360),
                    ],
                  ).animate().fadeIn(delay: 400.ms, duration: 350.ms),

                  const Gap(32),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildLoadingDot({required int delayMs}) {
    return Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentLight,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(0.7, 0.7),
          end: const Offset(1.3, 1.3),
          duration: 600.ms,
          delay: delayMs.ms,
          curve: Curves.easeInOut,
        )
        .fade(
          begin: 0.3,
          end: 1.0,
          duration: 600.ms,
          delay: delayMs.ms,
          curve: Curves.easeInOut,
        );
  }
}
