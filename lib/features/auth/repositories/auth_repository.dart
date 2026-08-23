import '../models/user_model.dart';
import '../models/user_role.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel?> refreshCurrentUser();
  Future<UserModel> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  });
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
    String? city,
    String? storeName,
    String? commercialReg,
    String? nationality,
  });
  Future<void> signOut();
  Future<void> sendPasswordReset(String email);
  String? getSavedEmail();
  bool getRememberMe();
}
