import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

/// Centralized Formatters for localized Date, Time, and Numbers.
/// Supports 12-hour formatting (AM/PM and ص/م) and handles bidirectional text (RTL/LTR).
class AppFormatters {
  AppFormatters._();

  // Legacy Formatters for backward compatibility
  static final DateFormat fullDate = DateFormat('yyyy/MM/dd • hh:mm a', 'ar');
  static final DateFormat dateOnly = DateFormat('yyyy/MM/dd');
  static final DateFormat timeOnly = DateFormat('hh:mm a');
  static final DateFormat arabicDate = DateFormat('dd MMMM yyyy', 'ar');

  // Currency & Number Formatters
  static final NumberFormat currencyEGP = NumberFormat('#,##0.00', 'ar');
  static final NumberFormat integerNumber = NumberFormat('#,##0', 'ar');

  // Common RegEx Patterns
  static final RegExp whitespaceRegex = RegExp(r'\s+');
  static final RegExp nonNumericRegex = RegExp(r'\D');

  /// Resolves effective language code ('ar' or 'en')
  static String resolveLocale(BuildContext? context, [String? explicitLocale]) {
    if (explicitLocale != null && explicitLocale.isNotEmpty) {
      return explicitLocale.toLowerCase().startsWith('en') ? 'en' : 'ar';
    }
    if (context != null) {
      try {
        final lang = context.locale.languageCode.toLowerCase();
        return lang.startsWith('en') ? 'en' : 'ar';
      } catch (_) {}
    }
    return Intl.defaultLocale?.toLowerCase().startsWith('en') == true
        ? 'en'
        : 'ar';
  }

  /// Formats date and time in 12-hour format with proper localization and RTL alignment.
  /// Example (AR): `2026/08/24 • 10:41 م`
  /// Example (EN): `2026-08-24 • 10:41 PM`
  static String formatDateTime(
    DateTime date, {
    BuildContext? context,
    String? localeCode,
  }) {
    final local = date.toLocal();
    final lang = resolveLocale(context, localeCode);
    if (lang == 'ar') {
      final formatted = DateFormat('yyyy/MM/dd • hh:mm a', 'ar').format(local);
      // \u200F is the Right-to-Left Mark (RLM) preventing text flip
      return '\u200F$formatted';
    } else {
      return DateFormat('yyyy-MM-dd • hh:mm a', 'en').format(local);
    }
  }

  /// Formats date only according to locale.
  /// Example (AR): `2026/08/24`
  /// Example (EN): `2026-08-24`
  static String formatDate(
    DateTime date, {
    BuildContext? context,
    String? localeCode,
  }) {
    final local = date.toLocal();
    final lang = resolveLocale(context, localeCode);
    if (lang == 'ar') {
      return DateFormat('yyyy/MM/dd', 'ar').format(local);
    } else {
      return DateFormat('yyyy-MM-dd', 'en').format(local);
    }
  }

  /// Formats time in 12-hour format only (e.g. `10:41 م` or `10:41 PM`).
  static String formatTime12(
    DateTime date, {
    BuildContext? context,
    String? localeCode,
  }) {
    final local = date.toLocal();
    final lang = resolveLocale(context, localeCode);
    if (lang == 'ar') {
      return '\u200F${DateFormat('hh:mm a', 'ar').format(local)}';
    } else {
      return DateFormat('hh:mm a', 'en').format(local);
    }
  }

  /// Formats month and year according to locale (e.g. `أغسطس 2026` or `August 2026`).
  static String formatMonthYear(
    DateTime date, {
    BuildContext? context,
    String? localeCode,
  }) {
    final local = date.toLocal();
    final lang = resolveLocale(context, localeCode);
    return DateFormat('MMMM yyyy', lang).format(local);
  }

  /// Formats date in written format (e.g. `24 أغسطس 2026` or `24 August 2026`).
  static String formatFullWrittenDate(
    DateTime date, {
    BuildContext? context,
    String? localeCode,
  }) {
    final local = date.toLocal();
    final lang = resolveLocale(context, localeCode);
    if (lang == 'ar') {
      return DateFormat('dd MMMM yyyy', 'ar').format(local);
    } else {
      return DateFormat('dd MMMM yyyy', 'en').format(local);
    }
  }

  /// Formats currency with Egyptian Pound symbol
  static String formatEGP(num amount) {
    return '${currencyEGP.format(amount)} ج.م';
  }

  /// Cleans national ID / Passport numbers (removes whitespace, forces uppercase)
  static String cleanId(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    return raw.replaceAll(whitespaceRegex, '').toUpperCase();
  }
}
