import 'package:flutter/material.dart';

abstract class AppConstants {
  static const String appName = 'Qout';
  static const String prefsKeyOnboardingCompleted = 'onboarding_completed';
  static const String prefsKeyLocale = 'app_locale';
  static const String prefsKeyThemeMode = 'app_theme_mode';

  // Locales
  static const Locale arabicLocale = Locale('ar');
  static const Locale englishLocale = Locale('en');
  static const String translationsPath = 'assets/translations';

  // Animation Durations
  static const Duration splashDuration = Duration(milliseconds: 2400);
  static const Duration pageTransitionDuration = Duration(milliseconds: 400);
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
}
