enum UserRole {
  donor,
  beneficiary,
  volunteer,
  admin;

  String get nameString => name;

  static UserRole fromString(String? value) {
    return UserRole.values.firstWhere(
      (role) => role.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => UserRole.donor,
    );
  }

  bool get isAdmin => this == UserRole.admin;
  bool get isVolunteer => this == UserRole.volunteer;
  bool get isBeneficiary => this == UserRole.beneficiary;
  bool get isDonor => this == UserRole.donor;
}
