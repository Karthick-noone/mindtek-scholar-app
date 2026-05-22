// reset_password_page.dart
import 'package:flutter/material.dart';
import 'package:mindtek_scholar_app/core/theme/app_colors.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String token;

  const ResetPasswordPage({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> with SingleTickerProviderStateMixin {
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  bool obscureNew = true;
  bool obscureConfirm = true;
  bool isLoading = false;
  bool isPasswordValid = false;
  bool isPasswordMatch = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    newPassController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  // 🔑 RESET PASSWORD
  void resetPassword() async {
    if (newPassController.text.isEmpty || confirmPassController.text.isEmpty) {
      _showMessage("Please fill all fields");
      return;
    }

    if (newPassController.text != confirmPassController.text) {
      _showMessage("Passwords do not match");
      return;
    }

    if (newPassController.text.length < 8) {
      _showMessage("Password must be at least 8 characters");
      return;
    }

    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 2)); // simulate API

    setState(() => isLoading = false);

    _showSuccessDialog();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Password Reset Successful!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Your password has been reset successfully. You can now login with your new password.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.popUntil(context, (route) => route.isFirst); // Go to login
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F51B5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Go to Login"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _validatePassword(String value) {
    setState(() {
      isPasswordValid = value.length >= 8 &&
          RegExp(r'[A-Z]').hasMatch(value) &&
          RegExp(r'[0-9]').hasMatch(value) &&
          RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
      
      isPasswordMatch = newPassController.text == confirmPassController.text &&
          confirmPassController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(28),
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Lock Icon with Gradient
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.green, Colors.teal],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.lock_reset_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Title
                            const Text(
                              "Create New Password",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3F51B5),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Email Info
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3F51B5).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.email,
                                style: const TextStyle(
                                  color: Color(0xFF3F51B5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // New Password
                            TextField(
                              controller: newPassController,
                              obscureText: obscureNew,
                              onChanged: _validatePassword,
                              decoration: InputDecoration(
                                labelText: "New Password",
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF3F51B5)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureNew ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscureNew = !obscureNew;
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
                                  borderSide: const BorderSide(color: Color(0xFF3F51B5), width: 2),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Confirm Password
                            TextField(
                              controller: confirmPassController,
                              obscureText: obscureConfirm,
                              onChanged: _validatePassword,
                              decoration: InputDecoration(
                                labelText: "Confirm Password",
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF3F51B5)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureConfirm ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscureConfirm = !obscureConfirm;
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
                                  borderSide: const BorderSide(color: Color(0xFF3F51B5), width: 2),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Password Requirements
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3F51B5).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  _buildRequirement(
                                    "At least 8 characters", 
                                    newPassController.text.length >= 8
                                  ),
                                  _buildRequirement(
                                    "Contains uppercase letter", 
                                    RegExp(r'[A-Z]').hasMatch(newPassController.text)
                                  ),
                                  _buildRequirement(
                                    "Contains number", 
                                    RegExp(r'[0-9]').hasMatch(newPassController.text)
                                  ),
                                  _buildRequirement(
                                    "Contains special character", 
                                    RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(newPassController.text)
                                  ),
                                  _buildRequirement(
                                    "Passwords match", 
                                    newPassController.text == confirmPassController.text && 
                                    confirmPassController.text.isNotEmpty
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 25),

                            // Reset Button
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: (isPasswordValid && isPasswordMatch && !isLoading) 
                                    ? resetPassword 
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3F51B5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 8,
                                ),
                                child: isLoading
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

                            const SizedBox(height: 20),

                            // Link Expiry Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 14,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "This link will expire in 1 hour",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: isMet ? Colors.green : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green : Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}