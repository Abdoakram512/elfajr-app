import 'package:equatable/equatable.dart';
import '../utils/firebase_parser_utils.dart';

enum NotificationType {
  paymentReceipt,
  extraDisbursementStatus,
  basketDelivered,
  general;

  static NotificationType fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'payment_receipt':
        return NotificationType.paymentReceipt;
      case 'extra_disbursement':
      case 'extra_disbursement_status':
        return NotificationType.extraDisbursementStatus;
      case 'basket_delivery':
      case 'basket_delivered':
        return NotificationType.basketDelivered;
      case 'general':
      default:
        return NotificationType.general;
    }
  }

  String get nameString {
    switch (this) {
      case NotificationType.paymentReceipt:
        return 'payment_receipt';
      case NotificationType.extraDisbursementStatus:
        return 'extra_disbursement_status';
      case NotificationType.basketDelivered:
        return 'basket_delivered';
      case NotificationType.general:
        return 'general';
    }
  }
}

class AppNotificationModel extends Equatable {
  final String notificationId;
  final String userId;
  final String recipientRole;
  final String title;
  final String body;
  final NotificationType type;
  final String? referenceId;
  final double? amount;
  final bool isRead;
  final DateTime timestamp;

  const AppNotificationModel({
    required this.notificationId,
    required this.userId,
    required this.recipientRole,
    required this.title,
    required this.body,
    required this.type,
    this.referenceId,
    this.amount,
    this.isRead = false,
    required this.timestamp,
  });

  factory AppNotificationModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    return AppNotificationModel(
      notificationId:
          documentId ?? (map['notificationId'] as String? ?? (map['id'] as String? ?? '')),
      userId: map['userId'] as String? ?? '',
      recipientRole: map['recipientRole'] as String? ?? 'beneficiary',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      type: NotificationType.fromString(map['type'] as String?),
      referenceId: map['referenceId'] as String?,
      amount: FirebaseParserUtils.parseNullableDouble(map['amount']),
      isRead: FirebaseParserUtils.parseBool(map['isRead'], fallback: false),
      timestamp: FirebaseParserUtils.parseDate(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'id': notificationId,
      'userId': userId,
      'recipientRole': recipientRole,
      'title': title,
      'body': body,
      'type': type.nameString,
      if (referenceId != null) 'referenceId': referenceId,
      if (amount != null) 'amount': amount,
      'isRead': isRead,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        notificationId,
        userId,
        recipientRole,
        title,
        body,
        type,
        referenceId,
        amount,
        isRead,
        timestamp,
      ];
}
