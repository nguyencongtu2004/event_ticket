import 'package:dio/dio.dart';
import 'package:event_ticket/constants/api.dart';
import 'package:event_ticket/enum.dart';
import 'package:event_ticket/models/user.dart';
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

  Future<List<User>> searchUser({
    required String query,
    required Roles role,
  }) async {
    final response = await get(
      url: Api.search,
      queryParameters: {
        'query': query,
        'role': role.value,
      },
    );

    if (response.statusCode == 200) {
      return (response.data as List)
          .map((user) => User.fromJson(user))
          .toList();
    } else {
      return [];
    }
  }

  //admin
  Future<Response> getAllUsers({Roles? role}) async {
    final response = await get(
      url: Api.getAllUsers,
      queryParameters: {
        if (role != null) 'role': role.value,
      },
    );

    return response;
  }

  // admin
  Future<Response> deleteUser(String userId) async {
    final response = await delete(url: Api.deleteUser(userId));

    return response;
  }
}
