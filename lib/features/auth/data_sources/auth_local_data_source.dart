import 'dart:convert';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/cache_helper.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> setRememberMe(bool enabled);
  bool getRememberMe();
  Future<void> saveUserSession(UserModel user);
  UserModel? getCachedUserSession();
  Future<void> clearUserSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final CacheHelper _cacheHelper;

  AuthLocalDataSourceImpl(this._cacheHelper);

  @override
  Future<void> setRememberMe(bool enabled) async {
    await _cacheHelper.saveData(
      key: AppConstants.prefsKeyRememberMe,
      value: enabled,
    );
  }

  @override
  bool getRememberMe() {
    return _cacheHelper.getBool(AppConstants.prefsKeyRememberMe) ?? false;
  }

  @override
  Future<void> saveUserSession(UserModel user) async {
    final jsonString = jsonEncode(user.toMap());
    await _cacheHelper.saveData(
      key: AppConstants.prefsKeyUserSession,
      value: jsonString,
    );
  }

  @override
  UserModel? getCachedUserSession() {
    final jsonString = _cacheHelper.getString(AppConstants.prefsKeyUserSession);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final map = jsonDecode(jsonString) as Map<String, dynamic>;
        return UserModel.fromMap(map);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearUserSession() async {
    await _cacheHelper.removeData(key: AppConstants.prefsKeyUserSession);
  }
}
