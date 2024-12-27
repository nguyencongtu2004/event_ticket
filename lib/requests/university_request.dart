import 'package:dio/dio.dart';
import 'package:event_ticket/constants/api.dart';
import 'package:event_ticket/service/http_service.dart';

class UniversityRequest extends HttpService {
  Future<Response> getUniversitiesWithAll() async {
    final response = await get(
      url: Api.getUniversitiesWithAll,
    );

    return response;
  }

  // admin
  Future<Response> getUniversities() async {
    final response = await get(
      url: Api.getUniversities,
    );

    return response;
  }

  // admin
  Future<Response> createUniversity(String name) async {
    final response = await post(url: Api.createUniversity, body: {
      'name': name,
    });
    return response;
  }

  // admin
  Future<Response> updateUniversity(String universityId, String name) async {
    final response = await put(url: Api.updateUniversity(universityId), body: {
      'name': name,
    });
    return response;
  }

  // admin
  Future<Response> deleteUniversity(String universityId) async {
    final response = await delete(
      url: Api.deleteUniversity(universityId),
    );

    return response;
  }

  // admin
  Future<Response> getFacultiesByUniversityId(String universityId) async {
    final response = await get(
      url: Api.getFacultiesByUniversityId(universityId),
    );

    return response;
  }

  // admin
  Future<Response> createFaculty(String universityId, String name) async {
    final response = await post(
      url: Api.createFaculty,
      body: {
        'universityId': universityId,
        'name': name,
      },
    );
    return response;
  }

  // admin
  Future<Response> updateFaculty(String facultyId, String name) async {
    final response = await put(
      url: Api.updateFaculty(facultyId),
      body: {
        'name': name,
      },
    );
    return response;
  }

  // admin
  Future<Response> deleteFaculty(String facultyId) async {
    final response = await delete(
      url: Api.deleteFaculty(facultyId),
    );

    return response;
  }

  // admin
  Future<Response> getMajorsByFacultyId(String facultyId) async {
    final response = await get(
      url: Api.getMajorsByFacultyId(facultyId),
    );

    return response;
  }

  // admin
  Future<Response> createMajor(String facultyId, String name) async {
    final response = await post(
      url: Api.createMajor,
      body: {
        'facultyId': facultyId,
        'name': name,
      },
    );
    return response;
  }

  // admin
  Future<Response> updateMajor(String majorId, String name) async {
    final response = await put(
      url: Api.updateMajor(majorId),
      body: {
        'name': name,
      },
    );
    return response;
  }

  // admin
  Future<Response> deleteMajor(String majorId) async {
    final response = await delete(
      url: Api.deleteMajor(majorId),
    );

    return response;
  }
}
