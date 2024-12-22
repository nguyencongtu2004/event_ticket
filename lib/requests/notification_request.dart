import 'package:dio/dio.dart';
import 'package:event_ticket/constants/api.dart';
import 'package:event_ticket/service/http_service.dart';

class NotificationRequest extends HttpService {
  Future<Response> getNotifications() async {
    final response = await get(
      url: Api.getNotifications,
    );
    return response;
  }

  Future<Response> markNotificationAsRead(String notificationId) async {
    final response = await patch(
      url: Api.markNotificationAsRead(notificationId),
    );
    return response;
  }

  Future<Response> markAllNotificationAsRead() async {
    final response = await patch(
      url: Api.markAllNotificationAsRead,
    );
    return response;
  }
}
