import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/forgot_password_request.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );
      return LoginResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  // Send OTP for forgot password
  Future<Map<String, dynamic>> sendOtp({
    required String scholarId,
    required String email,
    required String comUrlCode,
  }) async {
    try {
      final request = SendOtpRequest(
        userId: scholarId,
        email: email,
        comUrlCode: comUrlCode,
      );
      
      final response = await _apiClient.post(
        ApiEndpoints.sendOtp,
        data: request.toJson(),
      );
      
      // Check if response indicates success
      if (response.data['status_code'] == 200 || response.data['status'] == 'success') {
        return {
          'success': true,
          'message': response.data['message'] ?? 'OTP sent successfully',
          'user_id': response.data['user_id'] ?? scholarId,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to send OTP',
        };
      }
    } catch (e) {
      // Handle API error response
      return _handleError(e);
    }
  }
  
  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String otp,
    required String userId,
  }) async {
    try {
      final request = VerifyOtpRequest(
        otp: otp,
        userId: userId,
      );
      
      final response = await _apiClient.post(
        ApiEndpoints.verifyOtp,
        data: request.toJson(),
      );
      
      print('VERIFY OTP RESPONSE: ${response.data}');
      
      // Check if response indicates success
      // Based on your error: {status_code: 401, status: error, message: Invalid OTP}
      if (response.data['status_code'] == 200 || response.data['status'] == 'success') {
        return {
          'success': true,
          'message': response.data['message'] ?? 'OTP verified successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Invalid OTP',
          'status_code': response.data['status_code'],
        };
      }
    } catch (e) {
      // Handle API error response
      return _handleError(e);
    }
  }
  
  // Reset password
  Future<Map<String, dynamic>> resetPassword({
    required String userId,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final request = ResetPasswordRequest(
        userId: userId,
        newPwd: newPassword,
        confirmPwd: confirmPassword,
      );
      
      final response = await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: request.toJson(),
      );
      
      if (response.data['status_code'] == 200 || response.data['status'] == 'success') {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Password reset successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to reset password',
        };
      }
    } catch (e) {
      return _handleError(e);
    }
  }
  
  // Helper method to handle errors
  Map<String, dynamic> _handleError(dynamic error) {
    print('ERROR IN REPOSITORY: $error');
    
    // Try to extract error message from the exception
    String errorMessage = 'An error occurred';
    
    if (error is Map<String, dynamic>) {
      errorMessage = error['message'] ?? error['error'] ?? 'API Error';
    } else if (error is String) {
      errorMessage = error;
    } else if (error.toString().contains('status_code')) {
      // Try to parse the error string
      try {
        if (error.toString().contains('401')) {
          errorMessage = 'Invalid OTP. Please try again.';
        } else if (error.toString().contains('400')) {
          errorMessage = 'Invalid request. Please check your input.';
        } else {
          errorMessage = 'Server error. Please try again later.';
        }
      } catch (e) {
        errorMessage = 'Network error. Please check your connection.';
      }
    }
    
    return {
      'success': false,
      'message': errorMessage,
    };
  }
  
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } catch (e) {
      rethrow;
    }
  }
}