import 'package:event_ticket/pages/auth/login_screen.dart';
import 'package:event_ticket/pages/auth/register_screen.dart';
import 'package:event_ticket/pages/event/event_detail_screen.dart';
import 'package:event_ticket/pages/event/event_management_screen.dart';
import 'package:event_ticket/pages/home/buyer_home_screen.dart';
import 'package:event_ticket/pages/home/creator_home_screen.dart';
import 'package:event_ticket/pages/profile/edit_profile_screen.dart';
import 'package:event_ticket/pages/profile/profile_screen.dart';
import 'package:event_ticket/pages/splash/splash_screen.dart';
import 'package:event_ticket/pages/ticket/ticket_screen.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: Routes.splash,
  navigatorKey: GlobalKey<NavigatorState>(),
  routes: [
    //shellRoute,
    GoRoute(
      path: Routes.buyerHome,
      builder: (context, state) => const BuyerHomeScreen(),
    ),
    GoRoute(
      path: Routes.creatorHome,
      builder: (context, state) => const CreatorHomeScreen(),
    ),
    GoRoute(
      path: Routes.ticket,
      builder: (context, state) => const TicketScreen(),
    ),
    GoRoute(
      path: Routes.ticket,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
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
    GoRoute(
      path: Routes.eventManagement,
      builder: (context, state) => const EventManagementScreen(),
    ),
  ],
);
