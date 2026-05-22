// lib/providers/scholar_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../features/scholar/data/repositories/scholar_repository.dart';

class ScholarProvider extends ChangeNotifier {
  final ScholarRepository repository;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  ScholarProvider(this.repository);

  bool isLoading = false;
  bool isUploadingImage = false;
  Map<String, dynamic>? scholar;
  Map<String, dynamic>? company;
  Map<String, dynamic>? domainDetails;
  Map<String, dynamic>? bdaDetails;
  Map<String, dynamic>? workStatusDetails;
  String? error;

  // Getters for scholar data
  String get name => scholar?['user_name'] ?? '';
  String get scholarId => scholar?['user_id'] ?? '';
  String get regId => scholar?['id']?.toString() ?? '';
  String get mobile => scholar?['contact'] ?? '';
  String get email => scholar?['email'] ?? '';
  String get regDate => scholar?['reg_date'] ?? '';

  String get formattedRegDate {
    final date = scholar?['reg_date'];
    if (date == null || date.isEmpty) return '';

    try {
      final parsedDate = DateTime.parse(date);

      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];

      final day = parsedDate.day.toString().padLeft(2, '0');
      final month = months[parsedDate.month - 1];
      final year = parsedDate.year;

      return '$day $month $year';
    } catch (e) {
      return date.toString();
    }
  }

  String get scholarProfileImage {
    final profilePath = scholar?['scholar_profile'];
    if (profilePath != null && profilePath.toString().isNotEmpty) {
      final fullUrl = 'http://scholarapi.seasense.in/$profilePath';
      return fullUrl;
    }
    return '';
  }

  String get techExpert {
    final techExpertData = scholar?['tech_expert'];
    if (techExpertData is Map<String, dynamic>) {
      return techExpertData['staff_name'] ?? 'Not Assigned';
    }
    return 'Not Assigned';
  }

  String get techExpertContact {
    final techExpertData = scholar?['tech_expert'];
    if (techExpertData is Map<String, dynamic>) {
      return techExpertData['staff_contact'] ?? 'Not Assigned';
    }
    return 'Not Assigned';
  }

  // FIXED: Domain Name - Now handles simple string value (not an array)
  String get domainName {
    // Try to get domain directly from scholar as a string
    final domain = scholar?['domain_nm'] ?? scholar?['domain'];
    
    // If it's a string, return it directly
    if (domain is String && domain.isNotEmpty) {
      return domain;
    }
    
    // If it's a Map/object, try to extract the value
    if (domain is Map<String, dynamic>) {
      return domain['domain_nm']?.toString() ?? 
             domain['domain']?.toString() ?? 
             'Not Assigned';
    }
    
    // Fallback to domainDetails if available
    if (domainDetails != null) {
      return domainDetails!['domain_nm']?.toString() ?? 
             domainDetails!['domain']?.toString() ?? 
             'Not Assigned';
    }
    
    return 'Not Assigned';
  }

  String get bdaName {
    final bdaData = scholar?['bda'];
    if (bdaData is Map<String, dynamic>) {
      return bdaData['bda_name'] ?? 'Not Assigned';
    }
    return 'Not Assigned';
  }

  String get bdaContact {
    final bdaData = scholar?['bda'];
    if (bdaData is Map<String, dynamic>) {
      return bdaData['bda_contact'] ?? 'Not Assigned';
    }
    return 'Not Assigned';
  }

  String get completion {
    final workStatusData = workStatusDetails;
    if (workStatusData != null) {
      final status = workStatusData['work_sts']?.toString().toLowerCase() ?? '';
      switch (status) {
        case 'pending':
          return '25%';
        case 'in progress':
          return '50%';
        case 'review':
          return '75%';
        case 'completed':
          return '100%';
        default:
          return '0%';
      }
    }
    return '0%';
  }

  String get workDesc => scholar?['work_description'] ?? 'No description available';
  String get scholarProfile => scholar?['scholar_profile'] ?? '';
  String get scholarStatus => scholar?['scholar_status'] ?? '';
  String get approvalStatus => scholar?['aprvl_status'] ?? '';
  String get totalAmount => scholar?['total_amt'] ?? '0';
  String get initialAmount => scholar?['initial_amt'] ?? '0';
  String get workStartDate => scholar?['work_start_on'] ?? '';
  String get workDeadline => scholar?['work_dl_on'] ?? '';
  String get gstStatus => scholar?['gst_status'] ?? '';

  // Company details getters with multiple fallback options
  String get companyName {
    if (company != null && company!['company_name'] != null) {
      return company!['company_name'].toString();
    }
    if (scholar != null && scholar!['company'] != null) {
      final companyData = scholar!['company'];
      if (companyData is Map<String, dynamic>) {
        return companyData['company_name']?.toString() ?? '';
      }
    }
    return '';
  }

  String get companyContact {
    if (company != null && company!['com_contact'] != null) {
      return company!['com_contact'].toString();
    }
    if (scholar != null && scholar!['company'] != null) {
      final companyData = scholar!['company'];
      if (companyData is Map<String, dynamic>) {
        return companyData['com_contact']?.toString() ?? '';
      }
    }
    return '';
  }

  String get companyEmail {
    if (company != null && company!['email_id'] != null) {
      return company!['email_id'].toString();
    }
    if (scholar != null && scholar!['company'] != null) {
      final companyData = scholar!['company'];
      if (companyData is Map<String, dynamic>) {
        return companyData['email_id']?.toString() ?? '';
      }
    }
    return '';
  }

  String get companyAddress {
    if (company != null && company!['address'] != null) {
      return company!['address'].toString();
    }
    if (scholar != null && scholar!['company'] != null) {
      final companyData = scholar!['company'];
      if (companyData is Map<String, dynamic>) {
        return companyData['address']?.toString() ?? '';
      }
    }
    return '';
  }

  String get companyLogo {
    if (company != null && company!['com_logo'] != null) {
      final logoPath = company!['com_logo'].toString();
      if (logoPath.isNotEmpty) {
        final fullUrl = 'http://scholarapi.seasense.in/$logoPath';
        print("🏢 Company Logo URL: $fullUrl");
        return fullUrl;
      }
    }
    if (scholar != null && scholar!['company'] != null) {
      final companyData = scholar!['company'];
      if (companyData is Map<String, dynamic>) {
        final logoPath = companyData['com_logo']?.toString() ?? '';
        if (logoPath.isNotEmpty) {
          final fullUrl = 'http://scholarapi.seasense.in/$logoPath';
          print("🏢 Company Logo URL from scholar: $fullUrl");
          return fullUrl;
        }
      }
    }
    print("⚠️ No company logo found");
    return '';
  }

  String get workType {
    final workTypeData = scholar?['work_type'];
    if (workTypeData is Map<String, dynamic>) {
      return workTypeData['work_type'] ?? '';
    }
    return '';
  }

  String get domain {
    final domainData = domainDetails;
    if (domainData != null) {
      return domainData['domain'] ?? '';
    }
    return '';
  }

  String get journalIndex {
    final journalData = scholar?['journal_index'];
    if (journalData is Map<String, dynamic>) {
      return journalData['journal_index'] ?? '';
    }
    return '';
  }

  String get workStatus {
    final workStatusData = workStatusDetails;
    if (workStatusData != null) {
      return workStatusData['work_sts'] ?? 'Unknown';
    }
    return 'Unknown';
  }

  String get companyLocation => company?['location'] ?? '';
  String get companyGST => company?['gst'] ?? '';

  List<String> get secondaryEmails {
    final secondaryEmailsData = scholar?['secondary_emails'];
    if (secondaryEmailsData is List) {
      return secondaryEmailsData.map((e) => e.toString()).toList();
    }
    return [];
  }

  bool get hasSecondaryEmails => secondaryEmails.isNotEmpty;

  Future<void> fetchScholar() async {
    isLoading = true;
    notifyListeners();

    try {
      String? regId = await storage.read(key: 'reg_id');

      if (regId == null || regId.isEmpty) {
        final userId = await storage.read(key: 'user_id');
        if (userId != null && userId.isNotEmpty) {
          regId = userId;
          print("Using user_id as reg_id: $regId");
        } else {
          throw Exception("No reg_id or user_id found in storage. Please login again.");
        }
      }

      print("Fetching scholar details for reg_id: $regId");

      final response = await repository.getScholarDetails(regId);

      if (response != null) {
        print("📊 Response keys: ${response.keys}");

        if (response.containsKey('data') && response['data'] != null) {
          final dataObject = response['data'] as Map<String, dynamic>;
          scholar = dataObject;
          print(" Extracted scholar from 'data' key");
          print("📊 Data object keys: ${dataObject.keys}");

          if (scholar?['id'] != null) {
            await storage.write(key: 'reg_id', value: scholar!['id'].toString());
            print(" Stored reg_id: ${scholar!['id']}");
          }

          if (dataObject.containsKey('company') && dataObject['company'] != null) {
            company = dataObject['company'] as Map<String, dynamic>;
            print(" Extracted company details: ${company?['company_name']}");
          }

          if (dataObject.containsKey('domain') && dataObject['domain'] != null) {
            domainDetails = dataObject['domain'] as Map<String, dynamic>;
            print(" Extracted domain: ${domainDetails?['domain']}");
          }

          if (dataObject.containsKey('bda') && dataObject['bda'] != null) {
            bdaDetails = dataObject['bda'] as Map<String, dynamic>;
            print(" Extracted BDA: ${bdaDetails?['bda_name']}");
          }

          if (dataObject.containsKey('work_status') && dataObject['work_status'] != null) {
            workStatusDetails = dataObject['work_status'] as Map<String, dynamic>;
            print(" Extracted work status: ${workStatusDetails?['work_sts']}");
          }
        } else if (response.containsKey('scholar')) {
          scholar = response['scholar'] as Map<String, dynamic>;
          print(" Extracted scholar from 'scholar' key");
        } else {
          scholar = response;
          print(" Using response directly as scholar data");
        }

        error = null;
        print(" Scholar data loaded successfully:");
        print("   - Name: ${scholar?['user_name']}");
        print("   - ID: ${scholar?['id']}");
        print("   - User ID: ${scholar?['user_id']}");
        print("   - Email: ${scholar?['email']}");
        print("   - Contact: ${scholar?['contact']}");
        print("   - Domain Name: ${scholar?['domain_nm'] ?? scholar?['domain']}");
        print("   - Company: ${company?['company_name']}");
        print("   - BDE: ${bdaDetails?['bda_name']}");
        print("   - Work Status: ${workStatusDetails?['work_sts']}");

        if (scholar?['tech_expert'] is Map) {
          final techExpertMap = scholar!['tech_expert'] as Map;
          print("   - Technical Expert: ${techExpertMap['staff_name']}");
        }
      } else {
        throw Exception("No data received from server");
      }
    } catch (e) {
      error = e.toString();
      print("❌ Error fetching scholar: $error");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> uploadProfileImage(File imageFile) async {
    isUploadingImage = true;
    notifyListeners();

    try {
      final scholarId = scholar?['id']?.toString();
      if (scholarId == null || scholarId.isEmpty) {
        throw Exception("Scholar ID not found");
      }

      print("📤 Uploading profile image for scholar ID: $scholarId");
      
      final response = await repository.uploadProfileImage(scholarId, imageFile);
      
      if (response['status_code'] == 200 || response['status'] == 'success') {
        print("✅ Image uploaded successfully");
        await fetchScholar();
        isUploadingImage = false;
        notifyListeners();
        return true;
      } else {
        throw Exception(response['message'] ?? "Failed to upload image");
      }
    } catch (e) {
      print("❌ Error uploading profile image: $e");
      error = e.toString();
      isUploadingImage = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProfileImage() async {
    isUploadingImage = true;
    notifyListeners();

    try {
      final scholarId = scholar?['id']?.toString();
      if (scholarId == null || scholarId.isEmpty) {
        throw Exception("Scholar ID not found");
      }

      print("🗑️ Deleting profile image for scholar ID: $scholarId");
      
      final response = await repository.deleteProfileImage(scholarId);
      
      if (response['status_code'] == 200 || response['status'] == 'success') {
        print("✅ Image deleted successfully");
        await fetchScholar();
        isUploadingImage = false;
        notifyListeners();
        return true;
      } else {
        throw Exception(response['message'] ?? "Failed to delete image");
      }
    } catch (e) {
      print("❌ Error deleting profile image: $e");
      error = e.toString();
      isUploadingImage = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updatedData) async {
    isLoading = true;
    notifyListeners();

    try {
      final regId = await storage.read(key: 'reg_id');
      if (regId == null || regId.isEmpty) {
        throw Exception("No scholar ID found. Please login again.");
      }

      await fetchScholar();

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearData() {
    scholar = null;
    company = null;
    domainDetails = null;
    bdaDetails = null;
    workStatusDetails = null;
    error = null;
    isLoading = false;
    isUploadingImage = false;
    notifyListeners();
  }
}