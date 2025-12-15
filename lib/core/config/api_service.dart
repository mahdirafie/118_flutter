import 'package:basu_118/core/config/app_config.dart';
import 'package:basu_118/core/config/interceptor.dart';
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService()
      : _dio = Dio(
          BaseOptions(baseUrl: AppConfig.baseUrl),
        ) {
    _dio.interceptors.add(AuthInterceptor());
  }

  Future<Response> get(String path, {Map<String, dynamic>? query, Options? options}) =>
      _dio.get(path, queryParameters: query, options: options);

  Future<Response> post(String path, Map<String, dynamic> data) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, Map<String, dynamic> data) =>
      _dio.put(path, data: data);

  Future<Response> delete(String path, {Map<String, dynamic>? data}) =>
      _dio.delete(path, data: data);
}

final ApiService apiService = ApiService();
