import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../app/service_locator.dart';
import '../../features/admin/views/admin_main_view.dart';
import '../../features/auth/models/user_role.dart';
import '../../features/auth/view_models/auth_cubit.dart';
import '../../features/auth/views/forgot_password_view.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/auth/views/role_selection_view.dart';
import '../../features/beneficiary/views/beneficiary_main_view.dart';
import '../../features/donor/views/donor_main_view.dart';
import '../../features/merchant/views/merchant_main_view.dart';
import '../../features/onboarding/presentation/views/onboarding_view.dart';
import '../../features/splash/presentation/views/splash_view.dart';
import '../../features/volunteer/views/volunteer_main_view.dart';
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
        path: RouteNames.roleSelection,
        builder: (context, state) => const RoleSelectionView(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const LoginView(),
        ),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) {
          final role = state.extra is UserRole
              ? state.extra as UserRole
              : UserRole.donor;
          return BlocProvider(
            create: (_) => sl<AuthCubit>(),
            child: RegisterView(initialRole: role),
          );
        },
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const ForgotPasswordView(),
        ),
      ),

      // Role-Based Dashboards
      GoRoute(
        path: RouteNames.donorDashboard,
        builder: (context, state) => const DonorMainView(),
      ),
      GoRoute(
        path: RouteNames.beneficiaryDashboard,
        builder: (context, state) => const BeneficiaryMainView(),
      ),
      GoRoute(
        path: RouteNames.volunteerDashboard,
        builder: (context, state) => const VolunteerMainView(),
      ),
      GoRoute(
        path: RouteNames.merchantDashboard,
        builder: (context, state) => const MerchantMainView(),
      ),
      GoRoute(
        path: RouteNames.adminDashboard,
        builder: (context, state) => const AdminMainView(),
      ),
    ],
  );
}
