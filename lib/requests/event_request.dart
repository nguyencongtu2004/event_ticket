import 'package:dio/dio.dart';
import 'package:event_ticket/constants/api.dart';
import 'package:event_ticket/service/http_service.dart';

class EventRequest extends HttpService {
  Future<Response> getEvents() async {
    final response = await get(url: Api.getEvents);
    return response;
  }
}
