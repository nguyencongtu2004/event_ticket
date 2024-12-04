import 'package:dio/dio.dart';
import 'package:event_ticket/constants/api.dart';
import 'package:event_ticket/service/http_service.dart';

class UserRequest extends HttpService {
  Future<Response> getUserInfo() async {
    final response = await get(
      url: Api.getUserInfo,
    );

    return response;
  }

  Future<Response> updateUserInfo(FormData data) async {
    final response = await putWithFile(
      url: Api.updateUserInfo,
      body: data,
    );

    return response;
  }
}
