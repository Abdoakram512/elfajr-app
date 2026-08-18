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
            gradient: AppColors.splashGradient,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Concentric Ambient Pulsing Halos (Background Depth)
              _buildPulsingHalo(
                size: 380,
                color: AppColors.primaryLight.withValues(alpha: 0.04),
                delay: 0,
              ),
              _buildPulsingHalo(
                size: 280,
                color: AppColors.accent.withValues(alpha: 0.06),
                delay: 300,
              ),
              _buildPulsingHalo(
                size: 190,
                color: AppColors.primaryLight.withValues(alpha: 0.10),
                delay: 600,
              ),

              // 2. Central Brand Composition
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 3D Glassmorphic Emblem with Metallic Gold Border
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F8F64), Color(0xFF074E36), Color(0xFF042F20)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: AppColors.accentLight.withValues(alpha: 0.75),
                        width: 2.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryLight.withValues(alpha: 0.35),
                          blurRadius: 40,
                          spreadRadius: 4,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.25),
                          blurRadius: 60,
                          spreadRadius: 8,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.volunteer_activism_rounded,
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .scale(
                        duration: 800.ms,
                        curve: Curves.easeOutBack,
                      )
                      .then()
                      .shimmer(
                        duration: 1800.ms,
                        color: AppColors.accentLight.withValues(alpha: 0.5),
                      ),

                  const Gap(32),

                  // Brand Name Typography with Gold Sheen Effect
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Color(0xFFFFF7ED), Color(0xFFFDE68A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    child: Text(
                      'app_name'.tr(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: Colors.white,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideY(begin: 0.25, end: 0, duration: 600.ms),

                  const Gap(16),

                  // Frosted Glass Tagline Capsule
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          'app_tagline'.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(begin: 0.25, end: 0, duration: 600.ms),
                ],
              ),

              // 3. Fluid Slim Progress Indicator at Bottom
              Positioned(
                bottom: 54,
                child: Column(
                  children: [
                    SizedBox(
                      width: 140,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          minHeight: 2.5,
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.accent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPulsingHalo({
    required double size,
    required Color color,
    required int delay,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1.08, 1.08),
          duration: 2200.ms,
          delay: delay.ms,
          curve: Curves.easeInOut,
        );
  }
}
