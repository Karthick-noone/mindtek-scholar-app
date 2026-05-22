// lib/features/scholar/data/repositories/scholar_repository.dart
import 'dart:io';
import '../datasources/scholar_remote_datasource.dart';

class ScholarRepository {
  final ScholarRemoteDataSource remoteDataSource;

  ScholarRepository(this.remoteDataSource);

  Future<Map<String, dynamic>> getScholarDetails(String scholarId) async {
    try {
      final response = await remoteDataSource.getScholarDetails(scholarId);
      
      // Handle different response structures
      if (response.containsKey('data')) {
        return response['data'] as Map<String, dynamic>;
      } else if (response.containsKey('scholar')) {
        return response['scholar'] as Map<String, dynamic>;
      } else {
        return response;
      }
    } catch (e) {
      throw Exception("Failed to get scholar details: $e");
    }
  }

  Future<Map<String, dynamic>> updateProfile(String scholarId, Map<String, dynamic> updates) async {
    try {
      final response = await remoteDataSource.updateProfile(scholarId, updates);
      return response;
    } catch (e) {
      throw Exception("Failed to update profile: $e");
    }
  }

  Future<Map<String, dynamic>> changePassword(String scholarId, String oldPassword, String newPassword) async {
    try {
      final response = await remoteDataSource.changePassword(scholarId, oldPassword, newPassword);
      return response;
    } catch (e) {
      throw Exception("Failed to change password: $e");
    }
  }

  // Upload profile image
  Future<Map<String, dynamic>> uploadProfileImage(String scholarId, File imageFile) async {
    try {
      final response = await remoteDataSource.uploadProfileImage(scholarId, imageFile);
      return response;
    } catch (e) {
      throw Exception("Failed to upload profile image: $e");
    }
  }

  // Delete profile image
  Future<Map<String, dynamic>> deleteProfileImage(String scholarId) async {
    try {
      final response = await remoteDataSource.deleteProfileImage(scholarId);
      return response;
    } catch (e) {
      throw Exception("Failed to delete profile image: $e");
    }
  }
}