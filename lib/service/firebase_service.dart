import 'dart:ui';

import 'package:event_ticket/requests/auth_request.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:event_ticket/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  static final FirebaseMessaging fcm = FirebaseMessaging.instance;
  static final AuthRequest _authRequest = AuthRequest();

  static Future<void> init() async {
    // Khởi tạo Firebase
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    // Khởi tạo Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Đồng bộ token mới khi có thay đổi (gỡ app cài lại, xóa dữ liệu, ...)
    fcm.onTokenRefresh.listen((newToken) {
      print("Token mới: $newToken");
      _authRequest.sendFCMTokenToServer(newToken);
    }).onError((err) {
      print("Error getting FCM token: $err");
    });

    // Xin quyền thông báo trên IOS (Android không cần thiết)
    NotificationSettings settings = await fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    // Đăng ký nhận thông báo forceround
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
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

  // Code xử lý trong này, không dùng anymous function
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    // await Firebase.initializeApp();

    print("Handling a background message: ${message.messageId}");
  }
}
