import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand Emerald & Forest Green Palette
  static const Color primary = Color(0xFF0A6847);
  static const Color primaryDark = Color(0xFF064831);
  static const Color primaryLight = Color(0xFF22C55E);
  static const Color primarySubtle = Color(0xFFE8F5E9);

  // Warm Amber & Gold Accent
  static const Color accent = Color(0xFFF3A712);
  static const Color accentLight = Color(0xFFFDE68A);
  static const Color accentDark = Color(0xFFD97706);

  // Background & Surfaces - Light
  static const Color backgroundLight = Color(0xFFF8FAF9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Background & Surfaces - Dark
  static const Color backgroundDark = Color(0xFF0B1914);
  static const Color surfaceDark = Color(0xFF13251E);
  static const Color cardDark = Color(0xFF1A332B);

  // Neutral / Text Colors - Light
  static const Color textPrimaryLight = Color(0xFF132A22);
  static const Color textSecondaryLight = Color(0xFF4B6358);
  static const Color textMutedLight = Color(0xFF8DA399);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Neutral / Text Colors - Dark
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);
  static const Color borderDark = Color(0xFF1E3A2F);

  // Status & Feedback Colors
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFEA580C);
  static const Color info = Color(0xFF0284C7);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0A6847), Color(0xFF064831)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF0A6847), Color(0xFF0B1914)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldAccentGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
