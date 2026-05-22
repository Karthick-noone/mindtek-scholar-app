import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../features/scholar/data/repositories/work_progress_repository.dart';

class WorkProgressProvider extends ChangeNotifier {
  final WorkProgressRepository repository;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  
  WorkProgressProvider(this.repository);
  
  bool isLoading = false;
  Map<String, dynamic>? workProgress;
  String? error;
  
  // Work progress specific fields
  int progressPercentage = 0;
  String lastUpdateDate = '';
  String latestNote = '';
  
  Future<void> fetchWorkProgress() async {
    isLoading = true;
    notifyListeners();
    
    try {
      // Get scholar ID from storage
      String? scholarIdStr = await storage.read(key: 'reg_id');
      int? scholarId = scholarIdStr != null ? int.tryParse(scholarIdStr) : null;
      
      if (scholarId == null || scholarId == 0) {
        throw Exception("Scholar ID not found");
      }
      
      // Call API
      final response = await repository.getLastWorkStatus(scholarId);
      
      print("📥 Work Progress API Response: $response");
      
      // Handle response
      if (response['status_code'] == 200) {
        // Get data from response
        final data = response['data'] ?? {};
        
        workProgress = Map<String, dynamic>.from(data);
        
        // Extract values
        progressPercentage = (data['status'] ?? 0) as int;
        lastUpdateDate = data['date'] ?? '';
        latestNote = data['note'] ?? '';
        
        error = null;
        
        print("✅ Work Progress - Status: $progressPercentage%, Date: $lastUpdateDate, Note: $latestNote");
      } else {
        workProgress = null;
        progressPercentage = 0;
        lastUpdateDate = '';
        latestNote = '';
        error = response['message'] ?? 'Failed to load work progress';
      }
    } catch (e) {
      error = e.toString();
      workProgress = null;
      progressPercentage = 0;
      lastUpdateDate = '';
      latestNote = '';
      print("❌ Error fetching work progress: $error");
    }
    
    isLoading = false;
    notifyListeners();
  }
  
  void clearData() {
    workProgress = null;
    error = null;
    isLoading = false;
    progressPercentage = 0;
    lastUpdateDate = '';
    latestNote = '';
    notifyListeners();
  }
}