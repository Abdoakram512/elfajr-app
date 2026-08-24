import 'package:equatable/equatable.dart';
import '../../../../core/utils/firebase_parser_utils.dart';

enum DisbursementRequestStatus {
  pending,
  approved,
  rejected;

  static DisbursementRequestStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'approved':
        return DisbursementRequestStatus.approved;
      case 'rejected':
        return DisbursementRequestStatus.rejected;
      case 'pending':
      default:
        return DisbursementRequestStatus.pending;
    }
  }

  String get nameString {
    switch (this) {
      case DisbursementRequestStatus.approved:
        return 'approved';
      case DisbursementRequestStatus.rejected:
        return 'rejected';
      case DisbursementRequestStatus.pending:
        return 'pending';
    }
  }
}

class ExtraDisbursementRequestModel extends Equatable {
  final String requestId;
  final String merchantId;
  final String merchantStoreName;
  final String cardId;
  final String beneficiaryId;
  final String beneficiaryName;
  final String? beneficiaryNationalId;
  final double requestedAmount;
  final String reason;
  final DisbursementRequestStatus status;
  final String? reviewedByAdminId;
  final String? reviewedByAdminName;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final String? resultingTransactionId;
  final DateTime timestamp;

  const ExtraDisbursementRequestModel({
    required this.requestId,
    required this.merchantId,
    required this.merchantStoreName,
    required this.cardId,
    required this.beneficiaryId,
    required this.beneficiaryName,
    this.beneficiaryNationalId,
    required this.requestedAmount,
    required this.reason,
    required this.status,
    this.reviewedByAdminId,
    this.reviewedByAdminName,
    this.reviewedAt,
    this.rejectionReason,
    this.resultingTransactionId,
    required this.timestamp,
  });

  factory ExtraDisbursementRequestModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    return ExtraDisbursementRequestModel(
      requestId: documentId ?? (map['requestId'] as String? ?? ''),
      merchantId: map['merchantId'] as String? ?? '',
      merchantStoreName: map['merchantStoreName'] as String? ?? '',
      cardId: map['cardId'] as String? ?? '',
      beneficiaryId: map['beneficiaryId'] as String? ?? '',
      beneficiaryName: map['beneficiaryName'] as String? ?? '',
      beneficiaryNationalId: map['beneficiaryNationalId'] as String?,
      requestedAmount: FirebaseParserUtils.parseDouble(map['requestedAmount']),
      reason: map['reason'] as String? ?? '',
      status: DisbursementRequestStatus.fromString(map['status'] as String?),
      reviewedByAdminId: map['reviewedByAdminId'] as String?,
      reviewedByAdminName: map['reviewedByAdminName'] as String?,
      reviewedAt: FirebaseParserUtils.parseNullableDate(map['reviewedAt']),
      rejectionReason: map['rejectionReason'] as String?,
      resultingTransactionId: map['resultingTransactionId'] as String?,
      timestamp: FirebaseParserUtils.parseDate(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'merchantId': merchantId,
      'merchantStoreName': merchantStoreName,
      'cardId': cardId,
      'beneficiaryId': beneficiaryId,
      'beneficiaryName': beneficiaryName,
      if (beneficiaryNationalId != null)
        'beneficiaryNationalId': beneficiaryNationalId,
      'requestedAmount': requestedAmount,
      'reason': reason,
      'status': status.nameString,
      if (reviewedByAdminId != null) 'reviewedByAdminId': reviewedByAdminId,
      if (reviewedByAdminName != null) 'reviewedByAdminName': reviewedByAdminName,
      if (reviewedAt != null) 'reviewedAt': reviewedAt!.toIso8601String(),
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      if (resultingTransactionId != null)
        'resultingTransactionId': resultingTransactionId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        requestId,
        merchantId,
        merchantStoreName,
        cardId,
        beneficiaryId,
        beneficiaryName,
        beneficiaryNationalId,
        requestedAmount,
        reason,
        status,
        reviewedByAdminId,
        reviewedByAdminName,
        reviewedAt,
        rejectionReason,
        resultingTransactionId,
        timestamp,
      ];
}
