import 'dart:ui';

import 'package:event_ticket/requests/auth_request.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:event_ticket/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseService {
  static final FirebaseMessaging fcm = FirebaseMessaging.instance;
  static final AuthRequest _authRequest = AuthRequest();
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Khởi tạo Firebase
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    // Cấu hình FlutterLocalNotifications
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Icon cho thông báo
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await _localNotificationsPlugin.initialize(initializationSettings);

    // Khởi chạy Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Xin quyền thông báo trên iOS
    NotificationSettings settings = await fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    // Lắng nghe thông báo khi app chạy foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Nhận thông báo khi app chạy foreground');
      _showLocalNotification(message);
    });

    // Đăng ký nhận thông báo background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> syncFCMToken() async {
    // Lấy token
    String? token = await fcm.getToken();

    // Gửi token lên server nếu có
    if (token != null) {
      print("Gửi FCM Token: $token");
      _authRequest.sendFCMTokenToServer(token);
    }
  }

  static Future<void> deleteFCMTokenOnServer() async {
    // Lấy token
    String? token = await fcm.getToken();

    // Xóa token trên server nếu có
    if (token != null) {
      print("Xóa FCM Token: $token");
      _authRequest.deleteFCMTokenOnServer(token);
    }
  }

  // Code xử lý khi nhân thông báo trên background trong này, không dùng anymous function
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    // await Firebase.initializeApp();

    print("Handling a background message: ${message.messageId}");
  }

  // Hiển thị thông báo local (mới cấu hình trên Android)
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'default_channel', // ID channel
      'General Notifications', // Tên channel
      channelDescription: 'This channel is used for general notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _localNotificationsPlugin.show(
      DateTime.now().microsecond, // ID của thông báo
      message.notification?.title ?? "Thông báo",
      message.notification?.body ?? "Nội dung thông báo",
      notificationDetails,
    );
  }

  // Cấu hình khi ấn vào thông báo
  static Future<void> setupInteractedMessage(
      Function(RemoteMessage) onMessage) async {
    // Cấu hình khi ấn vào thông báo khi app terminated
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) onMessage(initialMessage);

    // Cấu hình khi ấn vào thông báo khi app chạy background
    FirebaseMessaging.onMessageOpenedApp.listen(onMessage);
  }
}
