import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand Imperial Emerald & Forest Green Palette
  static const Color primary = Color(0xFF0A734D);
  static const Color primaryDark = Color(0xFF063A28);
  static const Color primaryLight = Color(0xFF22C55E);
  static const Color primarySubtle = Color(0xFFE6F5EF);

  // Warm Royal Amber & Gold Accent
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFDE68A);
  static const Color accentDark = Color(0xFFD97706);
  static const Color goldGlow = Color(0xFFFFD166);

  // Background & Surfaces - Light
  static const Color backgroundLight = Color(0xFFF8FAF9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Background & Surfaces - Dark
  static const Color backgroundDark = Color(0xFF081510);
  static const Color surfaceDark = Color(0xFF0F241C);
  static const Color cardDark = Color(0xFF163328);

  // Neutral / Text Colors - Light
  static const Color textPrimaryLight = Color(0xFF0F261D);
  static const Color textSecondaryLight = Color(0xFF436054);
  static const Color textMutedLight = Color(0xFF7E9A8E);
  static const Color borderLight = Color(0xFFE2EBE6);

  // Neutral / Text Colors - Dark
  static const Color textPrimaryDark = Color(0xFFF1F7F4);
  static const Color textSecondaryDark = Color(0xFF98B3A7);
  static const Color textMutedDark = Color(0xFF5D786D);
  static const Color borderDark = Color(0xFF1E3A2F);

  // Status & Feedback Colors
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFEA580C);
  static const Color info = Color(0xFF0284C7);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0A734D), Color(0xFF063A28)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF084830), Color(0xFF062E20), Color(0xFF041C13)],
    stops: [0.0, 0.55, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldAccentGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassBorderGradient = LinearGradient(
    colors: [Colors.white54, Colors.white12],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
