import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mindtek_scholar_app/core/theme/app_colors.dart';
import 'package:mindtek_scholar_app/features/auth/presentation/providers/forgot_password_provider.dart';
import 'package:mindtek_scholar_app/features/auth/data/repositories/auth_repository.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  // Controllers
  final TextEditingController scholarIdController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(6, (index) => TextEditingController());
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Password visibility toggles
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    scholarIdController.dispose();
    emailController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: isError ? 3 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ForgotPasswordProvider(AuthRepository()),
      child: Consumer<ForgotPasswordProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Header with back button
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.98),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: _buildCurrentForm(provider),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentForm(ForgotPasswordProvider provider) {
    // Show error message if any
    if (provider.errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMessage(provider.errorMessage);
        provider.clearError();
      });
    }

    switch (provider.currentStep) {
      case 'otp':
        return _buildOTPForm(provider);
      case 'reset':
        return _buildResetPasswordForm(provider);
      default:
        return _buildCredentialsForm(provider);
    }
  }

  // Form 1: Scholar ID and Email
  Widget _buildCredentialsForm(ForgotPasswordProvider provider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3F51B5).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.lock_reset, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 20),
        const Text(
          "Forgot Password?",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3F51B5),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Enter your Scholar ID and Email to reset your password",
          style: TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        
        TextField(
          controller: scholarIdController,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: "Scholar ID",
            labelStyle: const TextStyle(color: Colors.black),
            prefixIcon: const Icon(Icons.badge, color: Color(0xFF3F51B5)),
            hintText: "Enter your scholar ID",
            hintStyle: const TextStyle(color: Colors.black54),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF3F51B5), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 15),
        
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: "Email Address",
            labelStyle: const TextStyle(color: Colors.black),
            prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF3F51B5)),
            hintText: "your@email.com",
            hintStyle: const TextStyle(color: Colors.black54),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF3F51B5), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 25),
        
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: provider.isLoading ? null : () async {
              if (scholarIdController.text.isEmpty) {
                _showMessage("Please enter your Scholar ID");
                return;
              }
              if (emailController.text.isEmpty || !_isValidEmail(emailController.text)) {
                _showMessage("Please enter a valid email address");
                return;
              }
              
              final success = await provider.sendOTP(
                scholarIdController.text,
                emailController.text,
              );
              
              if (success) {
                _showMessage("OTP sent successfully to your email!", isError: false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F51B5),
              disabledBackgroundColor: const Color(0xFF3F51B5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 8,
            ),
            child: provider.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Send OTP",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Remember your password? ",
              style: TextStyle(color: Colors.grey),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Login",
                style: TextStyle(
                  color: Color(0xFF3F51B5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

 // Form 2: OTP Verification with Timer and Separate Boxes
Widget _buildOTPForm(ForgotPasswordProvider provider) {
  // Initialize timer only once when form is shown
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!provider.isTimerRunning && !provider.isTimerExpired && provider.timerSeconds == 300) {
      provider.startTimer();
    }
  });

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.pin, size: 40, color: Colors.white),
      ),
      const SizedBox(height: 20),
      const Text(
        "Verify OTP",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4CAF50),
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        "Please enter the 6-digit OTP sent to your email",
        style: TextStyle(fontSize: 14, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 30),
      
      // Timer Display
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: provider.isTimerExpired 
              ? Colors.red.withOpacity(0.1) 
              : Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: provider.isTimerExpired ? Colors.red : Colors.orange,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              provider.isTimerExpired ? Icons.timer_off : Icons.timer,
              color: provider.isTimerExpired ? Colors.red : Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              provider.isTimerExpired 
                  ? "OTP Expired" 
                  : "OTP Valid for: ${provider.formattedTime}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: provider.isTimerExpired ? Colors.red : Colors.orange,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 30),
      
      // Separate OTP Boxes (6 digits) - Responsive design
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildOtpBox(index, provider),
            ),
          )),
        ),
      ),
      const SizedBox(height: 25),
      
      // Verify OTP Button - Only show when timer is NOT expired
      if (!provider.isTimerExpired)
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: provider.isLoading ? null : () async {
                final String otpValue = otpControllers.map((c) => c.text).join();
                if (otpValue.length != 6) {
                  _showMessage("Please enter complete 6-digit OTP");
                  return;
                }
                
                final success = await provider.verifyOTP(otpValue);
                if (success) {
                  _showMessage("OTP verified successfully!", isError: false);
                }
              },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              disabledBackgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 8,
            ),
            child: provider.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Verify OTP",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      
      const SizedBox(height: 15),
      
      // Resend OTP Button - Only show when timer is expired
      if (provider.isTimerExpired)
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: provider.isLoading ? null : () async {
              final success = await provider.resendOTP(
                scholarIdController.text, 
                emailController.text,
              );
              if (success) {
                _showMessage("New OTP sent successfully!", isError: false);
                // Clear all OTP boxes
                for (int i = 0; i < 6; i++) {
                  otpControllers[i].clear();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 8,
            ),
            child: provider.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Resend OTP",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      
      const SizedBox(height: 10),
      
      // Back Button
      // SizedBox(
      //   width: double.infinity,
      //   height: 45,
      //   child: OutlinedButton(
      //     onPressed: () {
      //       provider.stopTimer();
      //       provider.goBack();
      //       // Clear OTP boxes
      //       for (int i = 0; i < 6; i++) {
      //         otpControllers[i].clear();
      //       }
      //     },
      //     style: OutlinedButton.styleFrom(
      //       foregroundColor: Colors.grey,
      //       side: const BorderSide(color: Colors.grey),
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(15),
      //       ),
      //     ),
      //     child: const Text("Back", style: TextStyle(fontSize: 14)),
      //   ),
      // ),
    ],
  );
}

// Helper method to build OTP input boxes - Responsive version
Widget _buildOtpBox(int index, ForgotPasswordProvider provider) {
  // Calculate responsive width based on screen size
  final screenWidth = MediaQuery.of(context).size.width;
  final boxSize = (screenWidth - 120) / 6; // Subtract padding and margins
  
  return SizedBox(
    width: boxSize.clamp(40.0, 55.0), // Between 40-55 pixels
    height: 60,
    child: TextField(
      controller: otpControllers[index],
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 1,
      style: const TextStyle(
        fontSize: 20, 
        fontWeight: FontWeight.bold,
        color: Colors.black, // Force black text
      ),
      decoration: InputDecoration(
        counterText: "",
        filled: true,
        fillColor: Colors.white, // Force white background
        contentPadding: EdgeInsets.zero,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
      ),
      onChanged: (value) {
        if (value.isNotEmpty && index < 5) {
          FocusScope.of(context).nextFocus();
        } else if (value.isEmpty && index > 0) {
          FocusScope.of(context).previousFocus();
        }
      },
    ),
  );
}
// Form 3: New Password & Confirm Password - Accept all characters with visibility toggle
Widget _buildResetPasswordForm(ForgotPasswordProvider provider) {
  // Real-time password validation
  String password = newPasswordController.text;
  bool hasMinLength = password.length >= 6;
  bool hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
  bool hasLowercase = RegExp(r'[a-z]').hasMatch(password);
  bool hasNumber = RegExp(r'[0-9]').hasMatch(password);
  bool hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
  bool isPasswordValid = hasMinLength && hasUppercase && hasLowercase && hasNumber && hasSpecialChar;
  
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF9800).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.password, size: 40, color: Colors.white),
      ),
      const SizedBox(height: 20),
      const Text(
        "Reset Password",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF9800),
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        "Enter your new password (minimum 6 characters)",
        style: TextStyle(fontSize: 14, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 30),
      
      // New Password Field with Eye Icon
      TextField(
        controller: newPasswordController,
        obscureText: !_isNewPasswordVisible,
        keyboardType: TextInputType.text,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        onChanged: (_) => setState(() {}), // Trigger rebuild for validation
        decoration: InputDecoration(
          labelText: "New Password",
          labelStyle: const TextStyle(color: Colors.black),
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFF9800)),
          hintText: "Enter new password (min 6 characters)",
          hintStyle: const TextStyle(color: Colors.black54),
          helperText: "Use letters, numbers, and symbols",
          helperStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          suffixIcon: IconButton(
            icon: Icon(
              _isNewPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isNewPasswordVisible = !_isNewPasswordVisible;
              });
            },
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
          ),
        ),
      ),
      const SizedBox(height: 15),
      
      // Confirm Password Field with Eye Icon
      TextField(
        controller: confirmPasswordController,
        obscureText: !_isConfirmPasswordVisible,
        keyboardType: TextInputType.text,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        onChanged: (_) => setState(() {}), // Trigger rebuild for validation
        decoration: InputDecoration(
          labelText: "Confirm Password",
          labelStyle: const TextStyle(color: Colors.black),
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFF9800)),
          hintText: "Confirm your new password",
          hintStyle: const TextStyle(color: Colors.black54),
          helperText: "Re-enter your password",
          helperStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
          ),
        ),
      ),
      const SizedBox(height: 15),
      
      // Password requirements with checkboxes
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Password Requirements:",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            // Minimum 6 characters
            Row(
              children: [
                Icon(
                  hasMinLength ? Icons.check_circle : Icons.circle_outlined,
                  size: 16,
                  color: hasMinLength ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  "Minimum 6 characters",
                  style: TextStyle(
                    fontSize: 12,
                    color: hasMinLength ? Colors.green : Colors.grey,
                    fontWeight: hasMinLength ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // At least one uppercase letter
            Row(
              children: [
                Icon(
                  hasUppercase ? Icons.check_circle : Icons.circle_outlined,
                  size: 16,
                  color: hasUppercase ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  "At least one uppercase letter (A-Z)",
                  style: TextStyle(
                    fontSize: 12,
                    color: hasUppercase ? Colors.green : Colors.grey,
                    fontWeight: hasUppercase ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // At least one lowercase letter
            Row(
              children: [
                Icon(
                  hasLowercase ? Icons.check_circle : Icons.circle_outlined,
                  size: 16,
                  color: hasLowercase ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  "At least one lowercase letter (a-z)",
                  style: TextStyle(
                    fontSize: 12,
                    color: hasLowercase ? Colors.green : Colors.grey,
                    fontWeight: hasLowercase ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // At least one number
            Row(
              children: [
                Icon(
                  hasNumber ? Icons.check_circle : Icons.circle_outlined,
                  size: 16,
                  color: hasNumber ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  "At least one number (0-9)",
                  style: TextStyle(
                    fontSize: 12,
                    color: hasNumber ? Colors.green : Colors.grey,
                    fontWeight: hasNumber ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // At least one special character
            Row(
              children: [
                Icon(
                  hasSpecialChar ? Icons.check_circle : Icons.circle_outlined,
                  size: 16,
                  color: hasSpecialChar ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  "At least one special character (!@#\$%^&*)",
                  style: TextStyle(
                    fontSize: 12,
                    color: hasSpecialChar ? Colors.green : Colors.grey,
                    fontWeight: hasSpecialChar ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      
      // Show password match status
      if (confirmPasswordController.text.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(
                newPasswordController.text == confirmPasswordController.text
                    ? Icons.check_circle
                    : Icons.error_outline,
                size: 14,
                color: newPasswordController.text == confirmPasswordController.text
                    ? Colors.green
                    : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                newPasswordController.text == confirmPasswordController.text
                    ? "Passwords match"
                    : "Passwords do not match",
                style: TextStyle(
                  fontSize: 12,
                  color: newPasswordController.text == confirmPasswordController.text
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ),
        ),
      
      const SizedBox(height: 25),
      
      // Reset Password Button
      SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: provider.isLoading ? null : () async {
            // Validation
            if (newPasswordController.text.isEmpty) {
              _showMessage("Please enter a new password");
              return;
            }
            if (!hasMinLength) {
              _showMessage("Password must be at least 6 characters");
              return;
            }
            if (!hasUppercase) {
              _showMessage("Password must contain at least one uppercase letter");
              return;
            }
            if (!hasLowercase) {
              _showMessage("Password must contain at least one lowercase letter");
              return;
            }
            if (!hasNumber) {
              _showMessage("Password must contain at least one number");
              return;
            }
            if (!hasSpecialChar) {
              _showMessage("Password must contain at least one special character");
              return;
            }
            if (newPasswordController.text != confirmPasswordController.text) {
              _showMessage("Passwords do not match");
              return;
            }
            
            final success = await provider.resetPassword(
              newPasswordController.text,
              confirmPasswordController.text,
            );
            
            if (success) {
              _showMessage("Password reset successfully!", isError: false);
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.popUntil(context, (route) => route.isFirst);
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9800),
            disabledBackgroundColor: const Color(0xFFFF9800),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 8,
          ),
          child: provider.isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  "Reset Password",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
      const SizedBox(height: 15),
      
      // Back Button
      // SizedBox(
      //   width: double.infinity,
      //   height: 45,
      //   child: OutlinedButton(
      //     onPressed: () => provider.goBack(),
      //     style: OutlinedButton.styleFrom(
      //       foregroundColor: Colors.grey,
      //       side: const BorderSide(color: Colors.grey),
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(15),
      //       ),
      //     ),
      //     child: const Text("Back", style: TextStyle(fontSize: 14)),
      //   ),
      // ),
    ],
  );
}
}