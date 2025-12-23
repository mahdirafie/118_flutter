import 'dart:async';

import 'package:basu_118/core/auth_service/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:basu_118/core/storage/local_storage.dart';

class AuthInterceptor extends Interceptor {
  bool _isRefreshing = false;
  final List<Function(String)> _retryQueue = [];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await LocalStorage.getAccessToken();
    print("ACCESS TOKEN:");
    print(accessToken);

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If error is not 401, just pass it
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final refreshToken = await LocalStorage.getRefreshToken();
    if (refreshToken == null) {
      return handler.next(err); // User not logged in
    }

    final Dio dio = Dio();

    // ----- Already refreshing → Queue this request -----
    if (_isRefreshing) {
      final completer = Completer<Response>();
      _retryQueue.add((String newAccessToken) {
        err.requestOptions.headers['Authorization'] = "Bearer $newAccessToken";
        dio.fetch(err.requestOptions).then(completer.complete);
      });
      // ignore: argument_type_not_assignable_to_error_handler
      return completer.future.then(handler.resolve).catchError(handler.reject);
    }

    _isRefreshing = true;

    try {
      final refreshUri = Uri.parse(
        err.requestOptions.baseUrl,
      ).resolve('auth/refresh');

      final response = await dio.post(
        refreshUri.toString(),
        data: {"refresh_token": refreshToken},
      );

      final newAccessToken = response.data["access_token"];
      final newRefreshToken = response.data["refresh_token"]; // from Option B

      // Save new tokens
      await AuthService().saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      // Retry all queued requests
      for (var retry in _retryQueue) {
        retry(newAccessToken);
      }
      _retryQueue.clear();

      // Retry original request
      err.requestOptions.headers['Authorization'] = "Bearer $newAccessToken";
      final retryResponse = await dio.fetch(err.requestOptions);

      handler.resolve(retryResponse);
    } catch (refreshError) {
      print("REFRESH FAILED!");
      print(refreshError.toString());
      // Refresh failed → logout
      await LocalStorage.clear();

      handler.reject(err);
    } finally {
      _isRefreshing = false;
    }
  }
}
