import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:chefkit/common/config.dart';
import 'package:chefkit/common/token_storage.dart';
import 'package:chefkit/common/navigation_service.dart';

/// Check if Firebase is supported on current platform
bool get isFirebaseSupported {
  if (kIsWeb) return true;
  if (Platform.isAndroid || Platform.isIOS) return true;
  return false;
}

/// Top-level background message handler
/// Must be a top-level function (not a class method)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Only run on supported platforms
  if (!isFirebaseSupported) return;

  // Initialize Firebase for background handler
  await Firebase.initializeApp();
  // print('[FCM Background] Message received: ${message.messageId}');
  // print('[FCM Background] Title: ${message.notification?.title}');
  // print('[FCM Background] Body: ${message.notification?.body}');
  // print('[FCM Background] Data: ${message.data}');
}

/// Firebase Cloud Messaging Service
/// Handles FCM token registration, message handling, and local notifications
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final TokenStorage _tokenStorage = TokenStorage();

  String? _fcmToken;
  bool _isInitialized = false;

  /// Get the current FCM token
  String? get fcmToken => _fcmToken;

  /// Initialize Firebase Messaging
  /// Call this after Firebase.initializeApp() in main.dart
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Skip initialization on unsupported platforms
    if (!isFirebaseSupported) {
      // print('[FCM] Firebase not supported on this platform');
      return;
    }

    try {
      _messaging = FirebaseMessaging.instance;

      // Request permission for notifications
      await _requestPermission();

      // Initialize local notifications for foreground messages
      await _initializeLocalNotifications();

      // Get FCM token
      await _getAndSaveToken();

      // Listen for token refresh
      _messaging!.onTokenRefresh.listen(_handleTokenRefresh);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app is in background/terminated
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if app was opened from a terminated state notification
      final initialMessage = await _messaging!.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      _isInitialized = true;
      // print('[FCM] Firebase Messaging initialized successfully');
    } catch (e) {
      // print('[FCM] Error initializing Firebase Messaging: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    final settings = await _messaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // print('[FCM] Permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      // print('[FCM] User denied notification permission');
    }
  }

  /// Initialize local notifications for showing foreground messages
  Future<void> _initializeLocalNotifications() async {
    // Android initialization
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'chef_kit_notifications',
        'Chef Kit Notifications',
        description: 'Notifications for Chef Kit app',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  /// Get the FCM token and save it
  Future<void> _getAndSaveToken() async {
    try {
      _fcmToken = await _messaging!.getToken();
      // print('[FCM] Token obtained: $_fcmToken');

      // Automatically register token if user is logged in
      await registerTokenWithBackend();
    } catch (e) {
      // print('[FCM] Error getting token: $e');
    }
  }

  /// Handle token refresh
  Future<void> _handleTokenRefresh(String newToken) async {
    // print('[FCM] Token refreshed: $newToken');
    _fcmToken = newToken;
    await registerTokenWithBackend();
  }

  /// Register FCM token with the backend
  /// Call this after user logs in
  Future<bool> registerTokenWithBackend() async {
    if (_fcmToken == null) {
      // print('[FCM] No token to register');
      return false;
    }

    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null) {
      // print('[FCM] User not logged in, skipping token registration');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/notifications/token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'token': _fcmToken}),
      );

      if (response.statusCode == 200) {
        // print('[FCM] Token registered with backend successfully');
        return true;
      } else {
        // print(
          // '[FCM] Failed to register token: ${response.statusCode} ${response.body}',
        // );
        return false;
      }
    } catch (e) {
      // print('[FCM] Error registering token with backend: $e');
      return false;
    }
  }

  /// Handle foreground messages - show local notification
  void _handleForegroundMessage(RemoteMessage message) {
    // print('[FCM Foreground] Message received: ${message.messageId}');
    // print('[FCM Foreground] Title: ${message.notification?.title}');
    // print('[FCM Foreground] Body: ${message.notification?.body}');
    // print('[FCM Foreground] Data: ${message.data}');

    final notification = message.notification;
    if (notification != null) {
      _showLocalNotification(
        title: notification.title ?? 'Chef Kit',
        body: notification.body ?? '',
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Show a local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'chef_kit_notifications',
      'Chef Kit Notifications',
      channelDescription: 'Notifications for Chef Kit app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Handle notification tap from FirebaseMessaging (background/terminated)
  void _handleNotificationTap(RemoteMessage message) {
    // print('[FCM] Notification tapped: ${message.data}');
    NavigationService.handleNotificationNavigation(message.data);
  }

  /// Handle local notification tap (foreground)
  void _onLocalNotificationTap(NotificationResponse response) {
    // print('[FCM] Local notification tapped: ${response.payload}');
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        // print('[FCM] Notification data: $data');
        NavigationService.handleNotificationNavigation(data);
      } catch (e) {
        // print('[FCM] Error parsing notification payload: $e');
        // Fallback to notifications page
        NavigationService.navigateToNotifications();
      }
    } else {
      // No payload, go to notifications
      NavigationService.navigateToNotifications();
    }
  }

  /// Unregister token (call on logout)
  Future<void> unregisterToken() async {
    // Optionally notify backend to remove this device token
    // For now, we just clear the local reference
    _fcmToken = null;
    // print('[FCM] Token unregistered');
  }
}
