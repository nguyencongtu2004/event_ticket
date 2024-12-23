import 'package:dio/dio.dart';
import 'package:event_ticket/constants/api.dart';
import 'package:event_ticket/enum.dart';
import 'package:event_ticket/models/category.dart';
import 'package:event_ticket/service/http_service.dart';

class EventRequest extends HttpService {
  Future<Response> getEvents({Map<String, dynamic>? queryParameters}) async {
    final response = await get(
      url: Api.getEvents,
      queryParameters: queryParameters,
    );
    return response;
  }

  Future<Response> getManagementEvents(
      {Map<String, dynamic>? queryParameters}) async {
    final response = await get(
      url: Api.getManagementEvents,
      queryParameters: queryParameters,
    );
    return response;
  }

  Future<Response> getEventDetail(String eventId) async {
    final response = await get(url: Api.getEventDetail(eventId));
    return response;
  }

  Future<Response> createEvent(FormData form) async {
    final response = await postWithFile(url: Api.createEvent, body: form);
    return response;
  }

  Future<Response> deleteEvent(String eventId) async {
    final response = await delete(url: Api.deleteEvent(eventId));
    return response;
  }

  Future<Response> updateEvent(String eventId, FormData form) async {
    final response =
        await putWithFile(url: Api.updateEvent(eventId), body: form);
    return response;
  }

  Future<Response> searchEvents({
    String? name,
    String? location,
    DateTime? date,
    Category? category,
    EventStatus? status,
  }) async {
    final response = await get(
      url: Api.searchEvents,
      queryParameters: {
        if (name != null) 'name': name,
        if (location != null) 'location': location,
        if (date != null) 'date': date.toIso8601String(),
        if (category != null) 'categoryId': category.id,
        if (status != null) 'status': status.value,
      },
    );
    return response;
  }
}
