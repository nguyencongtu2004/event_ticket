import 'package:event_ticket/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  // Đặt hướng đứng cho ứng dụng
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
      //theme: theme,
    );
  }
}
