import '../datasources/complaint_remote_datasource.dart';

class ComplaintRepository {
  final ComplaintRemoteDataSource remoteDataSource;

  ComplaintRepository(this.remoteDataSource);

  Future<Map<String, dynamic>> getComplaints({
    required int scholarId,
    required int page,
    required int perPage,
    required String status,
    required String search,
  }) async {
    try {
      final response = await remoteDataSource.getComplaints(
        scholarId: scholarId,
        page: page,
        perPage: perPage,
        status: status,
        search: search,
      );
      return response;
    } catch (e) {
      throw Exception("Failed to get complaints: $e");
    }
  }

  Future<Map<String, dynamic>> storeComplaint(Map<String, dynamic> data) async {
    try {
      final response = await remoteDataSource.storeComplaint(data);
      return response;
    } catch (e) {
      throw Exception("Failed to store complaint: $e");
    }
  }

  Future<Map<String, dynamic>> getComplaintCounts(int scholarId) async {
    try {
      final response = await remoteDataSource.getComplaintCounts(scholarId);
      return response;
    } catch (e) {
      throw Exception("Failed to get complaint counts: $e");
    }
  }

  Future<Map<String, dynamic>> updateRating(int complaintId, int rating) async {
    try {
      final response = await remoteDataSource.updateRating(complaintId, {
        'ratings': rating,
      });
      return response;
    } catch (e) {
      throw Exception("Failed to update rating: $e");
    }
  }

  Future<Map<String, dynamic>> deleteComplaint(int complaintId) async {
    try {
      final response = await remoteDataSource.deleteComplaint(complaintId);
      return response;
    } catch (e) {
      throw Exception("Failed to delete complaint: $e");
    }
  }
}