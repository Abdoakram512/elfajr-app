import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

abstract class AuthLocalDataSource {
  Future<void> setRememberMe(bool enabled);
  bool getRememberMe();
  Future<void> saveEmail(String email);
  String? getSavedEmail();
  Future<void> clearSavedEmail();
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
    return _prefs.getBool(AppConstants.prefsKeyRememberMe) ?? true;
  }

  @override
  Future<void> saveEmail(String email) async {
    await _prefs.setString(AppConstants.prefsKeySavedEmail, email);
  }

  @override
  String? getSavedEmail() {
    return _prefs.getString(AppConstants.prefsKeySavedEmail);
  }

  @override
  Future<void> clearSavedEmail() async {
    await _prefs.remove(AppConstants.prefsKeySavedEmail);
  }
}
