import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/login_request.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  String? _userName;
  String? _userEmail;
  String? _userId;
  String? _idForChangePassword;
  String? _scholarId;
  
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userId => _userId;
  String? get scholarId => _scholarId;
  String? get changePasswordId => _idForChangePassword;
  
  AuthProvider() {
    _checkAuthStatus();
  }
  
Future<bool> login(String userId, String password, {bool rememberMe = false}) async {
  _setLoading(true);
  _clearError();
  
  try {
    final request = LoginRequest(user_id: userId, pwd: password);
    final response = await _repository.login(request);
    
    if (response.success && response.token != null) {
      // Save token (always save - user stays logged in until they explicitly logout)
      await _secureStorage.write(key: 'access_token', value: response.token);
      
      // Save user info
      if (response.user != null) {
        final actualUserId = response.user!.id;

        await _secureStorage.write(key: 'user_id', value: response.user!.userId);
        await _secureStorage.write(key: 'user_code', value: response.user!.code);
        await _secureStorage.write(key: 'reg_id', value: response.user!.regId);
        await _secureStorage.write(key: 'user_name', value: userId);
        // Store the ACTUAL user ID for password change
        await _secureStorage.write(key: 'id', value: actualUserId.toString());
        // Also store as change_password_id for clarity
        await _secureStorage.write(key: 'change_password_id', value: actualUserId.toString());
      }
      
      // Remember me flag is still saved if user wants extra features (like auto-fill)
      await _secureStorage.write(key: 'remember_me', value: rememberMe.toString());
      
      _userId = response.user?.userId;
      _userName = userId;
      _isAuthenticated = true;
      _idForChangePassword = response.user?.id.toString();

      _setLoading(false);
      return true;
    } else {
      // Display the exact message from response
      _setError(response.message);
      _setLoading(false);
      return false;
    }
  } catch (e) {
    // Display the exact error message
    _setError(e.toString());
    _setLoading(false);
    return false;
  }
}
  
  // Check authentication status on app startup
  Future<void> _checkAuthStatus() async {
    final token = await _secureStorage.read(key: 'access_token');
    
    // If a valid token exists, restore the session
    if (token != null && token.isNotEmpty) {
      _isAuthenticated = true;
      await _loadUserData();
    } else {
      _isAuthenticated = false;
    }
    
    notifyListeners();
  }

  Future<void> logout() async {
  try {
    // Call API logout endpoint
    await _repository.logout();
    print('Logout API call successful');
  } catch (e) {
    print('Logout API error: $e');
    // Even if API call fails, we still want to clear local data
  } finally {
    // Always clear local storage regardless of API success
    await _secureStorage.deleteAll();
    _isAuthenticated = false;
    _userName = null;
    _userEmail = null;
    _userId = null;
    _scholarId = null;
    notifyListeners();
    print('Local storage cleared, user logged out');
  }
}


  Future<void> _loadUserData() async {
    _userId = await _secureStorage.read(key: 'user_id');
    _userName = await _secureStorage.read(key: 'user_name');
    _userEmail = await _secureStorage.read(key: 'user_email');
    _scholarId = await _secureStorage.read(key: 'scholar_id');
    _idForChangePassword = await _secureStorage.read(key: 'change_password_id');
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
  }
}