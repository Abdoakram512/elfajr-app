import 'package:intl/intl.dart';

/// Centralized Singleton Formatters to reduce Garbage Collection (GC) pressure
/// and prevent repeated object allocations inside Flutter build() methods.
class AppFormatters {
  AppFormatters._();

  // Date & Time Formatters
  static final DateFormat fullDate = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat dateOnly = DateFormat('yyyy-MM-dd');
  static final DateFormat timeOnly = DateFormat('HH:mm');
  static final DateFormat arabicDate = DateFormat('dd MMMM yyyy', 'ar');

  // Currency & Number Formatters
  static final NumberFormat currencyEGP = NumberFormat('#,##0.00', 'ar');
  static final NumberFormat integerNumber = NumberFormat('#,##0', 'ar');

  // Common RegEx Patterns
  static final RegExp whitespaceRegex = RegExp(r'\s+');
  static final RegExp nonNumericRegex = RegExp(r'\D');

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
