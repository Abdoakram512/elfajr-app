import 'package:flutter/material.dart';

abstract class AppConstants {
  static const String appName = 'مؤسسة الفجر الخيرية';
  static const String appNameEn = 'Al-Fajr Foundation';
  static const String appTagline = 'منظومة الإغاثة والمساعدات الرقمية المعتمدة';
  static const String appVersion = '1.0.0';

  static const String prefsKeyOnboardingCompleted = 'alfajr_onboarding_completed';
  static const String prefsKeyLocale = 'alfajr_locale';
  static const String prefsKeyThemeMode = 'alfajr_theme_mode';
  static const String prefsKeyRememberMe = 'alfajr_remember_me';
  static const String prefsKeyUserSession = 'alfajr_user_session_cache';
  static const String prefsKeyAuthToken = 'alfajr_auth_token';
  static const String prefsKeyUserRole = 'alfajr_user_role';

  // Locales
  static const Locale arabicLocale = Locale('ar');
  static const Locale englishLocale = Locale('en');
  static const String translationsPath = 'assets/translations';

  // Animation Durations
  static const Duration splashDuration = Duration(milliseconds: 2400);
  static const Duration pageTransitionDuration = Duration(milliseconds: 400);
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Layout & Spacing
  static const double defaultRadius = 16.0;
  static const double cardRadius = 20.0;
  static const double buttonHeight = 52.0;
  static const double inputHeight = 52.0;
  static const double horizontalPadding = 20.0;

  // Pagination & Limits
  static const int defaultPageSize = 20;
  static const int recentTransactionsLimit = 5;
}
