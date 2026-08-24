import 'package:equatable/equatable.dart';
import '../../../../core/utils/firebase_parser_utils.dart';
import 'user_role.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String? phone;
  final UserRole role;
  final bool isApproved;
  final bool isActive;
  final String? city;
  final String? activeCardId; // For beneficiary: their active digital QR aid card ID
  final String? nationalId; // For beneficiary: Passport / National ID
  final String? nationality; // For beneficiary: e.g. سورية / مصرية
  final String? socialStatus; // For beneficiary: e.g. أرملة / مطلقة / مريض سرطان
  final String? fieldResearchStatus; // For beneficiary: e.g. سلمت البحث
  final String? medicalNotes; // For beneficiary: free surgery / clinic notes
  final String? inKindNeeds; // For beneficiary: household / in-kind items
  final String? storeName; // For merchant: store / pharmacy / center name
  final String? commercialReg; // For merchant: CR number
  
  // New Liquidity & Budget Fields
  final double? allocatedBudget;
  final double? currentRemainingBudget;
  final String? instapayAddress;
  final String? vodafoneCashNumber;
  final String? liquidityAlertLevel;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.phone,
    required this.role,
    this.isApproved = true,
    this.isActive = true,
    this.city,
    this.activeCardId,
    this.nationalId,
    this.nationality,
    this.socialStatus,
    this.fieldResearchStatus,
    this.medicalNotes,
    this.inKindNeeds,
    this.storeName,
    this.commercialReg,
    this.allocatedBudget,
    this.currentRemainingBudget,
    this.instapayAddress,
    this.vodafoneCashNumber,
    this.liquidityAlertLevel,
    required this.createdAt,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    UserRole? role,
    bool? isApproved,
    bool? isActive,
    String? city,
    String? activeCardId,
    String? nationalId,
    String? nationality,
    String? socialStatus,
    String? fieldResearchStatus,
    String? medicalNotes,
    String? inKindNeeds,
    String? storeName,
    String? commercialReg,
    double? allocatedBudget,
    double? currentRemainingBudget,
    String? instapayAddress,
    String? vodafoneCashNumber,
    String? liquidityAlertLevel,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isApproved: isApproved ?? this.isApproved,
      isActive: isActive ?? this.isActive,
      city: city ?? this.city,
      activeCardId: activeCardId ?? this.activeCardId,
      nationalId: nationalId ?? this.nationalId,
      nationality: nationality ?? this.nationality,
      socialStatus: socialStatus ?? this.socialStatus,
      fieldResearchStatus: fieldResearchStatus ?? this.fieldResearchStatus,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      inKindNeeds: inKindNeeds ?? this.inKindNeeds,
      storeName: storeName ?? this.storeName,
      commercialReg: commercialReg ?? this.commercialReg,
      allocatedBudget: allocatedBudget ?? this.allocatedBudget,
      currentRemainingBudget: currentRemainingBudget ?? this.currentRemainingBudget,
      instapayAddress: instapayAddress ?? this.instapayAddress,
      vodafoneCashNumber: vodafoneCashNumber ?? this.vodafoneCashNumber,
      liquidityAlertLevel: liquidityAlertLevel ?? this.liquidityAlertLevel,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String? get residence => city;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.name,
      'isApproved': isApproved,
      'isActive': isActive,
      'city': city,
      'residence': city,
      'activeCardId': activeCardId,
      'nationalId': nationalId,
      'nationality': nationality,
      'socialStatus': socialStatus,
      'fieldResearchStatus': fieldResearchStatus,
      'medicalNotes': medicalNotes,
      'inKindNeeds': inKindNeeds,
      'storeName': storeName,
      'commercialReg': commercialReg,
      'allocatedBudget': allocatedBudget,
      'currentRemainingBudget': currentRemainingBudget,
      'instapayAddress': instapayAddress,
      'vodafoneCashNumber': vodafoneCashNumber,
      'liquidityAlertLevel': liquidityAlertLevel,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return UserModel(
      uid: documentId ?? (map['uid'] as String? ?? ''),
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? (map['fullName'] as String? ?? ''),
      phone: map['phone'] as String?,
      role: UserRole.fromString(map['role'] as String?),
      isApproved: map['isApproved'] as bool? ?? true,
      isActive: map['isActive'] as bool? ?? true,
      city: map['residence'] as String? ?? (map['city'] as String?),
      activeCardId: map['activeCardId'] as String?,
      nationalId: map['nationalId'] as String?,
      nationality: map['nationality'] as String?,
      socialStatus: map['socialStatus'] as String?,
      fieldResearchStatus: map['fieldResearchStatus'] as String?,
      medicalNotes: map['medicalNotes'] as String?,
      inKindNeeds: map['inKindNeeds'] as String?,
      storeName: map['storeName'] as String?,
      commercialReg: map['commercialReg'] as String?,
      allocatedBudget: FirebaseParserUtils.parseNullableDouble(map['allocatedBudget']),
      currentRemainingBudget: FirebaseParserUtils.parseNullableDouble(map['currentRemainingBudget']),
      instapayAddress: map['instapayAddress'] as String?,
      vodafoneCashNumber: map['vodafoneCashNumber'] as String?,
      liquidityAlertLevel: map['liquidityAlertLevel'] as String?,
      createdAt: FirebaseParserUtils.parseDate(map['createdAt']),
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
    isActive,
    city,
    activeCardId,
    nationalId,
    nationality,
    socialStatus,
    fieldResearchStatus,
    medicalNotes,
    inKindNeeds,
    storeName,
    commercialReg,
    allocatedBudget,
    currentRemainingBudget,
    instapayAddress,
    vodafoneCashNumber,
    liquidityAlertLevel,
    createdAt,
  ];
}
