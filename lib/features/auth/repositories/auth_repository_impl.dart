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
    return await _remoteDataSource.getCurrentUserData();
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
      await _localDataSource.saveEmail(email.trim());
    } else {
      await _localDataSource.clearSavedEmail();
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

    return user;
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _remoteDataSource.sendPasswordResetEmail(email);
  }

  @override
  String? getSavedEmail() {
    return _localDataSource.getSavedEmail();
  }

  @override
  bool getRememberMe() {
    return _localDataSource.getRememberMe();
  }
}
