class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final User? user;
  final Map<String, dynamic>? scholar;

  LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
    this.scholar,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Check if it's a success response (status_code 200)
    final isSuccess = json['status_code'] == 200 || json['status'] == true;

    if (isSuccess && json['token'] == null) {
      throw Exception("Token missing in response");
    }

    return LoginResponse(
      success: isSuccess,
      message:
          json['message'] ?? (isSuccess ? 'Login successful' : 'Login failed'),
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      scholar: json['scholar'],
    );
  }
}

class User {
  final String id;
  final String code;
  final String userId;
  final String regId;

  User({
    required this.id,
    required this.code,
    required this.userId,
    required this.regId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      code: json['code'] ?? '',
      userId: json['user_id'] ?? '',
      regId: json['reg_id']?.toString() ?? '',
    );
  }
}
