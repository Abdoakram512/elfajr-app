import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentReceiptModel {
  final String id;
  final String? receiptId;
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
  final String? notes;
  final String? adminName;
  final DateTime? timestamp;
  final DateTime? confirmedAt;

  const PaymentReceiptModel({
    required this.id,
    this.receiptId,
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
    this.notes,
    this.adminName,
    this.timestamp,
    this.confirmedAt,
  });

  bool get isConfirmed => status == 'confirmed_by_merchant';

  factory PaymentReceiptModel.fromFirestore(
    Map<String, dynamic> map,
    String documentId,
  ) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    String? admin;
    if (map['sentBy'] is Map) {
      admin = map['sentBy']['adminName']?.toString();
    }

    return PaymentReceiptModel(
      id: documentId,
      receiptId: map['receiptId']?.toString() ?? documentId,
      merchantId: map['merchantId']?.toString() ?? '',
      merchantName: map['merchantName']?.toString() ?? 'منفذ معتمد',
      merchantStoreName: map['merchantStoreName']?.toString(),
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : 0.0,
      paymentMethod: map['paymentMethod']?.toString() ?? 'instapay',
      referenceNumber: map['referenceNumber']?.toString() ?? '',
      senderAccountOrPhone: map['senderAccountOrPhone']?.toString(),
      receiverAccountOrPhone: map['receiverAccountOrPhone']?.toString(),
      receiptImageUrl: map['receiptImageUrl']?.toString(),
      status: map['status']?.toString() ?? 'sent',
      notes: map['notes']?.toString(),
      adminName: admin,
      timestamp: parseDate(map['timestamp']) ?? parseDate(map['createdAt']),
      confirmedAt: parseDate(map['confirmedAt']),
    );
  }
}
