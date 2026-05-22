class SendOtpRequest {
  final String userId;
  final String email;
  final String comUrlCode;

  SendOtpRequest({
    required this.userId,
    required this.email,
    required this.comUrlCode,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'email': email,
    'com_url_code': comUrlCode,
  };
}

class VerifyOtpRequest {
  final String otp;
  final String userId;

  VerifyOtpRequest({
    required this.otp,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
    'otp': otp,
    'user_id': userId,
  };
}

class ResetPasswordRequest {
  final String userId;
  final String newPwd;
  final String confirmPwd;

  ResetPasswordRequest({
    required this.userId,
    required this.newPwd,
    required this.confirmPwd,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'new_pwd': newPwd,
    'confirm_pwd': confirmPwd,
  };
}

class ApiResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}