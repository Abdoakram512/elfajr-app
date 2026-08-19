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
    if (rememberMe) {
      final cachedUser = _localDataSource.getCachedUserSession();
      if (cachedUser != null) {
        return cachedUser;
      }
    }

    final remoteUser = await _remoteDataSource.getCurrentUserData();
    if (remoteUser != null && rememberMe) {
      await _localDataSource.saveUserSession(remoteUser);
    }
    return remoteUser;
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
