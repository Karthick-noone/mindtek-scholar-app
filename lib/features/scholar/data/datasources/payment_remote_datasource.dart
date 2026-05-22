// lib/features/scholar/data/datasources/payment_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class PaymentRemoteDataSource {
  final ApiClient apiClient;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  PaymentRemoteDataSource(this.apiClient);

  // Get payments by scholar ID - matches your API endpoint /sclr/payments/{id}
  Future<Map<String, dynamic>> getPayments(String scholarId) async {
    print("========== GET PAYMENTS API CALL ==========");
    print("📤 Request Method: GET");
    print("📤 Request URL: ${ApiEndpoints.payments}/$scholarId");
    print("📤 Scholar ID: $scholarId");
    print("⏰ Timestamp: ${DateTime.now()}");

    try {
      final token = await storage.read(key: 'access_token');
      
      final response = await apiClient.get(
        '${ApiEndpoints.payments}/$scholarId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print("📥 Response Status Code: ${response.statusCode}");
      print("📥 Response Data: ${response.data}");
      print("========== GET PAYMENTS API CALL COMPLETED ==========\n");

      return response.data;
    } catch (e) {
      print("❌ ERROR IN GET PAYMENTS API CALL ==========");
      print("❌ Error: $e");
      print("===========================================\n");
      throw Exception("Failed to fetch payments: $e");
    }
  }

  // Optional: Get single payment details if needed
  Future<Map<String, dynamic>> getPaymentDetails(String paymentId) async {
    print("========== GET PAYMENT DETAILS API CALL ==========");
    print("📤 Request Method: GET");
    print("📤 Request URL: ${ApiEndpoints.payments}/details/$paymentId");
    print("⏰ Timestamp: ${DateTime.now()}");

    try {
      final token = await storage.read(key: 'access_token');
      
      final response = await apiClient.get(
        '${ApiEndpoints.payments}/details/$paymentId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print("📥 Response Status Code: ${response.statusCode}");
      print("📥 Response Data: ${response.data}");
      print("========== GET PAYMENT DETAILS API CALL COMPLETED ==========\n");

      return response.data;
    } catch (e) {
      print("❌ ERROR IN GET PAYMENT DETAILS API CALL ==========");
      print("❌ Error: $e");
      print("==================================================\n");
      throw Exception("Failed to fetch payment details: $e");
    }
  }
}