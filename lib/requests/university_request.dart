import 'package:dio/dio.dart';
import 'package:event_ticket/constants/api.dart';
import 'package:event_ticket/service/http_service.dart';

class UniversityRequest extends HttpService {
  Future<Response> getUniversities() async {
    final response = await get(
      url: Api.getUniversities,
    );

    return response;
  }

  Future<Response> getFacultiesByUniversityId(universityId) async {
    final response = await get(
      url: Api.getFacultiesByUniversityId(universityId),
    );

    return response;
  }
}
