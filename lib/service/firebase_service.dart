import 'dart:convert';
import 'dart:ui';

import 'package:event_ticket/enum.dart';
import 'package:event_ticket/requests/auth_request.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/service/navigator_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:event_ticket/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

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
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        // Xử lý khi người dùng nhấn vào thông báo
        await handleNotificationClick(notificationResponse.payload);
      },
    );

    // Khởi chạy Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Xin quyền thông báo
    NotificationSettings settings = await fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    // Lắng nghe thông báo khi app chạy foreground, background, terminated
    setupInteractedMessage();

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
    const String webPushKey =
        'BLn_QRm18dAPaitPzlPdu3zXOt1f9LjPy426Yj6KZkONj0BE6eWNWgYvM_H_uUrf5Thd3718XXThQ0tJ6Gg1w88';
    // Lấy token
    try {
      String? token = await fcm.getToken(vapidKey: webPushKey);

      // Xóa token trên server nếu có
      if (token != null) {
        print("Xóa FCM Token: $token");
        _authRequest.deleteFCMTokenOnServer(token);
      }
    } catch (e) {
      print("Lỗi khi lấy token: $e");
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

  static Future<void> handleNotificationNavigation(RemoteMessage message,
      {bool fromBackground = true}) async {
    if (message.data.isEmpty) return;

    final NotificationType notificationType =
        NotificationType.values.firstWhere(
      (element) => element.value == message.data['type'],
      orElse: () => NotificationType.unknown,
    );
    if (notificationType == NotificationType.unknown) return;

    final context = navigatorKey.currentState?.context;
    if (context == null) return;

    switch (notificationType) {
      // Trường hợp vào ticket -> transfer ticket
      case NotificationType.ticketTransfer:
        if (fromBackground) {
          context.go(Routes.ticket);
        }
        context.push(Routes.transferTicket);
        break;

      // Trường hợp vào ticket -> ticket detail
      case NotificationType.checkIn:
      case NotificationType.ticketBooking:
      case NotificationType.ticketCancel:
      case NotificationType.paymentSuccess:
        if (fromBackground) {
          context.go(Routes.ticket);
        }
        final ticketId = message.data['ticketId'] as String?;
        if (ticketId != null) {
          context.push(Routes.getTicketDetailPath(ticketId));
        }
        break;

      // Trường hợp vào forum -> forum detail
      case NotificationType.commentReply:
        if (fromBackground) {
          context.go(Routes.forum);
        }
        final forumId = message.data['conversationId'] as String?;
        if (forumId != null) {
          context.push(Routes.getForumDetailPath(forumId));
        }
        break;

      // Trường hợp vào event -> event detail
      case NotificationType.newEvent:
      case NotificationType.eventUpdate:
        if (fromBackground) {
          context.go(Routes.event);
        }
        final eventId = message.data['eventId'] as String?;
        if (eventId != null) {
          context.push(Routes.getEventDetailPath(eventId));
        }
        break;
      default:
    }
  }

  static Future<void> setupInteractedMessage() async {
    // Xử lý khi app đang terminate
    RemoteMessage? initialMessage = await fcm.getInitialMessage();
    if (initialMessage != null) {
      await handleNotificationNavigation(initialMessage);
      // if (callback != null) callback(initialMessage);
      _notifyCallbacks(initialMessage); // Gọi callback
    }

    // Xử lý khi app ở background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await handleNotificationNavigation(message);
      // if (callback != null) callback(message);
      _notifyCallbacks(message); // Gọi callback
    });

    // Xử lý khi app ở foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // Hiển thị local notification
      await showLocalNotification(message);
      // if (callback != null) callback(message);
      _notifyCallbacks(message); // Gọi callback
    });
  }

  static Future<void> showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? '',
      message.notification?.body ?? '',
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  // Thêm sự kiện xử lý khi người dùng nhấn vào thông báo
  static Future<void> handleNotificationClick(String? payload) async {
    if (payload == null) return;

    try {
      // Chuẩn hóa payload thành JSON hợp lệ
      final String jsonPayload = payload
          .replaceAllMapped(RegExp(r'([a-zA-Z0-9_]+):'),
              (match) => '"${match[1]}":') // Thêm dấu ngoặc kép cho khóa
          .replaceAllMapped(
              RegExp(r':\s*([^,\}\s]+)'),
              (match) =>
                  ': "${match[1]}"') // Thêm dấu ngoặc kép cho giá trị chuỗi
          .replaceAll("'", '"'); // Thay dấu nháy đơn thành nháy kép

      // Decode payload
      final Map<String, dynamic> data =
          Map<String, dynamic>.from(jsonDecode(jsonPayload));
      final RemoteMessage simulatedMessage = RemoteMessage(data: data);

      // Gọi hàm điều hướng
      await handleNotificationNavigation(simulatedMessage,
          fromBackground: false);
    } catch (e) {
      print("Error decoding payload: $e");
    }
  }

  /////////////////////////////////////////////
  // callback
  // Danh sách các callback
  static final List<Function(RemoteMessage)> _onMessageCallbacks = [];

  // Đăng ký callback
  static void registerOnMessageCallback(Function(RemoteMessage) callback) {
    if (!_onMessageCallbacks.contains(callback)) {
      _onMessageCallbacks.add(callback);
    }
  }

  // Hủy đăng ký callback
  static void unregisterOnMessageCallback(Function(RemoteMessage) callback) {
    _onMessageCallbacks.remove(callback);
  }

  // Gọi tất cả callback
  static void _notifyCallbacks(RemoteMessage message) {
    for (final callback in _onMessageCallbacks) {
      callback(message);
    }
  }
}
