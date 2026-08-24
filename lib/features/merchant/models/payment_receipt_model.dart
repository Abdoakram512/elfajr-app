import 'package:equatable/equatable.dart';
import '../../../../core/utils/firebase_parser_utils.dart';

class PaymentReceiptModel extends Equatable {
  final String id;
  final String receiptId;
  final String merchantId;
  final String merchantName;
  final String? merchantStoreName;
  final double amount;
  final String paymentMethod; // instapay, vodafone_cash, bank_transfer, cash
  final String referenceNumber;
  final String? senderAccountOrPhone;
  final String? receiverAccountOrPhone;
  final String? receiptImageUrl;
  final String status; // sent, confirmed_by_merchant, disputed
  final String? sentByAdminId;
  final String? sentByAdminEmail;
  final String? adminName;
  final String? notes;
  final DateTime timestamp;
  final DateTime? confirmedAt;

  const PaymentReceiptModel({
    required this.id,
    required this.receiptId,
    required this.merchantId,
    required this.merchantName,
    this.merchantStoreName,
    required this.amount,
    required this.paymentMethod,
    required this.referenceNumber,
    this.senderAccountOrPhone,
    this.receiverAccountOrPhone,
    this.receiptImageUrl,
    required this.status,
    this.sentByAdminId,
    this.sentByAdminEmail,
    this.adminName,
    this.notes,
    required this.timestamp,
    this.confirmedAt,
  });

  bool get isConfirmed => status == 'confirmed_by_merchant' || status == 'confirmed';
  bool get isPending => !isConfirmed;

  factory PaymentReceiptModel.fromFirestore(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return PaymentReceiptModel.fromMap(map, documentId: documentId);
  }

  factory PaymentReceiptModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    String? admin;
    if (map['sentBy'] is Map) {
      admin = map['sentBy']['adminName']?.toString();
    }

    return PaymentReceiptModel(
      id: documentId ?? (map['receiptId'] as String? ?? (map['id'] as String? ?? '')),
      receiptId: map['receiptId'] as String? ?? (documentId ?? (map['id'] as String? ?? '')),
      merchantId: map['merchantId'] as String? ?? '',
      merchantName: map['merchantName'] as String? ?? 'منفذ معتمد',
      merchantStoreName: map['merchantStoreName'] as String?,
      amount: FirebaseParserUtils.parseDouble(map['amount']),
      paymentMethod: map['paymentMethod'] as String? ?? 'instapay',
      referenceNumber: map['referenceNumber'] as String? ?? '',
      senderAccountOrPhone: map['senderAccountOrPhone'] as String?,
      receiverAccountOrPhone: map['receiverAccountOrPhone'] as String?,
      receiptImageUrl: map['receiptImageUrl'] as String?,
      status: map['status'] as String? ?? 'sent',
      sentByAdminId: map['sentByAdminId'] as String?,
      sentByAdminEmail: map['sentByAdminEmail'] as String?,
      adminName: admin ?? map['adminName'] as String?,
      notes: map['notes'] as String?,
      timestamp: FirebaseParserUtils.parseDate(map['timestamp']),
      confirmedAt: FirebaseParserUtils.parseNullableDate(map['confirmedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'receiptId': receiptId,
      'id': id,
      'merchantId': merchantId,
      'merchantName': merchantName,
      if (merchantStoreName != null) 'merchantStoreName': merchantStoreName,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'referenceNumber': referenceNumber,
      if (senderAccountOrPhone != null)
        'senderAccountOrPhone': senderAccountOrPhone,
      if (receiverAccountOrPhone != null)
        'receiverAccountOrPhone': receiverAccountOrPhone,
      if (receiptImageUrl != null) 'receiptImageUrl': receiptImageUrl,
      'status': status,
      if (sentByAdminId != null) 'sentByAdminId': sentByAdminId,
      if (sentByAdminEmail != null) 'sentByAdminEmail': sentByAdminEmail,
      if (adminName != null) 'adminName': adminName,
      if (notes != null) 'notes': notes,
      'timestamp': timestamp.toIso8601String(),
      if (confirmedAt != null) 'confirmedAt': confirmedAt!.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        receiptId,
        merchantId,
        merchantName,
        merchantStoreName,
        amount,
        paymentMethod,
        referenceNumber,
        senderAccountOrPhone,
        receiverAccountOrPhone,
        receiptImageUrl,
        status,
        sentByAdminId,
        sentByAdminEmail,
        adminName,
        notes,
        timestamp,
        confirmedAt,
      ];
}
