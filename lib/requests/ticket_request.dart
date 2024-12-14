import 'dart:convert';

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
      url: Api.getHistory,
    );
    return response;
  }

  Future<Response> getTicketDetail(String ticketId) async {
    final response = await get(
      url: '',
    );
    final mock = {
      "_id": "675d51d02d2e0cc00b79f0ef",
      "bookingCode": "TICKET-5LRB6ZE20",
      "event": {
        "_id": "67546d34366656cf38dfda78",
        "name": "test",
        "date": "2024-12-17T00:00:00.000Z",
        "location": "hoi truong E",
        "price": 12000
      },
      "status": "booked",
      "paymentStatus": "pending",
      "createAt": "2024-12-14T09:37:20.372Z",
      "paymentData": {
        "partnerCode": "MOMO",
        "orderId": "MOMO1734169040463",
        "requestId": "MOMO1734169040463",
        "amount": 12000,
        "responseTime": 1734169044056,
        "message": "Thành công.",
        "resultCode": 0,
        "payUrl":
            "https://test-payment.momo.vn/v2/gateway/pay?s=07c93b622f1f8b5cabcfde61ea43906dac25f1ab665e210efd2f8ff5214a0118&t=TU9NT3xNT01PMTczNDE2OTA0MDQ2Mw",
        "deeplink":
            "momo://app?action=payWithApp&isScanQR=false&serviceType=app&sid=TU9NT3xNT01PMTczNDE2OTA0MDQ2Mw&v=3.0",
        "qrCodeUrl":
            "momo://app?action=payWithApp&isScanQR=true&serviceType=qr&sid=TU9NT3xNT01PMTczNDE2OTA0MDQ2Mw&v=3.0"
      }
    };

    return Response(
      requestOptions: RequestOptions(),
      data: mock,
      statusCode: 200,
    );
  }
}
