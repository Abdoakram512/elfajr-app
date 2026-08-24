import 'package:equatable/equatable.dart';
import '../../../../core/utils/firebase_parser_utils.dart';

class BasketDistributionModel extends Equatable {
  final String distributionId;
  final String cardId;
  final String beneficiaryId;
  final String beneficiaryName;
  final String nationalId;
  final int basketsCount;
  final int remainingBasketsAfter;
  final String distributionCenter;
  final String? administeredByAdminId;
  final String? administeredByAdminEmail;
  final DateTime timestamp;
  final String? notes;

  const BasketDistributionModel({
    required this.distributionId,
    required this.cardId,
    required this.beneficiaryId,
    required this.beneficiaryName,
    required this.nationalId,
    required this.basketsCount,
    this.remainingBasketsAfter = 0,
    required this.distributionCenter,
    this.administeredByAdminId,
    this.administeredByAdminEmail,
    required this.timestamp,
    this.notes,
  });

  factory BasketDistributionModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    return BasketDistributionModel(
      distributionId:
          documentId ?? (map['distributionId'] as String? ?? ''),
      cardId: map['cardId'] as String? ?? '',
      beneficiaryId: map['beneficiaryId'] as String? ?? '',
      beneficiaryName: map['beneficiaryName'] as String? ?? '',
      nationalId: map['nationalId'] as String? ?? '',
      basketsCount: FirebaseParserUtils.parseInt(map['basketsCount'], fallback: 1),
      remainingBasketsAfter:
          FirebaseParserUtils.parseInt(map['remainingBasketsAfter'], fallback: 0),
      distributionCenter: map['distributionCenter'] as String? ??
          'المقر الرئيسي - مركز توزيع الفجر',
      administeredByAdminId: map['administeredByAdminId'] as String?,
      administeredByAdminEmail: map['administeredByAdminEmail'] as String?,
      timestamp: FirebaseParserUtils.parseDate(map['timestamp']),
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'distributionId': distributionId,
      'cardId': cardId,
      'beneficiaryId': beneficiaryId,
      'beneficiaryName': beneficiaryName,
      'nationalId': nationalId,
      'basketsCount': basketsCount,
      'remainingBasketsAfter': remainingBasketsAfter,
      'distributionCenter': distributionCenter,
      if (administeredByAdminId != null)
        'administeredByAdminId': administeredByAdminId,
      if (administeredByAdminEmail != null)
        'administeredByAdminEmail': administeredByAdminEmail,
      'timestamp': timestamp.toIso8601String(),
      if (notes != null) 'notes': notes,
    };
  }

  @override
  List<Object?> get props => [
        distributionId,
        cardId,
        beneficiaryId,
        beneficiaryName,
        nationalId,
        basketsCount,
        remainingBasketsAfter,
        distributionCenter,
        administeredByAdminId,
        administeredByAdminEmail,
        timestamp,
        notes,
      ];
}
