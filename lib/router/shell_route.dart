import 'package:event_ticket/pages/admin/admin_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_ticket/pages/check_in/check_in_screen.dart';
import 'package:event_ticket/pages/event/event_management_screen.dart';
import 'package:event_ticket/pages/event/event_screen.dart';
import 'package:event_ticket/pages/forum/forum_screen.dart';
import 'package:event_ticket/pages/profile/profile_screen.dart';
import 'package:event_ticket/pages/ticket/ticket_screen.dart';
import 'package:event_ticket/providers/navigation_index_provider.dart';
import 'package:event_ticket/providers/role_provider.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/enum.dart';

final shellRoute = ShellRoute(
  //navigatorKey: navigatorKey,
  builder: (context, state, child) {
    return Consumer(
      builder: (context, ref, _) {
        final roleAsync = ref.watch(roleProvider);
        final currentIndex = ref.watch(navigationIndexProvider);

        return roleAsync.when(
          data: (role) {
            // Đồng bộ navigation index với path
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(navigationIndexProvider.notifier)
                  .setIndexForRoute(role, state.uri.path);
            });
            return LayoutBuilder(builder: (context, constraints) {
              final isLargeScreen = constraints.maxWidth > 600;

              void onDestinationSelected(int index) {
                ref.read(navigationIndexProvider.notifier).setIndex(index);
                if (role == Roles.ticketBuyer) {
                  switch (index) {
                    case 0:
                      context.go(Routes.event);
                      break;
                    case 1:
                      context.go(Routes.ticket);
                      break;
                    case 2:
                      context.go(Routes.forum);
                      break;
                    case 3:
                      context.go(Routes.profile);
                      break;
                  }
                } else if (role == Roles.eventCreator) {
                  switch (index) {
                    case 0:
                      context.go(Routes.eventManagement);
                      break;
                    case 1:
                      context.go(Routes.checkIn);
                      break;
                    case 2:
                      context.go(Routes.profile);
                      break;
                  }
                } else if (role == Roles.admin) {
                  switch (index) {
                    case 0:
                      context.go(Routes.admin);
                      break;
                    case 1:
                      context.go(Routes.profile);
                      break;
                  }
                }
              }

              final destinations = role == Roles.ticketBuyer
                  ? const [
                      NavigationDestination(
                          icon: Icon(Icons.event), label: 'Event'),
                      NavigationDestination(
                          icon: Icon(Icons.airplane_ticket), label: 'Ticket'),
                      NavigationDestination(
                          icon: Icon(Icons.forum), label: 'Forum'),
                      NavigationDestination(
                          icon: Icon(Icons.person), label: 'Profile'),
                    ]
                  : role == Roles.eventCreator
                      ? const [
                          NavigationDestination(
                              icon: Icon(Icons.manage_accounts),
                              label: 'Event Management'),
                          NavigationDestination(
                              icon: Icon(Icons.check_circle),
                              label: 'Check-in'),
                          NavigationDestination(
                              icon: Icon(Icons.person), label: 'Profile'),
                        ]
                      : const [
                          NavigationDestination(
                              icon: Icon(Icons.admin_panel_settings),
                              label: 'Admin'),
                          NavigationDestination(
                              icon: Icon(Icons.person), label: 'Profile'),
                        ];

              final navigationRailDestinations = role == Roles.ticketBuyer
                  ? const [
                      NavigationRailDestination(
                          icon: Icon(Icons.event), label: Text('Event')),
                      NavigationRailDestination(
                          icon: Icon(Icons.airplane_ticket),
                          label: Text('Ticket')),
                      NavigationRailDestination(
                          icon: Icon(Icons.forum), label: Text('Forum')),
                      NavigationRailDestination(
                          icon: Icon(Icons.person), label: Text('Profile')),
                    ]
                  : role == Roles.eventCreator
                      ? const [
                          NavigationRailDestination(
                              icon: Icon(Icons.manage_accounts),
                              label: Text('Event Management')),
                          NavigationRailDestination(
                              icon: Icon(Icons.check_circle),
                              label: Text('Check-in')),
                          NavigationRailDestination(
                              icon: Icon(Icons.person), label: Text('Profile')),
                        ]
                      : const [
                          NavigationRailDestination(
                              icon: Icon(Icons.admin_panel_settings),
                              label: Text('Admin')),
                          NavigationRailDestination(
                              icon: Icon(Icons.person), label: Text('Profile')),
                        ];

              return Scaffold(
                body: isLargeScreen
                    ? Row(
                        children: [
                          NavigationRail(
                            selectedIndex: currentIndex,
                            onDestinationSelected: onDestinationSelected,
                            destinations: navigationRailDestinations,
                            labelType: NavigationRailLabelType.all,
                            groupAlignment: -0.8,
                          ),
                          Expanded(
                            child: child,
                          ),
                        ],
                      )
                    : child,
                bottomNavigationBar: isLargeScreen
                    ? null
                    : NavigationBar(
                        selectedIndex: currentIndex,
                        onDestinationSelected: onDestinationSelected,
                        destinations: destinations,
                      ),
              );
            });
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
      },
    );
  },
  routes: [
    GoRoute(
      path: Routes.event,
      builder: (context, state) => const EventScreen(),
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: EventScreen()),
    ),
    GoRoute(
      path: Routes.ticket,
      builder: (context, state) {
        final detailId = state.uri.queryParameters['detailId'];
        return TicketScreen(detailId: detailId);
      },
      pageBuilder: (context, state) {
        final detailId = state.uri.queryParameters['detailId'];
        return NoTransitionPage(child: TicketScreen(detailId: detailId));
      },
    ),
    GoRoute(
      path: Routes.profile,
      builder: (context, state) => const ProfileScreen(),
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: ProfileScreen()),
    ),
    GoRoute(
      path: Routes.eventManagement,
      builder: (context, state) => const EventManagementScreen(),
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: EventManagementScreen()),
    ),
    GoRoute(
      path: Routes.checkIn,
      builder: (context, state) => const CheckInScreen(),
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: CheckInScreen()),
    ),
    GoRoute(
      path: Routes.forum,
      builder: (context, state) => const ForumScreen(),
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: ForumScreen()),
    ),
    GoRoute(
      path: Routes.admin,
      builder: (context, state) => const AdminScreen(),
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: AdminScreen()),
    ),
  ],
);
