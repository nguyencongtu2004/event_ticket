import 'package:event_ticket/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  // Đặt hướng sáng cho ứng dụng
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const ProviderScope(child: TicketApp()));
}

class TicketApp extends ConsumerWidget {
  const TicketApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //var isDarkMode = ref.watch(settingsProvider).isDarkMode;
    //var theme = isDarkMode ? newDarkMode : newLightMode;
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      //theme: theme,
    );
  }
}
