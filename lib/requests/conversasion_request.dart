import 'package:dio/dio.dart';
import 'package:event_ticket/constants/api.dart';
import 'package:event_ticket/service/http_service.dart';

class ConversasionRequest extends HttpService {
  Future<Response> getConversasions() async {
    final response = await get(
      url: Api.getConversasions,
    );
    return response;
  }

  Future<Response> getConversasionDetail(String conversationId,
      {int page = 1, int limit = 10}) async {
    final response = await get(
      url: Api.getConversasionDetail(conversationId),
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    return response;
  }
}
