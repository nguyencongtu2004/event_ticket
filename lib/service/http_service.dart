import 'package:dio/dio.dart';
import 'package:event_ticket/constants/api.dart';
import 'package:event_ticket/service/auth_service.dart';

class HttpService {
  final _dio = Dio(
    BaseOptions(baseUrl: Api.baseUrl),
  );

  HttpService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('Dio Request: ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('Dio Response: ${response.statusCode}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('Dio Error: ${e.message}');
        return handler.next(e);
      },
    ));
  }

  // Get request
  Future<Response> get({
    required String url,
    bool includeHeaders = true,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    Response response;
    try {
      response = await _dio.get(
        Api.baseUrl + url,
        queryParameters: queryParameters,
        options: Options(
          headers: includeHeaders ? await getHeaders() : headers,
        ),
      );
    } on DioException catch (error) {
      response = Response(
        requestOptions: error.requestOptions,
        statusCode: 400,
        statusMessage: error.message,
      );
    }

    return response;
  }

  // Post request
  Future<Response> post({
    required String url,
    Map<String, dynamic>? body,
    bool includeHeaders = true,
    Map<String, dynamic>? headers,
  }) async {
    Response response;
    try {
      response = await _dio.post(
        Api.baseUrl + url,
        data: body,
        options: Options(
          headers: includeHeaders ? await getHeaders() : headers,
        ),
      );
    } on DioException catch (error) {
      response = Response(
        requestOptions: error.requestOptions,
        statusCode: 400,
        statusMessage: error.message,
      );
    }

    return response;
  }

  // Post request with file
  Future<Response> postWithFile({
    required String url,
    required FormData body,
    bool includeHeaders = true,
    Map<String, dynamic>? headers,
  }) async {
    Response response;
    try {
      response = await _dio.post(
        Api.baseUrl + url,
        data: body,
        options: Options(
          headers: includeHeaders
              ? await getHeaders(contentType: 'multipart/form-data')
              : headers,
        ),
      );
    } on DioException catch (error) {
      response = Response(
        requestOptions: error.requestOptions,
        statusCode: 400,
        statusMessage: error.message,
      );
    }

    return response;
  }

  // Put request
  Future<Response> put({
    required String url,
    Map<String, dynamic>? body,
    bool includeHeaders = true,
    Map<String, dynamic>? headers,
  }) async {
    Response response;
    try {
      response = await _dio.put(
        Api.baseUrl + url,
        data: body,
        options: Options(
          headers: includeHeaders ? await getHeaders() : headers,
        ),
      );
    } on DioException catch (error) {
      response = Response(
        requestOptions: error.requestOptions,
        statusCode: 400,
        statusMessage: error.message,
      );
    }

    return response;
  }

  // Put request with file
  Future<Response> putWithFile({
    required String url,
    required FormData body,
    bool includeHeaders = true,
    Map<String, dynamic>? headers,
  }) async {
    Response response;
    try {
      response = await _dio.put(
        Api.baseUrl + url,
        data: body,
        options: Options(
          headers: includeHeaders
              ? await getHeaders(contentType: 'multipart/form-data')
              : headers,
        ),
      );
    } on DioException catch (error) {
      response = Response(
        requestOptions: error.requestOptions,
        statusCode: 400,
        statusMessage: error.message,
      );
    }

    return response;
  }

  // Delete request
  Future<Response> delete({
    required String url,
    bool includeHeaders = true,
    Map<String, dynamic>? headers,
  }) async {
    Response response;
    try {
      response = await _dio.delete(
        Api.baseUrl + url,
        options: Options(
          headers: includeHeaders ? await getHeaders() : headers,
        ),
      );
    } on DioException catch (error) {
      response = Response(
        requestOptions: error.requestOptions,
        statusCode: 400,
        statusMessage: error.message,
      );
    }

    return response;
  }

  // Get headers
  Future<Map<String, String>> getHeaders({
    contentType = 'application/json',
  }) async {
    final userToken = await AuthService.getAuthBearerToken();
    print('User token: $userToken');
    return {
      'Authorization': 'Bearer $userToken',
      'Content-Type': contentType,
    };
  }

  // Handle DioException
  // Response formatDioExecption(DioException ex) {
  //   var response = Response(requestOptions: ex.requestOptions);

  //   response.statusCode = 400;
  //   String? msg = response.statusMessage;

  //   try {
  //     if (ex.type == DioExceptionType.connectionTimeout) {
  //       msg =
  //           "Connection timeout. Please check your internet connection and try again";
  //     } else if (ex.type == DioExceptionType.sendTimeout) {
  //       msg =
  //           "Send timeout. Please check your internet connection and try again";
  //     } else if (ex.type == DioExceptionType.receiveTimeout) {
  //       msg =
  //           "Receive timeout. Please check your internet connection and try again";
  //     } else if (ex.type == DioExceptionType.cancel) {
  //       msg = "Request to server was cancelled. Please try again";
  //     } else if (ex.type == DioExceptionType.unknown) {
  //       msg = "Unexpected error occurred. Please try again";
  //     } else {
  //       msg = ex.message;
  //     }
  //     response.data = {"message": msg};
  //   } catch (error) {
  //     response.statusCode = 400;
  //     msg = "An error occurred. Please try again";
  //     response.data = {"message": msg};
  //   }

  //   throw Exception(msg);
  // }
}
