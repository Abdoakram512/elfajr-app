import 'package:equatable/equatable.dart';
import '../../../core/models/notification_model.dart';

enum NotificationsStatus { initial, loading, loaded, error }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final List<NotificationModel> notifications;
  final int unreadCount;
  final NotificationModel? latestIncomingNotification;
  final String? errorMessage;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.latestIncomingNotification,
    this.errorMessage,
  });

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationModel>? notifications,
    int? unreadCount,
    NotificationModel? latestIncomingNotification,
    bool clearLatestIncoming = false,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      latestIncomingNotification: clearLatestIncoming
          ? null
          : (latestIncomingNotification ?? this.latestIncomingNotification),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        notifications,
        unreadCount,
        latestIncomingNotification,
        errorMessage,
      ];
}
