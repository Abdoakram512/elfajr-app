import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level background message handler required by Firebase Messaging
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint('FCM Background message received: ${message.messageId}');
}

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'qout_high_importance_channel';
  static const String channelName = 'إشعارات منظومة قوت';
  static const String channelDescription =
      'إشعارات وصولات التحويل وشحن العهدة وعمليات الصرف';

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

  bool _isInitialized = false;
  StreamSubscription<String>? _tokenRefreshSub;

  /// Initialize Push Notifications & Local Notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Register Background Notification Handler cleanly inside the service
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 2. Request Notification Permissions
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint(
        'FCM Permission status: ${settings.authorizationStatus}',
      );

      // 3. Initialize Local Notifications Plugin
      const androidInitSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinInitSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidInitSettings,
        iOS: darwinInitSettings,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
        },
      );

      // 4. Create Android Notification Channel
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_androidChannel);

      // 5. Set Foreground Notification Presentation Options for iOS
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 6. Listen to Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
          'FCM Foreground message received: ${message.notification?.title}',
        );
        _handleForegroundMessage(message);
      });

      // 7. Handle notification click when app is opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('FCM onMessageOpenedApp clicked: ${message.data}');
      });

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully!');
    } catch (e) {
      debugPrint('NotificationService initialization error: $e');
    }
  }

  /// Handle incoming foreground messages and display high-priority local banner
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    final title = notification?.title ?? message.data['title'] ?? 'إشعار جديد';
    final body = notification?.body ?? message.data['body'] ?? '';

    _localNotifications.show(
      id: notification.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data.toString(),
    );
  }

  /// Show a manual custom local notification banner
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Register and synchronize FCM Token in Firestore for target user
  Future<void> syncFCMToken(String userId) async {
    if (userId.isEmpty) return;

    try {
      final token = await _fcm.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint('FCM Token for user $userId: $token');
        await _saveTokenToFirestore(userId, token);
      }

      // Listen for token refresh events
      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = _fcm.onTokenRefresh.listen((newToken) async {
        debugPrint('FCM Token refreshed for user $userId: $newToken');
        await _saveTokenToFirestore(userId, newToken);
      });
    } catch (e) {
      debugPrint('Error syncing FCM token: $e');
    }
  }

  Future<void> _saveTokenToFirestore(String userId, String token) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'fcmToken': token,
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastFcmTokenUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to save FCM token to Firestore: $e');
    }
  }

  void dispose() {
    _tokenRefreshSub?.cancel();
  }
}
