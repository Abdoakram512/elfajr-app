import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class CacheHelper {
  CacheHelper._();
  static final CacheHelper instance = CacheHelper._();

  late SharedPreferences _prefs;

  Future<void> init([SharedPreferences? sharedPreferences]) async {
    _prefs = sharedPreferences ?? await SharedPreferences.getInstance();
  }

  // ── Generic Storage Operations ─────────────────────────────────────────────

  Future<bool> saveData({required String key, required dynamic value}) async {
    if (value is String) return _prefs.setString(key, value);
    if (value is bool) return _prefs.setBool(key, value);
    if (value is int) return _prefs.setInt(key, value);
    if (value is double) return _prefs.setDouble(key, value);
    if (value is List<String>) return _prefs.setStringList(key, value);
    if (value is Map || value is List) return _prefs.setString(key, jsonEncode(value));
    return false;
  }

  dynamic getData({required String key}) => _prefs.get(key);

  String? getString(String key) => _prefs.getString(key);
  bool? getBool(String key) => _prefs.getBool(key);
  int? getInt(String key) => _prefs.getInt(key);
  double? getDouble(String key) => _prefs.getDouble(key);
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  bool containsKey(String key) => _prefs.containsKey(key);
  Future<bool> removeData({required String key}) => _prefs.remove(key);
  Future<bool> clearAll() => _prefs.clear();

  // ── App Specific Convenience Helpers ───────────────────────────────────────

  bool isOnboardingCompleted() =>
      _prefs.getBool(AppConstants.prefsKeyOnboardingCompleted) ?? false;

  Future<bool> setOnboardingCompleted([bool value = true]) =>
      saveData(key: AppConstants.prefsKeyOnboardingCompleted, value: value);

  bool getRememberMe() =>
      _prefs.getBool(AppConstants.prefsKeyRememberMe) ?? false;

  Future<bool> setRememberMe(bool value) =>
      saveData(key: AppConstants.prefsKeyRememberMe, value: value);

  Future<bool> saveUserSession(Map<String, dynamic> userMap) =>
      saveData(key: AppConstants.prefsKeyUserSession, value: jsonEncode(userMap));

  Map<String, dynamic>? getCachedUserSession() {
    final raw = getString(AppConstants.prefsKeyUserSession);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> clearUserSession() =>
      removeData(key: AppConstants.prefsKeyUserSession);
}
