import 'package:dio/dio.dart';
import 'package:event_ticket/constants/api.dart';
import 'package:event_ticket/service/http_service.dart';

class CategoryRequest extends HttpService {
  Future<Response> getCategories() async {
    final response = await get(url: Api.getCategories);
    return response;
  }
}
