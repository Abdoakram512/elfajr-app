import 'package:cloud_firestore/cloud_firestore.dart';

/// Centralized, high-performance parsing utilities for Firestore models and data sources.
/// Eliminates redundant `_parseDate`, `_parseDouble`, `_parseInt` boilerplates across models.
abstract class FirebaseParserUtils {
  /// Parses dynamic value to [DateTime], handling [Timestamp], [DateTime], [String] or returning [fallback].
  static DateTime parseDate(dynamic val, {DateTime? fallback}) {
    if (val == null) return fallback ?? DateTime.now();
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is String) {
      return DateTime.tryParse(val.trim()) ?? (fallback ?? DateTime.now());
    }
    return fallback ?? DateTime.now();
  }

  /// Parses nullable dynamic value to [DateTime] or null.
  static DateTime? parseNullableDate(dynamic val) {
    if (val == null) return null;
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is String) return DateTime.tryParse(val.trim());
    return null;
  }

  /// Parses dynamic value to [double], handling [num], [String], or returning [fallback].
  static double parseDouble(dynamic val, {double fallback = 0.0}) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val.trim()) ?? fallback;
    return fallback;
  }

  /// Parses dynamic value to [double?] or null.
  static double? parseNullableDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val.trim());
    return null;
  }

  /// Parses dynamic value to [int], handling [num], [String], or returning [fallback].
  static int parseInt(dynamic val, {int fallback = 0}) {
    if (val == null) return fallback;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val.trim()) ?? fallback;
    return fallback;
  }

  /// Parses dynamic value to [int?] or null.
  static int? parseNullableInt(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val.trim());
    return null;
  }

  /// Parses dynamic value to [bool], handling [bool], [String], [num] or returning [fallback].
  static bool parseBool(dynamic val, {bool fallback = false}) {
    if (val == null) return fallback;
    if (val is bool) return val;
    if (val is num) return val != 0;
    if (val is String) {
      final normalized = val.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return fallback;
  }
}
