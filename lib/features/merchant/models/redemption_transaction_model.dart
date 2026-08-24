import 'package:equatable/equatable.dart';
import '../../../../core/utils/firebase_parser_utils.dart';

class RedemptionTransactionModel extends Equatable {
  final String transactionId;
  final String cardId;
  final String beneficiaryId;
  final String beneficiaryName;
  final String? beneficiaryNationalId;
  final String merchantId;
  final String merchantStoreName;
  final double amountDeducted;
  final int foodBasketsDeducted;
  final double remainingBalance;
  final int remainingBaskets;
  final String? notes;
  final DateTime timestamp;

  const RedemptionTransactionModel({
    required this.transactionId,
    required this.cardId,
    required this.beneficiaryId,
    required this.beneficiaryName,
    this.beneficiaryNationalId,
    required this.merchantId,
    required this.merchantStoreName,
    required this.amountDeducted,
    this.foodBasketsDeducted = 0,
    required this.remainingBalance,
    this.remainingBaskets = 0,
    this.notes,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'cardId': cardId,
      'beneficiaryId': beneficiaryId,
      'beneficiaryName': beneficiaryName,
      if (beneficiaryNationalId != null)
        'beneficiaryNationalId': beneficiaryNationalId,
      'merchantId': merchantId,
      'merchantStoreName': merchantStoreName,
      'amountDeducted': amountDeducted,
      'foodBasketsDeducted': foodBasketsDeducted,
      'remainingBalance': remainingBalance,
      'remainingBaskets': remainingBaskets,
      if (notes != null) 'notes': notes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory RedemptionTransactionModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    return RedemptionTransactionModel(
      transactionId: documentId ?? (map['transactionId'] as String? ?? ''),
      cardId: map['cardId'] as String? ?? '',
      beneficiaryId: map['beneficiaryId'] as String? ?? '',
      beneficiaryName: map['beneficiaryName'] as String? ?? '',
      beneficiaryNationalId: map['beneficiaryNationalId'] as String?,
      merchantId: map['merchantId'] as String? ?? '',
      merchantStoreName: map['merchantStoreName'] as String? ?? '',
      amountDeducted: FirebaseParserUtils.parseDouble(map['amountDeducted']),
      foodBasketsDeducted: FirebaseParserUtils.parseInt(map['foodBasketsDeducted']),
      remainingBalance: FirebaseParserUtils.parseDouble(map['remainingBalance']),
      remainingBaskets: FirebaseParserUtils.parseInt(map['remainingBaskets']),
      notes: map['notes'] as String?,
      timestamp: FirebaseParserUtils.parseDate(map['timestamp']),
    );
  }

  @override
  List<Object?> get props => [
        transactionId,
        cardId,
        beneficiaryId,
        beneficiaryName,
        beneficiaryNationalId,
        merchantId,
        merchantStoreName,
        amountDeducted,
        foodBasketsDeducted,
        remainingBalance,
        remainingBaskets,
        notes,
        timestamp,
      ];
}
