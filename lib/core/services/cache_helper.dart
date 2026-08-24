import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Centralized Cache & Local Storage Helper
/// Encapsulates SharedPreferences with type-safe operations, error-handling,
/// and dedicated domain convenience helpers.
class CacheHelper {
  CacheHelper._internal();
  static final CacheHelper instance = CacheHelper._internal();

  SharedPreferences? _prefs;

  /// Initialize CacheHelper with SharedPreferences instance
  Future<void> init([SharedPreferences? sharedPreferences]) async {
    _prefs = sharedPreferences ?? await SharedPreferences.getInstance();
  }

  SharedPreferences get _safePrefs {
    if (_prefs == null) {
      throw StateError(
        'CacheHelper has not been initialized. Call CacheHelper.instance.init() first.',
      );
    }
    return _prefs!;
  }

  // ── Generic CRUD Operations ────────────────────────────────────────────────

  /// Save dynamic primitive data (`String`, `int`, `double`, `bool`, `List<String>`)
  Future<bool> saveData({
    required String key,
    required dynamic value,
  }) async {
    try {
      if (value is String) return await _safePrefs.setString(key, value);
      if (value is bool) return await _safePrefs.setBool(key, value);
      if (value is int) return await _safePrefs.setInt(key, value);
      if (value is double) return await _safePrefs.setDouble(key, value);
      if (value is List<String>) return await _safePrefs.setStringList(key, value);
      if (value is Map || value is List) {
        return await _safePrefs.setString(key, jsonEncode(value));
      }
      return false;
    } catch (e) {
      debugPrint('CacheHelper.saveData error for key "$key": $e');
      return false;
    }
  }

  /// Retrieve dynamic data by key
  dynamic getData({required String key}) {
    try {
      return _safePrefs.get(key);
    } catch (e) {
      debugPrint('CacheHelper.getData error for key "$key": $e');
      return null;
    }
  }

  String? getString(String key) => _safePrefs.getString(key);
  bool? getBool(String key) => _safePrefs.getBool(key);
  int? getInt(String key) => _safePrefs.getInt(key);
  double? getDouble(String key) => _safePrefs.getDouble(key);
  List<String>? getStringList(String key) => _safePrefs.getStringList(key);

  /// Check if a key exists in cache
  bool containsKey(String key) => _safePrefs.containsKey(key);

  /// Remove a specific key from cache
  Future<bool> removeData({required String key}) async {
    try {
      return await _safePrefs.remove(key);
    } catch (e) {
      debugPrint('CacheHelper.removeData error for key "$key": $e');
      return false;
    }
  }

  /// Clear all cached data
  Future<bool> clearAll() async {
    try {
      return await _safePrefs.clear();
    } catch (e) {
      debugPrint('CacheHelper.clearAll error: $e');
      return false;
    }
  }

  // ── Domain-Specific Convenience Methods ────────────────────────────────────

  /// Check if user has finished onboarding
  bool isOnboardingCompleted() {
    return _safePrefs.getBool(AppConstants.prefsKeyOnboardingCompleted) ?? false;
  }

  /// Mark onboarding as completed
  Future<bool> setOnboardingCompleted([bool completed = true]) async {
    return await saveData(
      key: AppConstants.prefsKeyOnboardingCompleted,
      value: completed,
    );
  }

  /// Check if remember me is enabled
  bool getRememberMe() {
    return _safePrefs.getBool(AppConstants.prefsKeyRememberMe) ?? false;
  }

  /// Save remember me preference
  Future<bool> setRememberMe(bool enabled) async {
    return await saveData(
      key: AppConstants.prefsKeyRememberMe,
      value: enabled,
    );
  }

  /// Save user session JSON
  Future<bool> saveUserSession(Map<String, dynamic> userMap) async {
    return await saveData(
      key: AppConstants.prefsKeyUserSession,
      value: jsonEncode(userMap),
    );
  }

  /// Retrieve cached user session JSON Map
  Map<String, dynamic>? getCachedUserSession() {
    final raw = getString(AppConstants.prefsKeyUserSession);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('CacheHelper.getCachedUserSession error: $e');
      return null;
    }
  }

  /// Clear cached user session
  Future<bool> clearUserSession() async {
    return await removeData(key: AppConstants.prefsKeyUserSession);
  }
}
