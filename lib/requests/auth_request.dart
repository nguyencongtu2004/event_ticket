import 'package:dio/dio.dart';
import 'package:event_ticket/constants/api.dart';
import 'package:event_ticket/enum.dart';
import 'package:event_ticket/service/http_service.dart';

class AuthRequest extends HttpService {
  Future<Response> login({
    required String email,
    required String password,
    String? role,
  }) async {
    final response = await post(
      url: Api.login,
      body: {
        'email': email,
        'password': password,
        'role': role,
      },
      includeHeaders: false,
    );

    return response;
  }

  Future<Response> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    String? university,
    String? faculty,
    String? major,
    String? studentId,
    Genders? gender,
    String? phone,
  }) async {
    final response = await post(
      url: Api.register,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'role': role,
        'university': university,
        'faculty': faculty,
        'major': major,
        'studentId': studentId,
        'gender': gender?.name,
        'phone': phone,
      },
      includeHeaders: false,
    );

    return response;
  }

  Future<Response> sendFCMTokenToServer(String fcmToken) {
    final response = post(
      url: Api.fcmToken,
      body: {'fcmToken': fcmToken},
    );

    return response;
  }

  Future<Response> deleteFCMTokenOnServer(String fcmToken) {
    final response = delete(
      url: Api.fcmToken,
      body: {'fcmToken': fcmToken},
    );

    return response;
  }

  Future<Response> forgetPassword(String email) async {
    final response = await put(
      url: Api.forgetPassword,
      body: {'email': email},
    );
    return response;
  }
}
