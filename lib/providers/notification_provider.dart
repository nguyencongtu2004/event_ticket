import 'package:event_ticket/models/notification.dart';
import 'package:event_ticket/requests/notification_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationNotifier extends AsyncNotifier<List<Notification>> {
  final _notificationRequest = NotificationRequest();

  @override
  Future<List<Notification>> build() async {
    try {
      final response = await _notificationRequest.getNotifications();
      final notifications = (response.data as List)
          .map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList();
      return notifications;
    } catch (e, st) {
      print('Error in NotificationNotifier.build: $e');
      print(st);
      throw e; // Let AsyncValue handle the error state
    }
  }

  Future<String> markAsRead(Notification notification) async {
    try {
      // Create a copy of the notification with updated isRead status
      final updatedNotification = Notification.fromJson(notification.toJson())
        ..isRead = true;

      // Store old state for rollback
      final oldState = state.value ?? [];

      // Update state optimistically
      state = AsyncValue.data(
        oldState
            .map((n) => n.id == notification.id ? updatedNotification : n)
            .toList(),
      );

      // Make API call
      final response =
          await _notificationRequest.markNotificationAsRead(notification.id);

      if (response.statusCode == 200) {
        return 'Notification marked as read';
      } else {
        // Rollback on failure
        state = AsyncValue.data(oldState);
        return response.data['message'] ??
            'Failed to mark notification as read';
      }
    } catch (e, st) {
      // Rollback on error
      state = AsyncValue.data(state.value ?? []);
      print('Error in NotificationNotifier.markAsRead: $e');
      print(st);
      return 'Failed to mark notification as read';
    }
  }

  Future<String> markAllAsRead() async {
    try {
      // Store old state for rollback
      final oldState = state.value ?? [];

      // Create new list with all notifications marked as read
      final updatedNotifications = oldState.map((n) {
        final updated = Notification.fromJson(n.toJson());
        updated.isRead = true;
        return updated;
      }).toList();

      // Update state optimistically
      state = AsyncValue.data(updatedNotifications);

      // Make API call
      final response = await _notificationRequest.markAllNotificationAsRead();

      if (response.statusCode == 200) {
        return 'All notifications marked as read';
      } else {
        // Rollback on failure
        state = AsyncValue.data(oldState);
        return response.data['message'] ??
            'Failed to mark all notifications as read';
      }
    } catch (e, st) {
      // Rollback on error
      state = AsyncValue.data(state.value ?? []);
      print('Error in NotificationNotifier.markAllAsRead: $e');
      print(st);
      return 'Failed to mark all notifications as read';
    }
  }
}

final notificationProvider =
    AsyncNotifierProvider<NotificationNotifier, List<Notification>>(
        NotificationNotifier.new);
