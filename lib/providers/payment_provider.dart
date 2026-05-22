// lib/providers/payment_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../features/scholar/data/repositories/payment_repository.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository repository;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  
  PaymentProvider(this.repository);
  
  bool isLoading = false;
  List<Map<String, dynamic>> payments = [];
  String? error;
  
  // Company details getters for receipt (if needed from payment data)
  String get companyName => payments.isNotEmpty ? payments.first['company_name'] ?? '' : '';
  String get companyAddress => payments.isNotEmpty ? payments.first['company_address'] ?? '' : '';
  String get companyEmail => payments.isNotEmpty ? payments.first['company_email'] ?? '' : '';
  String get companyContact => payments.isNotEmpty ? payments.first['company_contact'] ?? '' : '';
  String get companyLogo => payments.isNotEmpty ? payments.first['company_logo'] ?? '' : '';
  
  Future<void> fetchPayments() async {
    isLoading = true;
    notifyListeners();
    
    try {
      // Get scholar ID from storage
      String? regId = await storage.read(key: 'reg_id');
      String? scholarId = regId ?? await storage.read(key: 'user_id');
      
      if (scholarId == null || scholarId.isEmpty) {
        throw Exception("Scholar ID not found");
      }
      
      // Call API with just scholar ID (no page/limit needed)
      final response = await repository.getPayments(scholarId);
      
      print("📥 Payment API Response: $response");
      
      // Handle response based on your API structure
      // Check if response has status_code or status field
      if (response['status_code'] == 200 || response['status'] == 'success') {
        // If data is in 'data' field and it's a List
        if (response['data'] != null && response['data'] is List) {
          payments = List<Map<String, dynamic>>.from(response['data'] as List);
        } 
        // If response has payments array and it's a List
        else if (response['payments'] != null && response['payments'] is List) {
          payments = List<Map<String, dynamic>>.from(response['payments'] as List);
        }
        // If single payment object returned
        else if (response['id'] != null) {
          payments = [response];
        }
        else {
          // If response is empty or unexpected structure
          payments = [];
          print("⚠️ Unexpected response structure: ${response.keys}");
        }
        error = null;
      } else {
        payments = [];
        error = response['message'] ?? 'Failed to load payments';
      }
          
      print("✅ Loaded ${payments.length} payments");
    } catch (e) {
      error = e.toString();
      payments = [];
      print("❌ Error fetching payments: $error");
    }
    
    isLoading = false;
    notifyListeners();
  }
  
  void clearData() {
    payments = [];
    error = null;
    isLoading = false;
    notifyListeners();
  }
}