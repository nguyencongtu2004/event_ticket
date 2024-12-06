import 'package:event_ticket/models/route_page.dart';
import 'package:event_ticket/pages/auth/login_screen.dart';
import 'package:event_ticket/pages/auth/register_screen.dart';
import 'package:event_ticket/pages/event/event_detail_screen.dart';
import 'package:event_ticket/pages/home/home_screen.dart';
import 'package:event_ticket/pages/profile/edit_profile_screen.dart';
import 'package:event_ticket/pages/profile/profile_screen.dart';
import 'package:event_ticket/pages/ticket/ticket_screen.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


const List<RoutePage> allRoutePages = [
  RoutePage(0, Routes.home, 'Home', Icons.home_outlined, Icons.home, Colors.teal),
  RoutePage(1, Routes.ticket, 'Ticket', Icons.airplane_ticket_outlined,
      Icons.airplane_ticket, Colors.cyan),
  RoutePage(2, Routes.profile, 'Profile', Icons.person_outlined, Icons.person,
      Colors.orange),
];

final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: Routes.home,
  navigatorKey: GlobalKey<NavigatorState>(),
  routes: [
    StatefulShellRoute.indexedStack(
      // Các màn hình chính
      branches: [
        StatefulShellBranch(navigatorKey: GlobalKey<NavigatorState>(), routes: [
          GoRoute(
            path: Routes.home,
            builder: (context, state) => const HomeScreen(),
          ),
        ]),
        StatefulShellBranch(navigatorKey: GlobalKey<NavigatorState>(), routes: [
          GoRoute(
            path: Routes.ticket,
            builder: (context, state) => const TicketScreen(),
          ),
        ]),
        StatefulShellBranch(navigatorKey: GlobalKey<NavigatorState>(), routes: [
          GoRoute(
            path: Routes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ])
      ],
      // Thanh điều hướng dưới cùng
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: NavigationBar(
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            height: 60,
            indicatorColor: allRoutePages
                .firstWhere((element) => element.route == state.fullPath)
                .color
                .withOpacity(0.1),
            selectedIndex: allRoutePages
                .indexWhere((element) => element.route == state.fullPath),
            onDestinationSelected: (index) {
              // Refresh lại màn hình khi chuyển đổi
              router.refresh();
              context.go(allRoutePages[index].route);
            },
            destinations: allRoutePages.map<NavigationDestination>(
              (RoutePage routePage) {
                return NavigationDestination(
                  icon: Icon(routePage.icon, color: routePage.color, size: 35),
                  label: routePage.title,
                  selectedIcon: Icon(routePage.selectedIcon,
                      color: routePage.color, size: 35),
                  tooltip: routePage.title,
                );
              },
            ).toList(),
          ),
        );
      },
    ),
    // Các màn hình khác
    GoRoute(
      path: Routes.login,
      builder: (context, state) {
        final extraData = state.extra as Map<String, String>?;
        return LoginScreen(
          email: extraData?['email'],
          password: extraData?['password'],
        );
      },
    ),
    GoRoute(
      path: Routes.register,
      builder: (context, state) {
        final extraData = state.extra as Map<String, dynamic>?;
        return RegisterScreen(
          email: extraData?['email'],
          password: extraData?['password'],
        );
      },
    ),
    GoRoute(
      path: Routes.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: Routes.eventDetail,
      builder: (context, state) {
        final eventId = state.pathParameters['eventId']!;
        return EventDetailScreen(eventId: eventId);
      },
    ),
  ],
);
