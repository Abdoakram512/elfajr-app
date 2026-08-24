import 'package:equatable/equatable.dart';

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
      'totalBalance': totalBalance,
      'balance': totalBalance,
      'foodBasketsQuota': foodBasketsQuota,
      'quota': foodBasketsQuota,
      'status': status.nameString,
      'socialStatus': socialStatus,
      'nationality': nationality,
      'fieldResearchStatus': fieldResearchStatus,
      'issuedByVolunteerId': issuedByVolunteerId,
      'activatedAt': activatedAt?.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'securityHash': securityHash,
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now().add(const Duration(days: 365));
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ??
          DateTime.now().add(const Duration(days: 365));
    }
    try {
      return (value as dynamic).toDate();
    } catch (_) {
      return DateTime.now().add(const Duration(days: 365));
    }
  }

  static double _parseDouble(dynamic value, {double fallback = 0.0}) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? fallback;
    return fallback;
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? fallback;
    return fallback;
  }

  factory AidCardModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return AidCardModel(
      cardId: documentId ?? (map['cardId'] as String? ?? 'FAJR-CARD-002'),
      beneficiaryId: map['beneficiaryId'] as String? ?? '',
      beneficiaryName: map['beneficiaryName'] as String? ?? 'مستفيد',
      nationalId: map['nationalId'] as String? ?? '',
      familyCount: _parseInt(map['familyCount'], fallback: 4),
      residence: map['residence'] as String?,
      totalBalance: _parseDouble(
        map['balance'] ??
            (map['totalBalance'] ?? (map['currentBalance'] ?? map['amount'])),
        fallback: 600.0,
      ),
      foodBasketsQuota: _parseInt(
        map['foodBasketsQuota'] ??
            (map['quota'] ?? (map['basketsQuota'] ?? map['basketsCount'])),
        fallback: 2,
      ),
      status: AidCardStatus.fromString(map['status'] as String?),
      socialStatus: map['socialStatus'] as String?,
      nationality: map['nationality'] as String?,
      fieldResearchStatus: map['fieldResearchStatus'] as String?,
      issuedByVolunteerId: map['issuedByVolunteerId'] as String?,
      activatedAt: map['activatedAt'] != null
          ? _parseDate(map['activatedAt'])
          : null,
      expiresAt: _parseDate(map['expiresAt']),
      securityHash:
          map['securityHash'] as String? ?? 'sha256_secure_card_token',
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
  ];
}
