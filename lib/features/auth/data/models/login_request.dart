class LoginRequest {
  final String user_id;
  final String pwd;
  
  LoginRequest({
    required this.user_id,
    required this.pwd,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'pwd': pwd,
      'com_url_code': "http://mindtekscholar.seasense.in/"
    };
  }
}