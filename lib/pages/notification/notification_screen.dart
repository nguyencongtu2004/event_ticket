import 'package:event_ticket/enum.dart';
import 'package:event_ticket/extensions/context_extesion.dart';
import 'package:event_ticket/pages/event/event_detail_screen.dart';
import 'package:event_ticket/pages/forum/forum_detail_screen.dart';
import 'package:event_ticket/pages/notification/widget/notification_card.dart';
import 'package:event_ticket/pages/ticket/ticket_detail_screen.dart';
import 'package:event_ticket/pages/ticket/transfer_ticket_screen.dart';
import 'package:event_ticket/providers/notification_provider.dart';
import 'package:event_ticket/service/firebase_service.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_ticket/models/notification.dart';
import 'package:velocity_x/velocity_x.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  Widget? panelWidget;

  Future<void> onTap(Notification notification) async {
    if (MediaQuery.sizeOf(context).width > 600) {
      // Trường hợp màn hình lớn
      if (notification.data == null || notification.data!.isEmpty) return;

      final NotificationType notificationType =
          NotificationType.values.firstWhere(
        (element) => element.value == notification.data!['type'],
        orElse: () => NotificationType.unknown,
      );
      if (notificationType == NotificationType.unknown) return;

      switch (notificationType) {
        // Trường hợp vào ticket -> transfer ticket
        case NotificationType.ticketTransfer:
          setState(() => panelWidget = const TransferTicketScreen());
          break;

        // Trường hợp vào ticket -> ticket detail
        case NotificationType.checkIn:
        case NotificationType.ticketBooking:
        case NotificationType.ticketCancel:
        case NotificationType.paymentSuccess:
          final ticketId = notification.data!['ticketId'] as String?;
          if (ticketId == null) return;
          setState(() => panelWidget =
              TicketDetailScreen(key: ValueKey(ticketId), ticketId: ticketId));
          break;

        // Trường hợp vào forum -> forum detail
        case NotificationType.commentReply:
          final forumId = notification.data!['conversationId'] as String?;
          if (forumId == null) return;
          setState(() => panelWidget =
              ForumDetailScreen(key: ValueKey(forumId), forumId: forumId));
          break;

        // Trường hợp vào event -> event detail
        case NotificationType.newEvent:
        case NotificationType.eventUpdate:
          final eventId = notification.data!['eventId'] as String?;
          if (eventId == null) return;
          setState(() => panelWidget =
              EventDetailScreen(key: ValueKey(eventId), eventId: eventId));
          break;
        default:
      }
      return;
    } else {
      // Trường hợp màn hình nhỏ
      final simulatedMessage = notification.toRemoteMessage();

      FirebaseService.handleNotificationNavigation(
        simulatedMessage,
        fromBackground: false,
      ).then((_) => setState(() => panelWidget = null));
    }

    // Trường hợp chưa xem thì đánh dấu thông báo là đã xem
    if (notification.isRead == false) {
      ref.read(notificationProvider.notifier).markAsRead(notification);
    }
  }

  Future<void> markAllAsRead() async {
    final message =
        await ref.read(notificationProvider.notifier).markAllAsRead();

    context.showAnimatedToast(message);
  }

  @override
  Widget build(BuildContext context) {
    final asyncValue = ref.watch(notificationProvider);
    final theme = Theme.of(context);

    return TicketScaffold(
      title: 'Notifications',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.done_all),
          onPressed: markAllAsRead,
          tooltip: 'Mark all as read',
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(notificationProvider.future),
        child: switch (asyncValue) {
          AsyncValue<List<Notification>>(:final valueOrNull?) =>
            LayoutBuilder(builder: (context, constraints) {
              final isLargeScreen = constraints.maxWidth > 600;
              if (isLargeScreen) {
                return Center(
                  child: Row(
                    children: [
                      _buildNotificationList(context, valueOrNull)
                          .expand(flex: 2),
                      if (panelWidget != null) ...[
                        const VerticalDivider(width: 1),
                        Stack(children: [
                          panelWidget!,
                          Positioned(
                            top: 8,
                            left: 12,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () =>
                                  setState(() => panelWidget = null),
                              tooltip: 'Close panel',
                            ),
                          ),
                        ]).expand(flex: 3),
                      ],
                    ],
                  )
                      .w(isLargeScreen && panelWidget != null ? 1200 : 600)
                      .centered(),
                );
              } else {
                return _buildNotificationList(context, valueOrNull);
              }
            }),
          AsyncValue(:final error?) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    color: theme.colorScheme.error, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error: $error',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
            ).p(16).centered(),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  Widget _buildNotificationList(
      BuildContext context, List<Notification> notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: notifications.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) => NotificationCard(
        notification: notifications[index],
        onTap: onTap,
      ),
    );
  }
}
