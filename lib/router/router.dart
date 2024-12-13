import 'package:event_ticket/models/event.dart';
import 'package:event_ticket/pages/auth/login_screen.dart';
import 'package:event_ticket/pages/auth/register_screen.dart';
import 'package:event_ticket/pages/event/add_event_screen.dart';
import 'package:event_ticket/pages/event/edit_event_screen.dart';
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
      builder: (context, state) {
        //final index = state.extra as int? ?? 0;
        final page = state.uri.queryParameters['page'] ?? '0';
        int index = int.tryParse(page) ?? 0;
        if (index < 0) index = 0;
        if (index > 2) index = 2;
        return BuyerHomeScreen(index: index);
      },
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
      path: Routes.profile,
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
        final canEdit = state.extra as bool?;
        return EventDetailScreen(eventId: eventId, canEdit: canEdit ?? false);
      },
    ),
    GoRoute(
      path: Routes.eventManagement,
      builder: (context, state) => const EventManagementScreen(),
    ),
    GoRoute(
      path: Routes.createEvent,
      builder: (context, state) => const AddEventScreen(),
    ),
    GoRoute(
      path: Routes.editEvent,
      builder: (context, state) {
        final event = state.extra as Event;
        return EditEventScreen(event: event);
      },
    ),
  ],
);
