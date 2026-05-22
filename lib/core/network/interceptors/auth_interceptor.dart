import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/api_constants.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorage.read(key: ApiConstants.accessToken);
    if (token != null) {
      options.headers[ApiConstants.authorization] =
          '${ApiConstants.bearer} $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Handle token refresh logic here
      await _refreshToken();
      final newToken = await secureStorage.read(key: ApiConstants.accessToken);
      if (newToken != null) {
        final newRequest = err.requestOptions;
        newRequest.headers[ApiConstants.authorization] =
            '${ApiConstants.bearer} $newToken';
        final dio = err.requestOptions.extra['dio'];
        final response = await dio.fetch(newRequest);
        return handler.resolve(response);
      }
    }
    handler.next(err);
  }

  Future<void> _refreshToken() async {
    // Implement token refresh logic
  }
}
