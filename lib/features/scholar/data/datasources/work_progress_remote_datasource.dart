import 'package:mindtek_scholar_app/core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class WorkProgressRemoteDataSource {
  final ApiClient apiClient;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  
  WorkProgressRemoteDataSource(this.apiClient);
  
  Future<Map<String, dynamic>> getLastWorkStatus(int scholarId) async {
    try {
      final token = await storage.read(key: 'access_token');

      final response = await apiClient.get('${ApiEndpoints.workStatus}/$scholarId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),);
      return response.data;
    } catch (e) {
      print("Error in WorkProgressRemoteDataSource: $e");
      return {
        'status_code': 500,
        'status': 'error',
        'message': e.toString(),
        'data': null
      };
    }
  }
}