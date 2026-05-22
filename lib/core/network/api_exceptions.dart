import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, {this.statusCode});
  
  @override
  String toString() => message;
}

class ApiExceptionHandler {
  static String handle(DioException error) {
    // Try to get custom message from response
    if (error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        // Return the actual message from API (like "Scholar not found")
        return data['message'];
      }
    }
    
    // Default messages
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Please try again.';
      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response?.statusCode);
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
  
  static String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 404:
        return 'Scholar not found'; // Simple message
      case 401:
        return 'Invalid credentials';
      case 400:
        return 'Bad request';
      case 500:
        return 'Server error';
      default:
        return 'Something went wrong';
    }
  }
}