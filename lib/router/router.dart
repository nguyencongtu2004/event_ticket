import 'package:event_ticket/models/conversasion.dart';
import 'package:event_ticket/models/event.dart';
import 'package:event_ticket/models/ticket.dart';
import 'package:event_ticket/pages/auth/login_screen.dart';
import 'package:event_ticket/pages/auth/register_screen.dart';
import 'package:event_ticket/pages/event/add_event_screen.dart';
import 'package:event_ticket/pages/event/edit_event_screen.dart';
import 'package:event_ticket/pages/event/event_detail_screen.dart';
import 'package:event_ticket/pages/event/event_list_screen.dart';
import 'package:event_ticket/pages/event/search_event_screen.dart';
import 'package:event_ticket/pages/forum/forum_detail_screen.dart';
import 'package:event_ticket/pages/notification/notification_screen.dart';
import 'package:event_ticket/pages/profile/edit_profile_screen.dart';
import 'package:event_ticket/pages/splash/splash_screen.dart';
import 'package:event_ticket/pages/ticket/ticket_detail_screen.dart';
import 'package:event_ticket/pages/ticket/transfer_ticket_screen.dart';
import 'package:event_ticket/pages/ticket/transfer_ticket_search_screen.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/router/shell_route.dart';
import 'package:event_ticket/service/navigator_service.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: Routes.splash,
  navigatorKey: navigatorKey,
  routes: [
    shellRoute,
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
    GoRoute(
      path: Routes.eventList,
      builder: (context, state) => EventListScreen(
        title: state.uri.queryParameters['title'] ?? 'Events',
        sortBy: state.uri.queryParameters['sortBy'] ?? 'date',
      ),
    ),
    GoRoute(
      path: Routes.ticketDetail,
      builder: (context, state) {
        final ticketId = state.pathParameters['ticketId']!;
        return TicketDetailScreen(ticketId: ticketId);
      },
    ),
    GoRoute(
      path: Routes.transferTicketSearch,
      builder: (context, state) {
        final ticket = state.extra as Ticket?;
        return TransferTicketSearchScreen(ticket: ticket);
      },
    ),
    GoRoute(
      path: Routes.transferTicket,
      builder: (context, state) {
        return const TransferTicketScreen();
      },
    ),
    GoRoute(
      path: Routes.forumDetail,
      builder: (context, state) {
        final forumId = state.pathParameters['forumId']!;
        final conversasion = state.extra as Conversasion?;
        return ForumDetailScreen(forumId: forumId, conversasion: conversasion);
      },
    ),
    GoRoute(
      path: Routes.notification,
      builder: (context, state) {
        return const NotificationScreen();
      },
    ),
    GoRoute(
      path: Routes.searchEvent,
      builder: (context, state) {
        return const SearchEventScreen();
      },
    ),
  ],
);
