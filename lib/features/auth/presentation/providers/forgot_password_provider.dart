import 'package:flutter/material.dart';
import 'package:mindtek_scholar_app/features/auth/data/repositories/auth_repository.dart';
import 'dart:async';

class ForgotPasswordProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  ForgotPasswordProvider(this._authRepository);
  
  // State variables
  bool _isLoading = false;
  String _currentStep = 'credentials'; // credentials, otp, reset
  String _userId = '';
  String _errorMessage = '';
  
  // Timer related variables
  int _timerSeconds = 300; // 5 minutes = 300 seconds
  Timer? _timer;
  bool _isTimerExpired = false;
  
  // Getters
  bool get isLoading => _isLoading;
  String get currentStep => _currentStep;
  String get userId => _userId;
  String get errorMessage => _errorMessage;
  int get timerSeconds => _timerSeconds;
  bool get isTimerRunning => _timer != null;
  bool get isTimerExpired => _isTimerExpired;
  String get formattedTime {
    int minutes = _timerSeconds ~/ 60;
    int seconds = _timerSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  // Send OTP
  Future<bool> sendOTP(String scholarId, String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authRepository.sendOtp(
        scholarId: scholarId,
        email: email,
        comUrlCode: "http://mindtekscholar.seasense.in/",
      );
      
      print('SEND OTP RESPONSE: $response');
      
      if (response['success'] == true) {
        _userId = response['user_id'] ?? scholarId;
        _currentStep = 'otp';
        _setLoading(false);
        startTimer(); // Start timer when OTP is sent
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Failed to send OTP';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      _setLoading(false);
      return false;
    }
  }
  
  // Resend OTP
  Future<bool> resendOTP(String scholarId, String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authRepository.sendOtp(
        scholarId: scholarId,
        email: email,
        comUrlCode: "http://mindtekscholar.seasense.in/",
      );
      
      if (response['success'] == true) {
        _userId = response['user_id'] ?? scholarId;
        resetTimer(); // Reset timer on resend
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Failed to resend OTP';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      _setLoading(false);
      return false;
    }
  }
  
  // Start Timer
  void startTimer() {
    stopTimer(); // Stop any existing timer
    _timerSeconds = 300; // Reset to 5 minutes
    _isTimerExpired = false;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        _timerSeconds--;
        notifyListeners();
      } else {
        _isTimerExpired = true;
        stopTimer();
        notifyListeners();
      }
    });
    notifyListeners();
  }
  
  // Reset Timer
  void resetTimer() {
    stopTimer();
    startTimer();
  }
  
  // Stop Timer
  void stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }
  
  // Verify OTP
  Future<bool> verifyOTP(String otp) async {
    if (_isTimerExpired) {
      _errorMessage = 'OTP has expired. Please request a new OTP.';
      notifyListeners();
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authRepository.verifyOtp(
        otp: otp,
        userId: _userId,
      );
      
      print('VERIFY OTP RESPONSE IN PROVIDER: $response');
      
      if (response['success'] == true) {
        _currentStep = 'reset';
        stopTimer(); // Stop timer on successful verification
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Invalid OTP. Please try again.';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      _setLoading(false);
      return false;
    }
  }
  
  // Reset Password
  Future<bool> resetPassword(String newPassword, String confirmPassword) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _authRepository.resetPassword(
        userId: _userId,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      
      print('RESET PASSWORD RESPONSE: $response');
      
      if (response['success'] == true) {
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Failed to reset password';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      _setLoading(false);
      return false;
    }
  }
  
  // Reset flow (go back to start)
  void resetFlow() {
    stopTimer();
    _currentStep = 'credentials';
    _userId = '';
    _errorMessage = '';
    _timerSeconds = 300;
    _isTimerExpired = false;
    notifyListeners();
  }
  
  // Go back to previous step
  void goBack() {
    if (_currentStep == 'otp') {
      stopTimer();
      _currentStep = 'credentials';
    } else if (_currentStep == 'reset') {
      _currentStep = 'otp';
      startTimer(); // Restart timer when going back to OTP
    }
    _errorMessage = '';
    notifyListeners();
  }
  
  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }
  
  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }
}