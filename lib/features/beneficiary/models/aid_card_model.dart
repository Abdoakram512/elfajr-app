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
  final double totalBalance;
  final int foodBasketsQuota;
  final AidCardStatus status;
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
    required this.totalBalance,
    required this.foodBasketsQuota,
    this.status = AidCardStatus.active,
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
    double? totalBalance,
    int? foodBasketsQuota,
    AidCardStatus? status,
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
      totalBalance: totalBalance ?? this.totalBalance,
      foodBasketsQuota: foodBasketsQuota ?? this.foodBasketsQuota,
      status: status ?? this.status,
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
      'totalBalance': totalBalance,
      'foodBasketsQuota': foodBasketsQuota,
      'status': status.nameString,
      'issuedByVolunteerId': issuedByVolunteerId,
      'activatedAt': activatedAt?.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'securityHash': securityHash,
    };
  }

  factory AidCardModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return AidCardModel(
      cardId: documentId ?? (map['cardId'] as String? ?? ''),
      beneficiaryId: map['beneficiaryId'] as String? ?? '',
      beneficiaryName: map['beneficiaryName'] as String? ?? '',
      nationalId: map['nationalId'] as String? ?? '',
      familyCount: map['familyCount'] as int? ?? 1,
      totalBalance: (map['totalBalance'] as num?)?.toDouble() ?? 0.0,
      foodBasketsQuota: map['foodBasketsQuota'] as int? ?? 0,
      status: AidCardStatus.fromString(map['status'] as String?),
      issuedByVolunteerId: map['issuedByVolunteerId'] as String?,
      activatedAt: map['activatedAt'] != null
          ? DateTime.tryParse(map['activatedAt'] as String)
          : null,
      expiresAt: map['expiresAt'] != null
          ? DateTime.tryParse(map['expiresAt'] as String) ??
              DateTime.now().add(const Duration(days: 365))
          : DateTime.now().add(const Duration(days: 365)),
      securityHash: map['securityHash'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [
        cardId,
        beneficiaryId,
        beneficiaryName,
        nationalId,
        familyCount,
        totalBalance,
        foodBasketsQuota,
        status,
        issuedByVolunteerId,
        activatedAt,
        expiresAt,
        securityHash,
      ];
}
