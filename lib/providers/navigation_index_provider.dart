import 'package:event_ticket/enum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_ticket/router/routes.dart';

class NavigationIndexNotifier extends StateNotifier<int> {
  NavigationIndexNotifier() : super(0); // Khởi tạo index mặc định là 0

  void setIndex(int newIndex) {
    state = newIndex;
  }

  void setIndexForRoute(Roles role, String? path) {
    if (role == Roles.ticketBuyer) {
      switch (path) {
        case Routes.event:
          state = 0;
          break;
        case Routes.ticket:
          state = 1;
          break;
        case Routes.forum:
          state = 2;
          break;
        case Routes.profile:
          state = 3;
          break;
        default:
          state = 0; // Default nếu không khớp
      }
    } else if (role == Roles.eventCreator) {
      switch (path) {
        case Routes.eventManagement:
          state = 0;
          break;
        case Routes.checkIn:
          state = 1;
          break;
        case Routes.profile:
          state = 2;
          break;
        default:
          state = 0; // Default nếu không khớp
      }
    } else if (role == Roles.admin) {
      switch (path) {
        case Routes.admin:
          state = 0;
          break;
        case Routes.profile:
          state = 1;
          break;
        default:
          state = 0; // Default nếu không khớp
      }
    } else {
      state = 0; // Default nếu không khớp
    }
  }
}

final navigationIndexProvider =
    StateNotifierProvider<NavigationIndexNotifier, int>(
        (ref) => NavigationIndexNotifier());
