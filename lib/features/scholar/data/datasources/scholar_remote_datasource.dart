// lib/features/scholar/data/datasources/scholar_remote_datasource.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_client.dart';

class ScholarRemoteDataSource {
  final ApiClient apiClient;
  
  ScholarRemoteDataSource(this.apiClient);

  Future<Map<String, dynamic>> getScholarDetails(String regId) async {
    print("========== GET SCHOLAR DETAILS API CALL ==========");
    print("📤 Request Method: GET");
    print("📤 Request URL: ${ApiEndpoints.scholarDetails}/$regId");
    print("📤 Request Parameter (reg_id): $regId");
    print("⏰ Timestamp: ${DateTime.now()}");
    
    try {
      final response = await apiClient.get(
        '${ApiEndpoints.scholarDetails}/$regId',
      );
      
      print("📥 Response Status Code: ${response.statusCode}");
      print("📥 Response Data Type: ${response.data.runtimeType}");
      print("📥 Raw Response Data: ${response.data}");
      
      Map<String, dynamic> responseData;
      
      // Extract data from Dio Response
      if (response.data is Map<String, dynamic>) {
        responseData = response.data as Map<String, dynamic>;
        print("✅ Response is Map<String, dynamic>");
        print("📊 Response Map Keys: ${responseData.keys}");
      } else if (response.data is String) {
        print("📥 Response is String, decoding JSON...");
        responseData = json.decode(response.data) as Map<String, dynamic>;
        print("✅ Successfully decoded JSON string");
        print("📊 Decoded Data Keys: ${responseData.keys}");
      } else {
        responseData = response.data as Map<String, dynamic>;
        print("⚠️ Unexpected response type, casting to Map");
      }
      
      // Log response details
      if (responseData.containsKey('status')) {
        print("📊 Response Status: ${responseData['status']}");
      }
      if (responseData.containsKey('status_code')) {
        print("📊 Response Status Code: ${responseData['status_code']}");
      }
      
      // IMPORTANT: Always return the FULL response, not just the data
      // This preserves the nested structure including domain, company, bda, etc.
      print("✅ Returning FULL response with keys: ${responseData.keys}");
      print("📊 Response contains 'data' key: ${responseData.containsKey('data')}");
      
      if (responseData.containsKey('data')) {
        final dataObj = responseData['data'] as Map<String, dynamic>;
        print("📊 Data object contains these keys: ${dataObj.keys}");
        print("📊 Domain exists in data: ${dataObj.containsKey('domain')}");
        print("📊 Company exists in data: ${dataObj.containsKey('company')}");
        print("📊 BDA exists in data: ${dataObj.containsKey('bda')}");
        print("📊 Work Status exists: ${dataObj.containsKey('work_status')}");
        print("📊 Tech Expert exists: ${dataObj.containsKey('tech_expert')}");
        print("📊 Journal Index exists: ${dataObj.containsKey('journal_index')}");
        print("📊 Work Type exists: ${dataObj.containsKey('work_type')}");
      }
      
      print("========== API CALL COMPLETED SUCCESSFULLY ==========\n");
      return responseData; // Return FULL response with status_code, status, and data
      
    } catch (e) {
      print("❌ ERROR IN API CALL ==========");
      print("❌ Error Type: ${e.runtimeType}");
      print("❌ Error Message: $e");
      print("================================\n");
      throw Exception("Failed to fetch scholar details: $e");
    }
  }


 // Upload profile image
  Future<Map<String, dynamic>> uploadProfileImage(String scholarId, File imageFile) async {
    try {
      // Create form data for the image
      String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      FormData formData = FormData.fromMap({
        'scholar_profile': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await apiClient.post(
        '${ApiEndpoints.uploadProfileImage}/$scholarId',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw Exception("Failed to upload profile image: $e");
    }
  }

  
  // Delete profile image
// Delete profile image - Using POST method with remove parameter
Future<Map<String, dynamic>> deleteProfileImage(String scholarId) async {
  print("========== DELETE PROFILE IMAGE API CALL ==========");
  print("📤 Request Method: POST");
  print("📤 Request URL: ${ApiEndpoints.deleteProfileImage}/$scholarId");
  print("📤 Scholar ID: $scholarId");
  print("📤 Request Body: {remove: 1}");
  print("⏰ Timestamp: ${DateTime.now()}");
  
  try {
    final response = await apiClient.post(
      '${ApiEndpoints.deleteProfileImage}/$scholarId',
      data: {
        'remove': 1,  // Send remove parameter
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    
    print("📥 Response Status Code: ${response.statusCode}");
    print("📥 Response Data: ${response.data}");
    print("========== DELETE API CALL COMPLETED ==========\n");
    
    return response.data;
  } catch (e) {
    print("❌ ERROR IN DELETE API CALL ==========");
    print("❌ Error: $e");
    print("=====================================\n");
    throw Exception("Failed to delete profile image: $e");
  }
}


  Future<Map<String, dynamic>> updateProfile(String regId, Map<String, dynamic> updates) async {
    print("========== UPDATE PROFILE API CALL ==========");
    print("📤 Request Method: PUT");
    print("📤 Request URL: ${ApiEndpoints.updateProfile}/$regId");
    print("📤 Request Parameter (reg_id): $regId");
    print("📤 Update Data: $updates");
    print("⏰ Timestamp: ${DateTime.now()}");
    
    try {
      final response = await apiClient.put(
        '${ApiEndpoints.updateProfile}/$regId',
        data: updates,
      );
      
      print("📥 Response Status Code: ${response.statusCode}");
      print("📥 Response Data: ${response.data}");
      
      if (response.data is Map<String, dynamic>) {
        print("✅ Response is Map<String, dynamic>");
        final responseMap = response.data as Map<String, dynamic>;
        print("📊 Response Keys: ${responseMap.keys}");
        print("========== UPDATE API CALL COMPLETED ==========\n");
        return responseMap;
        
      } else if (response.data is String) {
        print("📥 Response is String, decoding JSON...");
        final decodedData = json.decode(response.data) as Map<String, dynamic>;
        print("✅ Successfully decoded response");
        print("========== UPDATE API CALL COMPLETED ==========\n");
        return decodedData;
        
      } else {
        final Map<String, dynamic> responseData = response.data;
        print("📊 Response Data: $responseData");
        
        if (responseData.containsKey('success') && responseData['success'] == true) {
          print("✅ Update successful");
          if (responseData.containsKey('data')) {
            print("✅ Found nested 'data' object");
            print("========== UPDATE API CALL COMPLETED ==========\n");
            return responseData['data'] as Map<String, dynamic>;
          }
        }
        
        print("========== UPDATE API CALL COMPLETED ==========\n");
        return responseData;
      }
      
    } catch (e) {
      print("❌ ERROR IN UPDATE API CALL ==========");
      print("❌ Error: $e");
      print("=====================================\n");
      throw Exception("Failed to update profile: $e");
    }
  }

  Future<Map<String, dynamic>> changePassword(String regId, String oldPassword, String newPassword) async {
    print("========== CHANGE PASSWORD API CALL ==========");
    print("📤 Request Method: POST");
    print("📤 Request URL: ${ApiEndpoints.changePassword}");
    print("📤 Request Data: {scholar_id: $regId, old_password: ***, new_password: ***}");
    print("⏰ Timestamp: ${DateTime.now()}");
    
    try {
      final response = await apiClient.post(
        ApiEndpoints.changePassword,
        data: {
          'scholar_id': regId,
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
      
      print("📥 Response Status Code: ${response.statusCode}");
      print("📥 Response Data: ${response.data}");
      
      if (response.data is Map<String, dynamic>) {
        print("✅ Password change response received");
        print("========== PASSWORD CHANGE API CALL COMPLETED ==========\n");
        return response.data as Map<String, dynamic>;
        
      } else if (response.data is String) {
        print("📥 Response is String, decoding JSON...");
        final decodedData = json.decode(response.data) as Map<String, dynamic>;
        print("✅ Successfully decoded response");
        print("========== PASSWORD CHANGE API CALL COMPLETED ==========\n");
        return decodedData;
        
      } else {
        print("========== PASSWORD CHANGE API CALL COMPLETED ==========\n");
        return response.data as Map<String, dynamic>;
      }
      
    } catch (e) {
      print("❌ ERROR IN PASSWORD CHANGE API CALL ==========");
      print("❌ Error: $e");
      print("===============================================\n");
      throw Exception("Failed to change password: $e");
    }
  }

  
}

