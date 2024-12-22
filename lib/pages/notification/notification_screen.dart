import 'package:event_ticket/enum.dart';
import 'package:event_ticket/extensions/context_extesion.dart';
import 'package:event_ticket/extensions/extension.dart';
import 'package:event_ticket/providers/notification_provider.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_ticket/models/notification.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  Future<void> onTap(Notification notification) async {
    if (notification.isRead != true) {
      final message = await ref
          .read(notificationProvider.notifier)
          .markAsRead(notification);

      context.showAnimatedToast(message);
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
            _buildNotificationList(context, valueOrNull),
          AsyncValue(:final error?) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
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
                ),
              ),
            ),
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
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final isUnread = notification.isRead != true;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: isUnread
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).cardColor,
          elevation: isUnread ? 2 : 1,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: isUnread
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              child: _getLeadingIcon(notification.type, isUnread),
            ),
            onTap: () => onTap(notification),
            title: Text(
              notification.title ?? 'No title',
              style: TextStyle(
                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(notification.body ?? 'No body'),
                const SizedBox(height: 4),
                if (notification.createdAt != null)
                  Text(
                    notification.createdAt!.toTimeAgo(isShortFormat: false),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            trailing: isUnread
                ? Icon(
                    Icons.circle,
                    size: 12,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _getLeadingIcon(NotificationType? type, bool isUnread) {
    final color = isUnread
        ? Colors.white
        : Theme.of(context).colorScheme.onSurfaceVariant;

    switch (type) {
      case NotificationType.paymentSuccess:
        return Icon(Icons.payment, color: color);
      case NotificationType.checkIn:
        return Icon(Icons.check, color: color);
      case NotificationType.newEvent:
        return Icon(Icons.event, color: color);
      case NotificationType.eventUpdate:
        return Icon(Icons.update, color: color);
      case NotificationType.ticketBooking:
        return Icon(Icons.event_seat, color: color);
      case NotificationType.ticketCancel:
        return Icon(Icons.cancel, color: color);
      case NotificationType.ticketTransfer:
        return Icon(Icons.transfer_within_a_station, color: color);
      case NotificationType.unknown:
        return Icon(Icons.question_mark, color: color);
      default:
        return Icon(Icons.question_mark, color: color);
    }
  }
}
