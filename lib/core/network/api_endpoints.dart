class ApiEndpoints {
  static const String baseUrl =
      'http://scholarapi.seasense.in/api'; // Change this to your actual API URL

  // Auth endpoints
  static const String login =
      '/scholar/login'; // Changed from /auth/login to /scholar/login
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/logout';

  // Scholar endpoints
  static const String scholarDetails = '/sclr/scholar';
  static const String dashboard = '/scholar/dashboard';
  static const String profile = '/scholar/profile';
  static const String updateProfile = '/scholar/profile/update';
  static const String changePassword = '/change-password';
  static const String paymentHistory = '/sclr/payments';
  static const String complaints = '/scholar/complaints';
  static const String receipts = '/scholar/receipts';
  static const String ratings = '/scholar/ratings';
  static const String uploadProfileImage =
      '/scholar/profile'; // POST to this endpoint
  static const String deleteProfileImage =
      '/scholar/profile'; // DELETE to this endpoint
  static const String paymentDetails = '/sclr/payments'; // Add this
  static const String downloadReceipt = '/scholar/receipt/download'; // Add this
  static const String paymentSummary = '/scholar/payment-summary'; // Add this

  static const String sendOtp = '/forgot/send-otp';
  static const String verifyOtp = '/forgot/verify-otp';
  static const String resetPassword = '/forgot/reset-password';

  static const String workStatus = '/workdetails/last-status'; // Add this
  // In api_endpoints.dart
  static const String userDetails = '/user/details'; // Add this
  static const String payments =
      '/sclr/payments'; // This will be used as /sclr/payments/{id}
}
