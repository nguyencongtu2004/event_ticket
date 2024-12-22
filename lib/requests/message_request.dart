import 'package:dio/dio.dart';
import 'package:event_ticket/constants/api.dart';
import 'package:event_ticket/service/http_service.dart';

class MessageRequest extends HttpService {
  Future<Response> sendMessage(
    String conversationId,
    String content,
    String? parentMessageId,
  ) async {
    final response = await post(
      url: Api.sendMessage,
      body: {
        'conversationId': conversationId,
        'content': content,
        'parentMessageId': parentMessageId,
      },
    );
    return response;
  }

  Future<Response> editMessage(String messageId, String content) async {
    final response = await put(
      url: Api.editMessage(messageId),
      body: {
        'content': content,
      },
    );
    return response;
  }

  Future<Response> deleteMessage(String messageId) async {
    final response = await delete(
      url: Api.deleteMessage(messageId),
    );
    return response;
  }
}
