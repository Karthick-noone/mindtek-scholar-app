import 'package:mindtek_scholar_app/core/network/api_client.dart';

class ChangePasswordRemoteDataSource {
  final ApiClient apiClient;
  
  ChangePasswordRemoteDataSource(this.apiClient);
  
  Future<Map<String, dynamic>> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      // Send ID in URL path
      final response = await apiClient.post('/change-password/$userId', data: {
        'old_pwd': oldPassword,
        'new_pwd': newPassword,
        'new_pwd_confirmation': confirmPassword,
      });
      
      print("✅ Change Password API called with URL: /change-password/$userId");
      
      // Handle response properly
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else if (response.data is String) {
        return {
          'status_code': response.statusCode ?? 200,
          'status': response.statusCode == 200 ? 'success' : 'error',
          'message': response.data,
        };
      } else {
        return {
          'status_code': response.statusCode ?? 500,
          'status': 'error',
          'message': 'Invalid response format',
        };
      }
    } catch (e) {
      print("❌ Error in ChangePasswordRemoteDataSource: $e");
      return {
        'status_code': 500,
        'status': 'error',
        'message': e.toString(),
      };
    }
  }
}