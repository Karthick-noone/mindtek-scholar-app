import 'package:mindtek_scholar_app/core/network/api_client.dart';
import 'package:mindtek_scholar_app/core/network/api_endpoints.dart';
import 'package:mindtek_scholar_app/features/auth/data/models/forgot_password_request.dart';

part of 'auth_remote_datasource.dart';

// Add these methods to your existing AuthRemoteDatasource class
class AuthRemoteDatasource {
  final ApiClient _apiClient;
  
  // ... existing code ...
  
  // Forgot Password Methods
  Future<Map<String, dynamic>> sendOtp(SendOtpRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.sendOtp,
        data: request.toJson(),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOtp(VerifyOtpRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.verifyOtp,
        data: request.toJson(),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: request.toJson(),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}