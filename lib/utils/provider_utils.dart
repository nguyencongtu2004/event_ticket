import 'package:event_ticket/providers/checked_in_ticket_provider.dart';
import 'package:event_ticket/providers/event_management_provider.dart';
import 'package:event_ticket/providers/event_provider.dart';
import 'package:event_ticket/providers/forum_provider.dart';
import 'package:event_ticket/providers/navigation_index_provider.dart';
import 'package:event_ticket/providers/notification_provider.dart';
import 'package:event_ticket/providers/role_provider.dart';
import 'package:event_ticket/providers/ticket_provider.dart';
import 'package:event_ticket/providers/transfer_ticket_provider.dart';
import 'package:event_ticket/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void invalidateAllProvidersExceptCategory(WidgetRef ref) {
  ref.invalidate(checkedInTicketProvider);
  ref.invalidate(eventManagementProvider);
  ref.invalidate(eventProvider);
  ref.invalidate(navigationIndexProvider);
  ref.invalidate(roleProvider);
  ref.invalidate(ticketProvider);
  ref.invalidate(userProvider);
  ref.invalidate(transferTicketProvider);
  ref.invalidate(forumProvider);
  ref.invalidate(notificationProvider);
}
