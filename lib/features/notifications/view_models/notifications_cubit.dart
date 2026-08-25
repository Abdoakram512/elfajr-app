import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/services/audio_feedback_service.dart';
import '../../../core/services/notification_service.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _notificationsSub;
  String? _currentUserId;
  bool _isInitialSnapshot = true;
  final Set<String> _knownNotificationIds = {};

  NotificationsCubit({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(const NotificationsState());

  /// Starts listening to real-time notification stream for active user
  void startListening(String userId) {
    if (userId.isEmpty) return;
    if (_currentUserId == userId && _notificationsSub != null) return;

    _currentUserId = userId;
    _isInitialSnapshot = true;
    _knownNotificationIds.clear();
    _notificationsSub?.cancel();

    debugPrint('[NotificationsCubit] Starting Firestore listener for user: $userId');
    emit(state.copyWith(status: NotificationsStatus.loading));

    _notificationsSub = _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
      (snapshot) {
        final list = <NotificationModel>[];

        for (final doc in snapshot.docs) {
          try {
            final model = NotificationModel.fromFirestore(doc.data(), doc.id);
            list.add(model);
          } catch (e) {
            debugPrint('Error parsing notification doc ${doc.id}: $e');
          }
        }

        // Sort descending by timestamp
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        final unread = list.where((n) => !n.isRead).length;
        debugPrint('[NotificationsCubit] Fetched ${list.length} notifications ($unread unread) for $userId');

        // Detect newly arrived notifications (skip initial batch)
        NotificationModel? newestIncoming;
        if (!_isInitialSnapshot) {
          for (final n in list) {
            if (!_knownNotificationIds.contains(n.id) && !n.isRead) {
              newestIncoming = n;
              _triggerNotificationAlert(n);
              break;
            }
          }
        }

        // Update known IDs
        _knownNotificationIds.clear();
        for (final n in list) {
          _knownNotificationIds.add(n.id);
        }

        _isInitialSnapshot = false;

        emit(state.copyWith(
          status: NotificationsStatus.loaded,
          notifications: list,
          unreadCount: unread,
          latestIncomingNotification: newestIncoming,
        ));
      },
      onError: (err) {
        debugPrint('Notifications stream error: $err');
        emit(state.copyWith(
          status: NotificationsStatus.error,
          errorMessage: err.toString(),
        ));
      },
    );
  }

  /// Triggers sound & local notification alert for an incoming notification
  void _triggerNotificationAlert(NotificationModel notification) {
    AudioFeedbackType audioType = AudioFeedbackType.notification;
    if (notification.type == NotificationType.paymentReceipt ||
        notification.type == NotificationType.budgetAllocated) {
      audioType = AudioFeedbackType.cashReceipt;
    } else if (notification.type == NotificationType.extraDisbursementResponse) {
      audioType = AudioFeedbackType.alert;
    }

    // 1. Play Audio Chime
    AudioFeedbackService.instance.playNotificationSound(type: audioType);

    // 2. Fire System Tray Local Notification
    NotificationService.instance.showLocalNotification(
      title: notification.title,
      body: notification.body,
      payload: notification.type.rawValue,
      audioType: audioType,
      playSound: false, // already played above
    );
  }

  /// Dismiss the latest incoming banner from state
  void dismissLatestIncoming() {
    emit(state.copyWith(clearLatestIncoming: true));
  }

  /// Marks a specific notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to mark notification as read: $e');
    }
  }

  /// Marks all unread notifications as read
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;
    try {
      final unreadDocs = state.notifications.where((n) => !n.isRead);
      final batch = _firestore.batch();
      for (final n in unreadDocs) {
        final ref = _firestore.collection('notifications').doc(n.id);
        batch.update(ref, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Failed to mark all notifications as read: $e');
    }
  }

  /// Deletes a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      debugPrint('Failed to delete notification: $e');
    }
  }

  /// Stops listening to notifications
  void stopListening() {
    _notificationsSub?.cancel();
    _notificationsSub = null;
    _currentUserId = null;
    _isInitialSnapshot = true;
    _knownNotificationIds.clear();
    emit(const NotificationsState());
  }

  @override
  Future<void> close() {
    _notificationsSub?.cancel();
    return super.close();
  }
}
