import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mindtek_scholar_app/features/scholar/data/repositories/change_password_repository.dart';

class ChangePasswordProvider extends ChangeNotifier {
  final ChangePasswordRepository repository;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  
  ChangePasswordProvider(this.repository);
  
  bool isLoading = false;
  String? error;
  
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      print("\n========== CHANGE PASSWORD ==========");
      
      // Read all relevant storage keys
      final userIdForPassword = await storage.read(key: 'id');
      final changePasswordId = await storage.read(key: 'change_password_id');
      final regId = await storage.read(key: 'reg_id');
      final accessToken = await storage.read(key: 'access_token');
      
      print("📦 Storage Data:");
      print("   • 'id' key: $userIdForPassword");
      print("   • 'change_password_id': $changePasswordId");
      print("   • 'reg_id': $regId");
      print("   • 'access_token': ${accessToken != null ? '${accessToken.substring(0, 20)}...' : 'null'}");
      
      // Use the 'id' key which should store user.id (33)
      String? idToUse = userIdForPassword;
      
      if (idToUse == null || idToUse.isEmpty) {
        idToUse = changePasswordId;
        print("⚠️ 'id' key not found, using change_password_id: $idToUse");
      }
      
      if (idToUse == null || idToUse.isEmpty) {
        idToUse = regId;
        print("⚠️ Using reg_id instead: $idToUse");
      }
      
      int? userId = idToUse != null ? int.tryParse(idToUse) : null;
      
      print("\n🔑 Using ID for password change: $userId");
      print("   Expected ID from login response user.id: 33");
      
      if (userId == null || userId == 0) {
        throw Exception("No valid ID found for password change");
      }
      
      print("\n📤 Sending API Request:");
      print("   URL: /change-password");
      print("   Body: {");
      print("     id: $userId,");
      print("     data: {");
      print("       old_pwd: $oldPassword");
      print("       new_pwd: $newPassword");
      print("       new_pwd_confirmation: $confirmPassword");
      print("     }");
      print("   }");
      
      final response = await repository.changePassword(
        userId: userId,
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      
      print("\n📥 API Response:");
      print("   Status: ${response['status_code']}");
      print("   Message: ${response['message']}");
      print("=========================================\n");
      
      if (response['status_code'] == 200 || response['status'] == 'success') {
        error = null;
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        error = response['message'] ?? response['error'] ?? 'Failed to change password';
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      print("❌ Error: $error");
      print("=========================================\n");
      return false;
    }
  }
  
  void clearError() {
    error = null;
    notifyListeners();
  }
}