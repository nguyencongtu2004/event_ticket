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

  Future<Response> getHistory() async {
    final response = await get(
      url: Api.getTicketHistory,
    );
    return response;
  }

  Future<Response> getTicketDetail(String ticketId) async {
    final response = await get(
      url: Api.getTicketDetail(ticketId),
    );
  
    return response;
  }

  Future<Response> cancelTicket(String ticketId, String cancelReason) async {
    final response = await delete(
      url: Api.cancelTicket(ticketId),
      body: {'cancelReason': cancelReason},
    );
  
    return response;
  }

  Future<Response> checkInTicket(String bookingCode) async {
    final response = await post(
      url: Api.checkIn,
      body: {'bookingCode': bookingCode},
    );
  
    return response;
  }

  Future<Response> transferTicket(String ticketId, String newOwnerId) async {
    final response = await post(
      url: Api.transferTicket(ticketId),
      body: {'newOwnerId': newOwnerId},
    );
  
    return response;
  }

  Future<Response> confirmTransferTicket(String ticketId) async {
    final response = await post(
      url: Api.confirmTransferTicket(ticketId),
    );
  
    return response;
  }
  
  Future<Response> rejectTransferTicket(String ticketId) async {
    final response = await post(
      url: Api.rejectTransferTicket(ticketId),
    );
  
    return response;
  }
}
