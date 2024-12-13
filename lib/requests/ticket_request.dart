import 'package:dio/dio.dart';
import 'package:event_ticket/constants/api.dart';
import 'package:event_ticket/service/http_service.dart';

class TicketRequest extends HttpService {
  Future<Response> bookTicket(String eventId) async {
    final response = await post(
      url: Api.bookTicket,
      body: {'eventId': eventId},
    );
    return response;
  }
}
