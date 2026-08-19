import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> setRememberMe(bool enabled);
  bool getRememberMe();
  Future<void> saveUserSession(UserModel user);
  UserModel? getCachedUserSession();
  Future<void> clearUserSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _prefs;

  AuthLocalDataSourceImpl(this._prefs);

  @override
  Future<void> setRememberMe(bool enabled) async {
    await _prefs.setBool(AppConstants.prefsKeyRememberMe, enabled);
  }

  @override
  bool getRememberMe() {
    return _prefs.getBool(AppConstants.prefsKeyRememberMe) ?? false;
  }

  @override
  Future<void> saveUserSession(UserModel user) async {
    final rawJson = jsonEncode(user.toMap());
    await _prefs.setString(AppConstants.prefsKeyUserSession, rawJson);
  }

  @override
  UserModel? getCachedUserSession() {
    final rawJson = _prefs.getString(AppConstants.prefsKeyUserSession);
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final map = jsonDecode(rawJson) as Map<String, dynamic>;
        return UserModel.fromMap(map);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearUserSession() async {
    await _prefs.remove(AppConstants.prefsKeyUserSession);
  }
}
