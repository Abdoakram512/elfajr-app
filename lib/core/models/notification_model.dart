import 'package:equatable/equatable.dart';
import '../utils/firebase_parser_utils.dart';

enum NotificationType {
  paymentReceipt,
  budgetAllocated,
  extraDisbursementResponse,
  aidDistributed,
  cardStatusUpdate,
  general;

  static NotificationType fromString(String? type) {
    switch (type) {
      case 'payment_receipt':
        return NotificationType.paymentReceipt;
      case 'budget_allocated':
      case 'allocate_budget':
        return NotificationType.budgetAllocated;
      case 'extra_disbursement_response':
      case 'extra_disbursement':
        return NotificationType.extraDisbursementResponse;
      case 'aid_distributed':
      case 'distribute_basket':
        return NotificationType.aidDistributed;
      case 'card_status_update':
      case 'eligibility_update':
        return NotificationType.cardStatusUpdate;
      default:
        return NotificationType.general;
    }
  }

  String get rawValue {
    switch (this) {
      case NotificationType.paymentReceipt:
        return 'payment_receipt';
      case NotificationType.budgetAllocated:
        return 'budget_allocated';
      case NotificationType.extraDisbursementResponse:
        return 'extra_disbursement_response';
      case NotificationType.aidDistributed:
        return 'aid_distributed';
      case NotificationType.cardStatusUpdate:
        return 'card_status_update';
      case NotificationType.general:
        return 'general';
    }
  }
}

class NotificationModel extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final String? referenceId;
  final double? amount;
  final bool isRead;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.referenceId,
    this.amount,
    required this.isRead,
    required this.timestamp,
    this.metadata,
  });

  factory NotificationModel.fromFirestore(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return NotificationModel(
      id: documentId,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? 'إشعار جديد',
      body: map['body'] as String? ?? '',
      type: NotificationType.fromString(map['type'] as String?),
      referenceId: map['referenceId'] as String? ?? map['refId'] as String?,
      amount: map['amount'] != null ? FirebaseParserUtils.parseDouble(map['amount']) : null,
      isRead: map['isRead'] as bool? ?? false,
      timestamp: FirebaseParserUtils.parseDate(map['timestamp']),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    String? referenceId,
    double? amount,
    bool? isRead,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      amount: amount ?? this.amount,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        body,
        type,
        referenceId,
        amount,
        isRead,
        timestamp,
      ];
}
