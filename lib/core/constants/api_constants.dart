class ApiConstants {
  // Change this to your actual backend API URL
  // static const String baseUrl = 'http://localhost:3000/api'; // For local development
  static const String baseUrl = 'http://scholarapi.seasense.in/api'; // For production
  static const String apiUrl = 'http://scholarapi.seasense.in/'; // For production
  
  static const String apiVersion = 'v1';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
  
  // Storage keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
}