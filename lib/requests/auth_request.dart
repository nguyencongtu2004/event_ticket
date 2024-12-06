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
    );

    return response;
  }
}
