import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/service_locator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_names.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit(prefs: sl())..initApp(),
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
          context.go(RouteNames.donorDashboard);
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ambient Soft Glow in the Center (Static, Non-distracting)
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight.withValues(alpha: 0.08),
                ),
              ),

              // Central Clean Brand Identity
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Clean, Premium Emblem
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10875C), Color(0xFF0A5C3E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.volunteer_activism_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  )
                      .animate()
                      .scale(
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(duration: 500.ms),

                  const Gap(24),

                  // Brand Name (قوت)
                  Text(
                    'app_name'.tr(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 500.ms)
                      .slideY(begin: 0.2, end: 0, duration: 500.ms),

                  const Gap(8),

                  // Slogan / Tagline (Clean & Elegant)
                  Text(
                    'app_tagline'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 0.3,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 350.ms, duration: 500.ms)
                      .slideY(begin: 0.2, end: 0, duration: 500.ms),
                ],
              ),

              // Bottom Minimal Indicator
              Positioned(
                bottom: 48,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.accent.withValues(alpha: 0.8),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
