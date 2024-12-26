import 'package:event_ticket/enum.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/service/auth_service.dart';
import 'package:event_ticket/service/firebase_service.dart';
import 'package:event_ticket/utils/provider_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Khởi tạo animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    initApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    });

    // Lấy role của người dùng và chuyển hướng đến trang tương ứng
    final role = await AuthService.getRole();
    
    // Chuyển hướng đến trang chính
    switch (role) {
      case Roles.eventCreator:
        context.go(Routes.eventManagement);
        break;
      case Roles.ticketBuyer:
        context.go(Routes.event);
        break;
      case Roles.admin:
        context.go(Routes.admin);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Event Ticket',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
