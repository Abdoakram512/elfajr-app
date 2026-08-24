import 'package:equatable/equatable.dart';
import '../../../../core/utils/firebase_parser_utils.dart';

enum BudgetAllocationType {
  initial,
  recharge,
  adjustment;

  static BudgetAllocationType fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'recharge':
        return BudgetAllocationType.recharge;
      case 'adjustment':
        return BudgetAllocationType.adjustment;
      case 'initial':
      default:
        return BudgetAllocationType.initial;
    }
  }

  String get nameString {
    switch (this) {
      case BudgetAllocationType.initial:
        return 'initial';
      case BudgetAllocationType.recharge:
        return 'recharge';
      case BudgetAllocationType.adjustment:
        return 'adjustment';
    }
  }
}

class BudgetAllocationModel extends Equatable {
  final String allocationId;
  final String merchantId;
  final String merchantName;
  final String merchantStoreName;
  final double amount;
  final BudgetAllocationType type;
  final String allocatedByAdminId;
  final String? allocatedByAdminEmail;
  final DateTime timestamp;
  final String? notes;

  const BudgetAllocationModel({
    required this.allocationId,
    required this.merchantId,
    required this.merchantName,
    required this.merchantStoreName,
    required this.amount,
    required this.type,
    required this.allocatedByAdminId,
    this.allocatedByAdminEmail,
    required this.timestamp,
    this.notes,
  });

  factory BudgetAllocationModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    return BudgetAllocationModel(
      allocationId: documentId ?? (map['allocationId'] as String? ?? ''),
      merchantId: map['merchantId'] as String? ?? '',
      merchantName: map['merchantName'] as String? ?? 'صراف معتمد',
      merchantStoreName: map['merchantStoreName'] as String? ?? 'منفذ صرف',
      amount: FirebaseParserUtils.parseDouble(map['amount']),
      type: BudgetAllocationType.fromString(map['type'] as String?),
      allocatedByAdminId:
          map['allocatedByAdminId'] as String? ?? 'admin',
      allocatedByAdminEmail: map['allocatedByAdminEmail'] as String?,
      timestamp: FirebaseParserUtils.parseDate(map['timestamp']),
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'allocationId': allocationId,
      'merchantId': merchantId,
      'merchantName': merchantName,
      'merchantStoreName': merchantStoreName,
      'amount': amount,
      'type': type.nameString,
      'allocatedByAdminId': allocatedByAdminId,
      if (allocatedByAdminEmail != null)
        'allocatedByAdminEmail': allocatedByAdminEmail,
      'timestamp': timestamp.toIso8601String(),
      if (notes != null) 'notes': notes,
    };
  }

  @override
  List<Object?> get props => [
        allocationId,
        merchantId,
        merchantName,
        merchantStoreName,
        amount,
        type,
        allocatedByAdminId,
        allocatedByAdminEmail,
        timestamp,
        notes,
      ];
}
