import 'package:event_ticket/models/route_page.dart';
import 'package:event_ticket/pages/auth/login_screen.dart';
import 'package:event_ticket/pages/auth/register_screen.dart';
import 'package:event_ticket/pages/home/home_screen.dart';
import 'package:event_ticket/pages/profile/edit_profile_screen.dart';
import 'package:event_ticket/pages/profile/profile_screen.dart';
import 'package:event_ticket/pages/ticket/ticket_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const List<RoutePage> allRoutePages = [
  RoutePage(0, '/home', 'Home', Icons.home_outlined, Icons.home, Colors.teal),
  RoutePage(1, '/ticket', 'Ticket', Icons.airplane_ticket_outlined,
      Icons.airplane_ticket, Colors.cyan),
  RoutePage(2, '/profile', 'Profile', Icons.person_outlined, Icons.person,
      Colors.orange),
];

final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/home',
  navigatorKey: GlobalKey<NavigatorState>(),
  routes: [
    StatefulShellRoute.indexedStack(
      // Các màn hình chính
      branches: [
        StatefulShellBranch(navigatorKey: GlobalKey<NavigatorState>(), routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
        ]),
        StatefulShellBranch(navigatorKey: GlobalKey<NavigatorState>(), routes: [
          GoRoute(
            path: '/ticket',
            builder: (context, state) => const TicketScreen(),
          ),
        ]),
        StatefulShellBranch(navigatorKey: GlobalKey<NavigatorState>(), routes: [
          GoRoute(
            path: '/profile',
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
      path: '/login',
      builder: (context, state) {
        final extraData = state.extra as Map<String, String>?;
        return LoginScreen(
          email: extraData?['email'],
          password: extraData?['password'],
        );
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) {
        final extraData = state.extra as Map<String, dynamic>?;
        return RegisterScreen(
          email: extraData?['email'],
          password: extraData?['password'],
        );
      },
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),

    // GoRoute(
    //     path: '/splash',
    //     builder: (context, state) {
    //       return const SplashScreen();
    //     }),
    // GoRoute(
    //     path: '/learn/:chapter',
    //     builder: (context, state) {
    //       final chapter = int.parse(state.pathParameters['chapter']!);
    //       return LearnScreen(chapter: chapter);
    //     }),
    // GoRoute(
    //     path: '/chose-licence-class',
    //     builder: (context, state) {
    //       return const ChoseLicencesClassScreen();
    //     }),
    // GoRoute(
    //     path: '/signs',
    //     builder: (context, state) {
    //       return const SignsScreen();
    //     }),
    // GoRoute(
    //     path: '/test-list',
    //     builder: (context, state) {
    //       return const TestListScreen();
    //     }),
    // GoRoute(
    //     path: '/test-info/:testId',
    //     builder: (context, state) {
    //       final testId = state.pathParameters['testId']!;
    //       return TestInfoScreen(testId: testId);
    //     }),
    // GoRoute(
    //     path: '/test/:testId',
    //     builder: (context, state) {
    //       final testId = state.pathParameters['testId']!;
    //       return TestScreen(testId: testId);
    //     }),
    // GoRoute(
    //     path: '/test-result/:testId',
    //     builder: (context, state) {
    //       final testId = state.pathParameters['testId']!;
    //       return TestResultScreen(testId: testId);
    //     }),
    // GoRoute(
    //     path: '/tips',
    //     builder: (context, state) {
    //       return const TipsScreen();
    //     }),
  ],
);
