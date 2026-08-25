abstract class RouteNames {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String roleSelection = '/role-selection';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // 3 Core Role Dashboards
  static const String beneficiaryDashboard = '/beneficiary-dashboard';
  static const String merchantDashboard = '/merchant-dashboard';
  static const String adminDashboard = '/admin-dashboard';

  // Informational & Support Pages (Dynamic from Firestore)
  static const String aboutUs = '/about-us';
  static const String faq = '/faq';
  static const String termsPrivacy = '/terms-privacy';
  static const String contactSupport = '/contact-support';
  static const String accountSuspended = '/account-suspended';
  static const String merchantPaymentReceipts = '/merchant-payment-receipts';
  static const String notifications = '/notifications';
}
