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
    await _cacheHelper.setRememberMe(enabled);
  }

  @override
  bool getRememberMe() {
    return _cacheHelper.getRememberMe();
  }

  @override
  Future<void> saveUserSession(UserModel user) async {
    await _cacheHelper.saveUserSession(user.toMap());
  }

  @override
  UserModel? getCachedUserSession() {
    final map = _cacheHelper.getCachedUserSession();
    if (map != null) {
      try {
        return UserModel.fromMap(map);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearUserSession() async {
    await _cacheHelper.clearUserSession();
  }
}
