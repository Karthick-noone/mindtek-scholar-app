import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../features/scholar/data/repositories/complaint_repository.dart';

class ComplaintProvider extends ChangeNotifier {
  final ComplaintRepository repository;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  
  ComplaintProvider(this.repository);
  
  bool isLoading = false;
  List<Map<String, dynamic>> complaints = [];
  String? error;
  
  // Pagination & Filter State
  int currentPage = 1;
  int totalPages = 1;
  int totalCount = 0;
  int rowsPerPage = 10;
  String filterStatus = 'all';
  String searchTerm = '';
  
  // Counts - Initialize with 0
  int totalComplaints = 0;
  int pendingCount = 0;
  int inProgressCount = 0;
  int resolvedCount = 0;
  
  Future<void> fetchComplaints({
    int? page,
    int? perPage,
    String? status,
    String? search,
    bool reset = false,
  }) async {
    if (reset) {
      currentPage = 1;
    }
    
    isLoading = true;
    notifyListeners();
    
    try {
      // Get scholar ID from storage
      String? scholarIdStr = await storage.read(key: 'reg_id');
      int? scholarId = scholarIdStr != null ? int.tryParse(scholarIdStr) : null;
      
      if (scholarId == null || scholarId == 0) {
        throw Exception("Scholar ID not found");
      }
      
      // Update pagination/filter values
      if (page != null) currentPage = page;
      if (perPage != null) rowsPerPage = perPage;
      if (status != null) filterStatus = status;
      if (search != null) searchTerm = search;
      
      // Call API - if status is 'all', send empty string
      final response = await repository.getComplaints(
        scholarId: scholarId,
        page: currentPage,
        perPage: rowsPerPage,
        status: filterStatus == 'all' ? '' : filterStatus,
        search: searchTerm,
      );
      
      print("📥 Complaint API Response: $response");
      
      // Handle response
      if (response['status_code'] == 200) {
        // Get data array
        List<dynamic> dataList = response['data'] ?? [];
        
        // Convert and fix type issues
        complaints = dataList.map((item) {
          Map<String, dynamic> complaint = Map<String, dynamic>.from(item);
          
          // Ensure ratings is int (handle null)
          if (complaint['ratings'] == null) {
            complaint['ratings'] = 0;
          } else if (complaint['ratings'] is String) {
            complaint['ratings'] = int.tryParse(complaint['ratings']) ?? 0;
          } else if (complaint['ratings'] is int) {
            complaint['ratings'] = complaint['ratings'];
          } else {
            complaint['ratings'] = 0;
          }
          
          // Ensure status is properly formatted
          if (complaint['status'] != null) {
            String statusText = complaint['status'].toString();
            if (statusText.toLowerCase() == 'in progress') {
              complaint['status'] = 'In Progress';
            } else if (statusText.toLowerCase() == 'resolved') {
              complaint['status'] = 'Resolved';
            } else if (statusText.toLowerCase() == 'pending') {
              complaint['status'] = 'Pending';
            }
          }
          
          return complaint;
        }).toList();
        
        totalCount = response['count'] ?? dataList.length;
        totalPages = (totalCount + rowsPerPage - 1) ~/ rowsPerPage;
        error = null;
        
        print("✅ Loaded ${complaints.length} complaints");
        print("✅ Total count: $totalCount");
        print("✅ Total pages: $totalPages");
      } else {
        complaints = [];
        totalCount = 0;
        error = response['message'] ?? 'Failed to load complaints';
      }
    } catch (e) {
      error = e.toString();
      complaints = [];
      totalCount = 0;
      print("❌ Error fetching complaints: $error");
    }
    
    isLoading = false;
    notifyListeners();
  }
  
  Future<void> fetchComplaintCounts() async {
    try {
      // Get scholar ID from storage
      String? scholarIdStr = await storage.read(key: 'reg_id');
      int? scholarId = scholarIdStr != null ? int.tryParse(scholarIdStr) : null;
      
      if (scholarId == null || scholarId == 0) {
        print("⚠️ Scholar ID not found for counts");
        return;
      }
      
      final response = await repository.getComplaintCounts(scholarId);
      
      print("📊 Counts API Response: $response");
      
      if (response['status_code'] == 200) {
        // The counts are inside a 'counts' object
        final counts = response['counts'] ?? response;
        
        totalComplaints = (counts['total_complaints'] ?? 0) as int;
        pendingCount = (counts['pending'] ?? 0) as int;
        inProgressCount = (counts['in_progress'] ?? 0) as int;
        resolvedCount = (counts['resolved'] ?? 0) as int;
        
        print("✅ Counts - Total: $totalComplaints, Pending: $pendingCount, In Progress: $inProgressCount, Resolved: $resolvedCount");
        notifyListeners();
      } else {
        print("⚠️ Invalid counts response: $response");
      }
    } catch (e) {
      print("❌ Error fetching counts: $e");
    }
  }
  
  Future<bool> addComplaint(Map<String, dynamic> data) async {
    isLoading = true;
    notifyListeners();
    
    try {
      final response = await repository.storeComplaint(data);
      
       if (response['status_code'] == 200 || 
        response['status_code'] == 201 || 
        response['status'] == 'success') {
        await fetchComplaints(reset: true);
        await fetchComplaintCounts();
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Error adding complaint: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> rateComplaint(int complaintId, int rating) async {
    try {
      final response = await repository.updateRating(complaintId, rating);
      
      if (response['status_code'] == 200) {
        await fetchComplaints();
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Error rating complaint: $e");
      return false;
    }
  }
  
  Future<bool> removeComplaint(int complaintId) async {
    try {
      final response = await repository.deleteComplaint(complaintId);
      
      if (response['status_code'] == 200) {
        await fetchComplaints(reset: true);
        await fetchComplaintCounts();
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Error deleting complaint: $e");
      return false;
    }
  }
  
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      fetchComplaints(page: page);
    }
  }
  
  void setFilterStatus(String status) {
    if (filterStatus == status) return;
    filterStatus = status;
    fetchComplaints(reset: true);
  }
  
  void setSearchTerm(String term) {
    if (searchTerm == term) return;
    searchTerm = term;
    fetchComplaints(reset: true);
  }
  
  void setRowsPerPage(int rows) {
    if (rowsPerPage == rows) return;
    rowsPerPage = rows;
    fetchComplaints(reset: true);
  }
  
  void clearSearch() {
    if (searchTerm.isEmpty) return;
    searchTerm = '';
    fetchComplaints(reset: true);
  }
  
  void clearData() {
    complaints = [];
    error = null;
    isLoading = false;
    totalComplaints = 0;
    pendingCount = 0;
    inProgressCount = 0;
    resolvedCount = 0;
    currentPage = 1;
    totalPages = 1;
    totalCount = 0;
    notifyListeners();
  }
}