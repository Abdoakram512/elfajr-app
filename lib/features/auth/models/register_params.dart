import 'user_role.dart';

class RegisterParams {
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String? phone;
  final String? city;
  final String? storeName;
  final String? commercialReg;
  final String? nationality;
  final String? nationalId;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.phone,
    this.city,
    this.storeName,
    this.commercialReg,
    this.nationality,
    this.nationalId,
  });

  factory RegisterParams.beneficiary({
    required String name,
    required String password,
    required String phone,
    required String city,
    required String nationalId,
    required String nationality,
  }) {
    return RegisterParams(
      name: name,
      email: '',
      password: password,
      role: UserRole.beneficiary,
      phone: phone,
      city: city,
      nationalId: nationalId,
      nationality: nationality,
    );
  }

  factory RegisterParams.merchant({
    required String storeName,
    required String email,
    required String password,
    required String phone,
    required String city,
    String? commercialReg,
  }) {
    return RegisterParams(
      name: storeName,
      email: email,
      password: password,
      role: UserRole.merchant,
      phone: phone,
      city: city,
      storeName: storeName,
      commercialReg: commercialReg,
    );
  }

  bool get isBeneficiary => role == UserRole.beneficiary;
  bool get isMerchant => role == UserRole.merchant;
  bool get isAdmin => role == UserRole.admin;
}
