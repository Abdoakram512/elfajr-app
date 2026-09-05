import 'package:equatable/equatable.dart';
import '../../../../core/utils/firebase_parser_utils.dart';

enum AidCardStatus {
  active,
  pendingActivation,
  frozen,
  depleted,
  expired;

  static AidCardStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'active':
        return AidCardStatus.active;
      case 'frozen':
        return AidCardStatus.frozen;
      case 'depleted':
        return AidCardStatus.depleted;
      case 'expired':
        return AidCardStatus.expired;
      case 'pending_activation':
      default:
        return AidCardStatus.pendingActivation;
    }
  }

  String get nameString {
    switch (this) {
      case AidCardStatus.active:
        return 'active';
      case AidCardStatus.frozen:
        return 'frozen';
      case AidCardStatus.depleted:
        return 'depleted';
      case AidCardStatus.expired:
        return 'expired';
      case AidCardStatus.pendingActivation:
        return 'pending_activation';
    }
  }
}

class AidCardModel extends Equatable {
  final String cardId;
  final String beneficiaryId;
  final String beneficiaryName;
  final String nationalId;
  final int familyCount;
  final String? residence;
  final double totalBalance;
  final int foodBasketsQuota;
  final AidCardStatus status;
  final String? socialStatus;
  final String? nationality;
  final String? fieldResearchStatus;
  final String? issuedByVolunteerId;
  final DateTime? activatedAt;
  final DateTime expiresAt;
  final String securityHash;
  final String? lastMonthlyCycle;
  final DateTime? lastRechargedAt;

  const AidCardModel({
    required this.cardId,
    required this.beneficiaryId,
    required this.beneficiaryName,
    required this.nationalId,
    this.familyCount = 4,
    this.residence,
    required this.totalBalance,
    required this.foodBasketsQuota,
    this.status = AidCardStatus.active,
    this.socialStatus,
    this.nationality,
    this.fieldResearchStatus,
    this.issuedByVolunteerId,
    this.activatedAt,
    required this.expiresAt,
    required this.securityHash,
    this.lastMonthlyCycle,
    this.lastRechargedAt,
  });

  bool get isActive => status == AidCardStatus.active;
  bool get hasBalance => totalBalance > 0 || foodBasketsQuota > 0;

  AidCardModel copyWith({
    String? cardId,
    String? beneficiaryId,
    String? beneficiaryName,
    String? nationalId,
    int? familyCount,
    String? residence,
    double? totalBalance,
    int? foodBasketsQuota,
    AidCardStatus? status,
    String? socialStatus,
    String? nationality,
    String? fieldResearchStatus,
    String? issuedByVolunteerId,
    DateTime? activatedAt,
    DateTime? expiresAt,
    String? securityHash,
    String? lastMonthlyCycle,
    DateTime? lastRechargedAt,
  }) {
    return AidCardModel(
      cardId: cardId ?? this.cardId,
      beneficiaryId: beneficiaryId ?? this.beneficiaryId,
      beneficiaryName: beneficiaryName ?? this.beneficiaryName,
      nationalId: nationalId ?? this.nationalId,
      familyCount: familyCount ?? this.familyCount,
      residence: residence ?? this.residence,
      totalBalance: totalBalance ?? this.totalBalance,
      foodBasketsQuota: foodBasketsQuota ?? this.foodBasketsQuota,
      status: status ?? this.status,
      socialStatus: socialStatus ?? this.socialStatus,
      nationality: nationality ?? this.nationality,
      fieldResearchStatus: fieldResearchStatus ?? this.fieldResearchStatus,
      issuedByVolunteerId: issuedByVolunteerId ?? this.issuedByVolunteerId,
      activatedAt: activatedAt ?? this.activatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      securityHash: securityHash ?? this.securityHash,
      lastMonthlyCycle: lastMonthlyCycle ?? this.lastMonthlyCycle,
      lastRechargedAt: lastRechargedAt ?? this.lastRechargedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cardId': cardId,
      'beneficiaryId': beneficiaryId,
      'beneficiaryName': beneficiaryName,
      'nationalId': nationalId,
      'familyCount': familyCount,
      'residence': residence,
      'balance': totalBalance,
      'totalBalance': totalBalance,
      'foodBasketsQuota': foodBasketsQuota,
      'status': status.nameString,
      'socialStatus': socialStatus,
      'nationality': nationality,
      'fieldResearchStatus': fieldResearchStatus,
      'issuedByVolunteerId': issuedByVolunteerId,
      'activatedAt': activatedAt?.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'securityHash': securityHash,
      'lastMonthlyCycle': lastMonthlyCycle,
      'lastRechargedAt': lastRechargedAt?.toIso8601String(),
    };
  }

  factory AidCardModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return AidCardModel(
      cardId: documentId ?? (map['cardId'] as String? ?? ''),
      beneficiaryId: map['beneficiaryId'] as String? ?? '',
      beneficiaryName: map['beneficiaryName'] as String? ?? '',
      nationalId: map['nationalId'] as String? ?? '',
      familyCount: FirebaseParserUtils.parseInt(map['familyCount'], fallback: 1),
      residence: map['residence'] as String?,
      totalBalance: FirebaseParserUtils.parseDouble(map['balance'] ?? map['totalBalance']),
      foodBasketsQuota: FirebaseParserUtils.parseInt(map['foodBasketsQuota']),
      status: AidCardStatus.fromString(map['status'] as String?),
      socialStatus: map['socialStatus'] as String?,
      nationality: map['nationality'] as String?,
      fieldResearchStatus: map['fieldResearchStatus'] as String?,
      issuedByVolunteerId: map['issuedByVolunteerId'] as String?,
      activatedAt: FirebaseParserUtils.parseNullableDate(map['activatedAt']),
      expiresAt: FirebaseParserUtils.parseDate(
        map['expiresAt'],
        fallback: DateTime.now().add(const Duration(days: 365)),
      ),
      securityHash: map['securityHash'] as String? ?? '',
      lastMonthlyCycle: map['lastMonthlyCycle'] as String?,
      lastRechargedAt: FirebaseParserUtils.parseNullableDate(map['lastRechargedAt']),
    );
  }

  @override
  List<Object?> get props => [
    cardId,
    beneficiaryId,
    beneficiaryName,
    nationalId,
    familyCount,
    residence,
    totalBalance,
    foodBasketsQuota,
    status,
    socialStatus,
    nationality,
    fieldResearchStatus,
    issuedByVolunteerId,
    activatedAt,
    expiresAt,
    securityHash,
    lastMonthlyCycle,
    lastRechargedAt,
  ];
}
