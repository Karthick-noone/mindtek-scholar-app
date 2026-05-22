// lib/features/scholar/data/repositories/payment_repository.dart
import '../datasources/payment_remote_datasource.dart';

class PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepository(this.remoteDataSource);

  Future<Map<String, dynamic>> getPayments(String scholarId) async {
    try {
      final response = await remoteDataSource.getPayments(scholarId);
      return response;
    } catch (e) {
      throw Exception("Failed to get payments: $e");
    }
  }

  Future<Map<String, dynamic>> getPaymentDetails(String paymentId) async {
    try {
      final response = await remoteDataSource.getPaymentDetails(paymentId);
      return response;
    } catch (e) {
      throw Exception("Failed to get payment details: $e");
    }
  }
}