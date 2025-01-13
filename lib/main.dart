import 'package:event_ticket/router/router.dart';
import 'package:event_ticket/service/firebase_service.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Đặt hướng đứng cho ứng dụng
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Khởi tạo Firebase
  await FirebaseService.init();

  // Load file .env
  // await dotenv.load(fileName: ".env");

  // Chạy app
  runApp(const ProviderScope(child: TicketApp()));
}

class TicketApp extends StatelessWidget {
  const TicketApp({super.key});

  @override
  Widget build(BuildContext context) {
    //var isDarkMode = ref.watch(settingsProvider).isDarkMode;
    //var theme = isDarkMode ? newDarkMode : newLightMode;
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: const Locale('vi', 'VN'),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // Có thể thay đổi thành ThemeMode.system để theo hệ thống
      themeMode: ThemeMode.light,
    );
  }
}
