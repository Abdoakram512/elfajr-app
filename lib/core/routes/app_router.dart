import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/views/onboarding_view.dart';
import '../../features/splash/presentation/views/splash_view.dart';
import 'route_names.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Login Screen (Phase 5)'),
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.donorDashboard,
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Donor Dashboard (Phase 6)'),
          ),
        ),
      ),
    ],
  );
}
