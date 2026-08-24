import 'package:flutter/material.dart';

/// Centralized Design System Colors and Gradients for Qout Application.
abstract class AppColors {
  // ── Brand Imperial Emerald & Forest Green Palette ─────────────────────────
  static const Color primary = Color(0xFF0A734D);
  static const Color primaryDark = Color(0xFF063A28);
  static const Color primaryLight = Color(0xFF22C55E);
  static const Color primarySubtle = Color(0xFFE6F5EF);

  // Emerald Shading
  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald200 = Color(0xFFA7F3D0);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);
  static const Color emerald800 = Color(0xFF065F46);
  static const Color emerald900 = Color(0xFF064E3B);

  // ── Warm Royal Amber & Gold Accent ─────────────────────────────────────────
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFDE68A);
  static const Color accentDark = Color(0xFFD97706);
  static const Color goldGlow = Color(0xFFFFD166);

  // Amber Shading
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber900 = Color(0xFF78350F);

  // ── Background & Surfaces - Light ──────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF8FAF9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // ── Background & Surfaces - Dark ───────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF081510);
  static const Color surfaceDark = Color(0xFF0F241C);
  static const Color cardDark = Color(0xFF163328);

  // ── Neutral Slate Colors ───────────────────────────────────────────────────
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // ── Neutral / Text Colors - Light ──────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF0F261D);
  static const Color textSecondaryLight = Color(0xFF436054);
  static const Color textMutedLight = Color(0xFF7E9A8E);
  static const Color borderLight = Color(0xFFE2EBE6);

  // ── Neutral / Text Colors - Dark ───────────────────────────────────────────
  static const Color textPrimaryDark = Color(0xFFF1F7F4);
  static const Color textSecondaryDark = Color(0xFF98B3A7);
  static const Color textMutedDark = Color(0xFF5D786D);
  static const Color borderDark = Color(0xFF1E3A2F);

  // ── Status & Feedback Colors ───────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFEA580C);
  static const Color info = Color(0xFF0284C7);

  // ── Payment Methods & Brand Tints ──────────────────────────────────────────
  static const Color instapayPurple = Color(0xFF7C3AED);
  static const Color instapayBg = Color(0xFFF5F3FF);

  static const Color vodafoneCashRed = Color(0xFFDC2626);
  static const Color vodafoneCashBg = Color(0xFFFEF2F2);

  static const Color bankTransferBlue = Color(0xFF2563EB);
  static const Color bankTransferBg = Color(0xFFEFF6FF);

  static const Color cashGreen = Color(0xFF0A734D);
  static const Color cashBg = Color(0xFFECFDF5);

  // ── Onboarding Accent Tints ────────────────────────────────────────────────
  static const Color onboardingEmeraldStart = Color(0xFFE6F5EF);
  static const Color onboardingEmeraldEnd = Color(0xFFC7EBDD);
  static const Color onboardingAmberStart = Color(0xFFFEF3C7);
  static const Color onboardingAmberEnd = Color(0xFFFDE68A);
  static const Color onboardingBlueStart = Color(0xFFE0F2FE);
  static const Color onboardingBlueEnd = Color(0xFFBAE6FD);
  static const Color onboardingDotInactive = Color(0xFFD1D5DB);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0A734D), Color(0xFF063A28)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF0A6847), Color(0xFF063A28), Color(0xFF042419)],
    stops: [0.0, 0.55, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient receiptsHeaderGradient = LinearGradient(
    colors: [Color(0xFF063A28), Color(0xFF0A734D), Color(0xFF0F8A5D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
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
