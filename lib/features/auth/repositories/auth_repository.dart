import '../models/register_params.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel?> refreshCurrentUser();
  Future<UserModel> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  });
  Future<UserModel> register(RegisterParams params);
  Future<void> signOut();
  Future<void> sendPasswordReset(String email);
  String? getSavedEmail();
  bool getRememberMe();
  Stream<List<String>> streamNationalities();
}
