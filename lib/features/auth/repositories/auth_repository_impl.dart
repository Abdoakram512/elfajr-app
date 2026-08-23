import '../data_sources/auth_local_data_source.dart';
import '../data_sources/auth_remote_data_source.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<UserModel?> getCurrentUser() async {
    final rememberMe = _localDataSource.getRememberMe();
    final cachedUser = _localDataSource.getCachedUserSession();

    // 1. Try to fetch fresh live state from Firestore first
    try {
      UserModel? remoteUser;
      if (cachedUser != null) {
        remoteUser = await _remoteDataSource.getUserDataById(cachedUser.uid) ??
            await _remoteDataSource.getUserDataByEmail(cachedUser.email);
      } else {
        remoteUser = await _remoteDataSource.getCurrentUserData();
      }

      if (remoteUser != null) {
        if (rememberMe) {
          await _localDataSource.saveUserSession(remoteUser);
        }
        return remoteUser;
      }
    } catch (_) {
      // If offline or fetch failed, fallback to local cache
    }

    if (rememberMe && cachedUser != null) {
      return cachedUser;
    }

    return null;
  }

  @override
  Future<UserModel?> refreshCurrentUser() async {
    final cachedUser = _localDataSource.getCachedUserSession();
    try {
      UserModel? remoteUser;
      if (cachedUser != null) {
        remoteUser = await _remoteDataSource.getUserDataById(cachedUser.uid) ??
            await _remoteDataSource.getUserDataByEmail(cachedUser.email);
      } else {
        remoteUser = await _remoteDataSource.getCurrentUserData();
      }

      if (remoteUser != null) {
        await _localDataSource.saveUserSession(remoteUser);
        return remoteUser;
      }
    } catch (_) {}
    return cachedUser;
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final user = await _remoteDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _localDataSource.setRememberMe(rememberMe);
    if (rememberMe) {
      await _localDataSource.saveUserSession(user);
    } else {
      await _localDataSource.clearUserSession();
    }

    return user;
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
    String? city,
    String? storeName,
    String? commercialReg,
  }) async {
    final user = await _remoteDataSource.registerWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
      role: role,
      phone: phone,
      city: city,
      storeName: storeName,
      commercialReg: commercialReg,
    );

    await _localDataSource.setRememberMe(true);
    await _localDataSource.saveUserSession(user);

    return user;
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
    await _localDataSource.clearUserSession();
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _remoteDataSource.sendPasswordResetEmail(email);
  }

  @override
  String? getSavedEmail() => null;

  @override
  bool getRememberMe() => _localDataSource.getRememberMe();
}
