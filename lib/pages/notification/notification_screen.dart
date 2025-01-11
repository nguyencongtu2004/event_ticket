import 'package:event_ticket/extensions/context_extesion.dart';
import 'package:event_ticket/pages/notification/widget/notification_card.dart';
import 'package:event_ticket/providers/notification_provider.dart';
import 'package:event_ticket/service/firebase_service.dart';
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
    final simulatedMessage = notification.toRemoteMessage();

    FirebaseService.handleNotificationNavigation(
      simulatedMessage,
      fromBackground: false,
    );
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
          AsyncValue<List<Notification>>(:final valueOrNull?) => Center(
              child: SizedBox(
                width: 600,
                child: _buildNotificationList(context, valueOrNull),
              ),
            ),
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
      itemBuilder: (context, index) => NotificationCard(
        notification: notifications[index],
        onTap: onTap,
      ),
    );
  }
}
