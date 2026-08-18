import 'package:equatable/equatable.dart';
import 'user_role.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String? phone;
  final UserRole role;
  final bool isApproved;
  final String? city;
  final String? extraDetails; // Skills for volunteer, family info for beneficiary
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.phone,
    required this.role,
    this.isApproved = true,
    this.city,
    this.extraDetails,
    required this.createdAt,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    UserRole? role,
    bool? isApproved,
    String? city,
    String? extraDetails,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isApproved: isApproved ?? this.isApproved,
      city: city ?? this.city,
      extraDetails: extraDetails ?? this.extraDetails,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.name,
      'isApproved': isApproved,
      'city': city,
      'extraDetails': extraDetails,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return UserModel(
      uid: documentId ?? (map['uid'] as String? ?? ''),
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String?,
      role: UserRole.fromString(map['role'] as String?),
      isApproved: map['isApproved'] as bool? ?? true,
      city: map['city'] as String?,
      extraDetails: map['extraDetails'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        name,
        phone,
        role,
        isApproved,
        city,
        extraDetails,
        createdAt,
      ];
}
