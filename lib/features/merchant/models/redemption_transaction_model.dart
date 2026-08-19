import 'package:equatable/equatable.dart';

class RedemptionTransactionModel extends Equatable {
  final String transactionId;
  final String cardId;
  final String beneficiaryId;
  final String beneficiaryName;
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
      'merchantId': merchantId,
      'merchantStoreName': merchantStoreName,
      'amountDeducted': amountDeducted,
      'foodBasketsDeducted': foodBasketsDeducted,
      'remainingBalance': remainingBalance,
      'remainingBaskets': remainingBaskets,
      'notes': notes,
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
      merchantId: map['merchantId'] as String? ?? '',
      merchantStoreName: map['merchantStoreName'] as String? ?? '',
      amountDeducted: (map['amountDeducted'] as num?)?.toDouble() ?? 0.0,
      foodBasketsDeducted: map['foodBasketsDeducted'] as int? ?? 0,
      remainingBalance: (map['remainingBalance'] as num?)?.toDouble() ?? 0.0,
      remainingBaskets: map['remainingBaskets'] as int? ?? 0,
      notes: map['notes'] as String?,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        transactionId,
        cardId,
        beneficiaryId,
        beneficiaryName,
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
