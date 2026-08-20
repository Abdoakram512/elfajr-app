import 'package:go_router/go_router.dart';

import '../../features/admin/views/admin_main_view.dart';
import '../../features/auth/models/user_role.dart';
import '../../features/auth/views/forgot_password_view.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/auth/views/role_selection_view.dart';
import '../../features/beneficiary/views/beneficiary_main_view.dart';
import '../../features/info_content/views/about_us_view.dart';
import '../../features/info_content/views/contact_support_view.dart';
import '../../features/info_content/views/faq_view.dart';
import '../../features/info_content/views/terms_privacy_view.dart';
import '../../features/auth/views/account_suspended_view.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/merchant/views/merchant_main_view.dart';
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
        path: RouteNames.roleSelection,
        builder: (context, state) => const RoleSelectionView(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) {
          final role = state.extra is UserRole
              ? state.extra as UserRole
              : UserRole.beneficiary;
          return RegisterView(initialRole: role);
        },
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordView(),
      ),
      GoRoute(
        path: RouteNames.accountSuspended,
        builder: (context, state) {
          final user = state.extra is UserModel ? state.extra as UserModel : null;
          return AccountSuspendedView(user: user);
        },
      ),

      // 3 Core Role-Based Dashboards
      GoRoute(
        path: RouteNames.beneficiaryDashboard,
        builder: (context, state) => const BeneficiaryMainView(),
      ),
      GoRoute(
        path: RouteNames.merchantDashboard,
        builder: (context, state) => const MerchantMainView(),
      ),
      GoRoute(
        path: RouteNames.adminDashboard,
        builder: (context, state) => const AdminMainView(),
      ),

      // Dynamic Informational & Support Pages
      GoRoute(
        path: RouteNames.aboutUs,
        builder: (context, state) => const AboutUsView(),
      ),
      GoRoute(
        path: RouteNames.faq,
        builder: (context, state) => const FaqView(),
      ),
      GoRoute(
        path: RouteNames.termsPrivacy,
        builder: (context, state) => const TermsPrivacyView(),
      ),
      GoRoute(
        path: RouteNames.contactSupport,
        builder: (context, state) => const ContactSupportView(),
      ),
    ],
  );
}

