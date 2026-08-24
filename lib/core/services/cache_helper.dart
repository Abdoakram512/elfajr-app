import 'package:shared_preferences/shared_preferences.dart';

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
}
