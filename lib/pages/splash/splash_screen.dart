import 'package:event_ticket/enum.dart';
import 'package:event_ticket/providers/notification_provider.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/service/auth_service.dart';
import 'package:event_ticket/service/firebase_service.dart';
import 'package:event_ticket/utils/provider_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
    // Khởi tạo Firebase
    await FirebaseService.init();

    // Kiểm tra xem người dùng đã đăng nhập chưa
    final token = await AuthService.getAuthBearerToken();
    if (token.isEmpty) {
      context.go(Routes.login);
      return;
    }

    // Khởi tạo Provider từ utils
    initializeProviders(ref);

    // Đồng bộ FCM token vào server
    FirebaseService.syncFCMToken();

    // Đăng ký callback khi có thông báo
    FirebaseService.registerOnMessageCallback((message) {
      print('New Message: ${message.data}');

      // TODO: fix không cập nhật số thông báo
      //ref.refresh(notificationProvider.future);
    });

    // Lấy role của người dùng và chuyển hướng đến trang tương ứng
    final role = await AuthService.getRole();
    print(role.name);
    if (role == Roles.ticketBuyer) {
      context.go(Routes.event);
    } else {
      context.go(Routes.eventManagement);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Splash Screen...'),
      ),
    );
  }
}
