import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'user_role.dart';

DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String? phone;
  final UserRole role;
  final bool isApproved;
  final String? city;
  final String?
  extraDetails; // Skills for volunteer, family info for beneficiary
  final String?
  activeCardId; // For beneficiary: their active digital QR aid card ID
  final String? storeName; // For merchant: store / pharmacy / center name
  final String? commercialReg; // For merchant: CR number
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
    this.activeCardId,
    this.storeName,
    this.commercialReg,
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
    String? activeCardId,
    String? storeName,
    String? commercialReg,
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
      activeCardId: activeCardId ?? this.activeCardId,
      storeName: storeName ?? this.storeName,
      commercialReg: commercialReg ?? this.commercialReg,
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
      'activeCardId': activeCardId,
      'storeName': storeName,
      'commercialReg': commercialReg,
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
      activeCardId: map['activeCardId'] as String?,
      storeName: map['storeName'] as String?,
      commercialReg: map['commercialReg'] as String?,
      createdAt: _parseDateTime(map['createdAt']),
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
    activeCardId,
    storeName,
    commercialReg,
    createdAt,
  ];
}
