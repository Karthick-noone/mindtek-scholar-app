import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'api_exceptions.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();
  
  late Dio _dio;
  
  Dio get dio => _dio;
  
  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': ApiConstants.contentType,
      },
      // IMPORTANT: Follow redirects
      followRedirects: true,
      // Allow redirects for POST requests
      maxRedirects: 5,
      // Don't throw on 302, handle it gracefully
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ));
    
    _dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
    ]);
  }
  
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
      );
      
      // Handle redirect responses manually if needed
      if (response.statusCode == 302) {
        final redirectUrl = response.headers.value('location');
        if (redirectUrl != null) {
          print('Redirecting to: $redirectUrl');
          // You can handle the redirect here if needed
          throw ApiException('Authentication failed. Please check your credentials or contact support.');
        }
      }
      
      return response;
    } on DioException catch (e) {
      throw ApiException(ApiExceptionHandler.handle(e));
    }
  }
  
  // Other methods (get, put, delete) remain the same...
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParams,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException(ApiExceptionHandler.handle(e));
    }
  }
  
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException(ApiExceptionHandler.handle(e));
    }
  }
  
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException(ApiExceptionHandler.handle(e));
    }
  }
}