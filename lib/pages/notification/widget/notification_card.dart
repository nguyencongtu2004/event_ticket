import 'package:event_ticket/models/notification.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:event_ticket/enum.dart';
import 'package:event_ticket/extensions/extension.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final Notification notification;
  final void Function(Notification notification) onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.isRead != true;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isUnread
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).cardColor,
      elevation: isUnread ? 2 : 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isUnread
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          child: _getLeadingIcon(context, notification.type, isUnread),
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
  }

  Widget _getLeadingIcon(
      BuildContext context, NotificationType? type, bool isUnread) {
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
