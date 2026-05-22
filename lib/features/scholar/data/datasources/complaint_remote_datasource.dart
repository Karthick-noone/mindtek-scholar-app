import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/api_client.dart';

class ComplaintRemoteDataSource {
  final ApiClient apiClient;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  ComplaintRemoteDataSource(this.apiClient);

  // Get complaints by scholar ID with pagination and filters
  Future<Map<String, dynamic>> getComplaints({
    required int scholarId,
    required int page,
    required int perPage,
    required String status,
    required String search,
  }) async {
    print("========== GET COMPLAINTS API CALL ==========");
    print("📤 Request Method: GET");
    
    String url = '/scholar/complaints/$scholarId?page=$page&per_page=$perPage';
    
    if (status != 'all') {
      url += '&status=$status';
      print("📌 Filtering by status: $status");
    }
    
    if (search.isNotEmpty) {
      url += '&search=${Uri.encodeComponent(search)}';
      print("🔍 Searching for: $search");
    }
    
    print("📤 Request URL: $url");
    print("📤 Scholar ID: $scholarId");
    print("📤 Page: $page, Per Page: $perPage");
    print("⏰ Timestamp: ${DateTime.now()}");

    try {
      final token = await storage.read(key: 'access_token');
      
      final response = await apiClient.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print("📥 Response Status Code: ${response.statusCode}");
      print("📥 Response Data: ${response.data}");
      print("========== GET COMPLAINTS API CALL COMPLETED ==========\n");

      return response.data;
    } catch (e) {
      print("❌ ERROR IN GET COMPLAINTS API CALL ==========");
      print("❌ Error: $e");
      print("===========================================\n");
      throw Exception("Failed to fetch complaints: $e");
    }
  }

  // Store new complaint
  Future<Map<String, dynamic>> storeComplaint(Map<String, dynamic> data) async {
    print("========== STORE COMPLAINT API CALL ==========");
    print("📤 Request Method: POST");
    print("📤 Request URL: /store/complaint");
    print("📤 Request Data: $data");
    print("⏰ Timestamp: ${DateTime.now()}");

    try {
      final token = await storage.read(key: 'access_token');
      
      final response = await apiClient.post(
        '/store/complaint',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print("📥 Response Status Code: ${response.statusCode}");
      print("📥 Response Data: ${response.data}");
      print("========== STORE COMPLAINT API CALL COMPLETED ==========\n");

      return response.data;
    } catch (e) {
      print("❌ ERROR IN STORE COMPLAINT API CALL ==========");
      print("❌ Error: $e");
      print("===========================================\n");
      throw Exception("Failed to store complaint: $e");
    }
  }

  // Get complaint counts
  Future<Map<String, dynamic>> getComplaintCounts(int scholarId) async {
    print("========== GET COMPLAINT COUNTS API CALL ==========");
    print("📤 Request Method: GET");
    print("📤 Request URL: /complaints/count/$scholarId");
    print("📤 Scholar ID: $scholarId");
    print("⏰ Timestamp: ${DateTime.now()}");

    try {
      final token = await storage.read(key: 'access_token');
      
      final response = await apiClient.get(
        '/complaints/count/$scholarId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print("📥 Response Status Code: ${response.statusCode}");
      print("📥 Response Data: ${response.data}");
      print("========== GET COMPLAINT COUNTS API CALL COMPLETED ==========\n");

      return response.data;
    } catch (e) {
      print("❌ ERROR IN GET COMPLAINT COUNTS API CALL ==========");
      print("❌ Error: $e");
      print("==================================================\n");
      throw Exception("Failed to fetch complaint counts: $e");
    }
  }

  // Update rating
  Future<Map<String, dynamic>> updateRating(int complaintId, Map<String, dynamic> data) async {
    print("========== UPDATE RATING API CALL ==========");
    print("📤 Request Method: POST");
    print("📤 Request URL: /update-rating/$complaintId");
    print("📤 Complaint ID: $complaintId");
    print("📤 Rating Data: $data");
    print("⏰ Timestamp: ${DateTime.now()}");

    try {
      final token = await storage.read(key: 'access_token');
      
      final response = await apiClient.post(
        '/update-rating/$complaintId',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print("📥 Response Status Code: ${response.statusCode}");
      print("📥 Response Data: ${response.data}");
      print("========== UPDATE RATING API CALL COMPLETED ==========\n");

      return response.data;
    } catch (e) {
      print("❌ ERROR IN UPDATE RATING API CALL ==========");
      print("❌ Error: $e");
      print("===========================================\n");
      throw Exception("Failed to update rating: $e");
    }
  }

  // Delete complaint
  Future<Map<String, dynamic>> deleteComplaint(int complaintId) async {
    print("========== DELETE COMPLAINT API CALL ==========");
    print("📤 Request Method: DELETE");
    print("📤 Request URL: /complaint/delete/$complaintId");
    print("📤 Complaint ID: $complaintId");
    print("⏰ Timestamp: ${DateTime.now()}");

    try {
      final token = await storage.read(key: 'access_token');
      
      final response = await apiClient.delete(
        '/complaint/delete/$complaintId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print("📥 Response Status Code: ${response.statusCode}");
      print("📥 Response Data: ${response.data}");
      print("========== DELETE COMPLAINT API CALL COMPLETED ==========\n");

      return response.data;
    } catch (e) {
      print("❌ ERROR IN DELETE COMPLAINT API CALL ==========");
      print("❌ Error: $e");
      print("===========================================\n");
      throw Exception("Failed to delete complaint: $e");
    }
  }
}