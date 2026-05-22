import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mindtek_scholar_app/core/theme/app_colors.dart';
import 'package:mindtek_scholar_app/providers/change_password_provider.dart';
import 'package:mindtek_scholar_app/features/auth/presentation/providers/auth_provider.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  
  // Password strength
  double _passwordStrength = 0.0;
  String _strengthText = "";
  Color _strengthColor = Colors.grey;
  
  // Validation flags
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    newPasswordController.addListener(() {
      _checkPasswordStrength(newPasswordController.text);
    });
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }
  
  void _checkPasswordStrength(String password) {
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      
      int strengthCount = 0;
      if (_hasMinLength) strengthCount++;
      if (_hasUppercase) strengthCount++;
      if (_hasLowercase) strengthCount++;
      if (_hasNumber) strengthCount++;
      if (_hasSpecialChar) strengthCount++;
      
      _passwordStrength = strengthCount / 5;
      
      if (_passwordStrength <= 0.4) {
        _strengthText = "WEAK";
        _strengthColor = const Color(0xFFEF4444);
      } else if (_passwordStrength <= 0.7) {
        _strengthText = "MEDIUM";
        _strengthColor = const Color(0xFFF59E0B);
      } else {
        _strengthText = "STRONG";
        _strengthColor = const Color(0xFF10B981);
      }
    });
  }
  
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    final changePasswordProvider = Provider.of<ChangePasswordProvider>(
      context,
      listen: false,
    );
    
    final success = await changePasswordProvider.changePassword(
      oldPassword: currentPasswordController.text.trim(),
      newPassword: newPasswordController.text.trim(),
      confirmPassword: confirmPasswordController.text.trim(),
    );
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Password changed successfully! Logging out..."),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.logout();
        if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(changePasswordProvider.error ?? "Failed to change password"),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
  
  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
 @override
Widget build(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final changePasswordProvider = Provider.of<ChangePasswordProvider>(context);
  
  return Scaffold(
    backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
    body: Column(
      children: [
        // Fixed Header - No SafeArea here, let it extend to top
        _buildPremiumHeader(isDarkMode),
        
        // Scrollable Form Content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildMainForm(isDarkMode, changePasswordProvider),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildPremiumHeader(bool isDarkMode) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
     gradient: LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: isDarkMode
      ? [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460)]
      : [const Color(0xFF1116F4), const Color(0xFF3B82F6)],
),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(35),
        bottomRight: Radius.circular(35),
      ),
    ),
    child: Stack(
      children: [
        // Decorative Circles
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        Positioned(
          top: 60,
          right: 40,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.04),
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: -20,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        
        // Main Content with SafeArea only for status bar padding
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            right: 20,
            bottom: 24,
          ),
          child: Column(
            children: [
              // Top Row with Back Button and Title
              Row(
                children: [
                  Container(
                    // decoration: BoxDecoration(
                    //   color: Colors.white.withOpacity(0.2),
                    //   borderRadius: BorderRadius.circular(12),
                    // ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Change Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  // Icon on the right
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Subtitle text
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Update Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keep your account secure',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
  
  Widget _buildMainForm(bool isDarkMode, ChangePasswordProvider changePasswordProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
    // Current Password
_buildNeomorphicField(
  controller: currentPasswordController,
  label: 'Current Password',
  hint: 'Enter your current password',
  icon: Icons.lock_outline_rounded,
  isDarkMode: isDarkMode,
  obscure: _obscureCurrent,
  onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
  validator: (value) {
    if (_submitted || (value != null && value.isNotEmpty)) {
      if (value == null || value.isEmpty) return 'Current password is required';
    }
    return null;
  },
  errorText: _currentPasswordError,
  onErrorChanged: (error) => setState(() => _currentPasswordError = error),
),

const SizedBox(height: 20),

// New Password
_buildNeomorphicField(
  controller: newPasswordController,
  label: 'New Password',
  hint: 'Enter your new password',
  icon: Icons.password_rounded,
  isDarkMode: isDarkMode,
  obscure: _obscureNew,
  onToggle: () => setState(() => _obscureNew = !_obscureNew),
  validator: (value) {
    if (_submitted || (value != null && value.isNotEmpty)) {
      if (value == null || value.isEmpty) return 'New password is required';
      if (value.length < 8) return 'Password must be at least 8 characters';
    }
    return null;
  },
  errorText: _newPasswordError,
  onErrorChanged: (error) => setState(() => _newPasswordError = error),
),

// Password Strength Meter
if (newPasswordController.text.isNotEmpty) ...[
  const SizedBox(height: 16),
  _buildStrengthMeter(isDarkMode),
],

const SizedBox(height: 20),

// Confirm Password
_buildNeomorphicField(
  controller: confirmPasswordController,
  label: 'Confirm Password',
  hint: 'Confirm your new password',
  icon: Icons.verified_rounded,
  isDarkMode: isDarkMode,
  obscure: _obscureConfirm,
  onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
  validator: (value) {
    if (_submitted || (value != null && value.isNotEmpty)) {
      if (value == null || value.isEmpty) return 'Please confirm your password';
      if (value != newPasswordController.text) return 'Passwords do not match';
    }
    return null;
  },
  errorText: _confirmPasswordError,
  onErrorChanged: (error) => setState(() => _confirmPasswordError = error),
),

const SizedBox(height: 30),

SizedBox(
  width: double.infinity,
  height: 54,
  child: DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: isDarkMode
            ? [
                const Color(0xFF4A6CB0),  // Darker blue
                const Color(0xFF2A3B7C),  // Navy
              ]
            : [
                const Color(0xFF1116F4),  // Bright blue
                const Color(0xFF3B82F6),  // Lighter blue
              ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: (isDarkMode 
              ? const Color(0xFF4A6CB0)
              : const Color(0xFF1116F4)).withOpacity(isDarkMode ? 0.25 : 0.35),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      onPressed: () {
        setState(() {
          _submitted = true;

          _currentPasswordError =
              currentPasswordController.text.isEmpty
                  ? 'Current password is required'
                  : null;

          _newPasswordError =
              newPasswordController.text.isEmpty
                  ? 'New password is required'
                  : (newPasswordController.text.length < 8
                      ? 'Password must be at least 8 characters'
                      : null);

          _confirmPasswordError =
              confirmPasswordController.text.isEmpty
                  ? 'Please confirm your password'
                  : (confirmPasswordController.text !=
                          newPasswordController.text
                      ? 'Passwords do not match'
                      : null);
        });

        if (_currentPasswordError == null &&
            _newPasswordError == null &&
            _confirmPasswordError == null) {
          _changePassword();
        }
      },
      child: changePasswordProvider.isLoading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : const Text(
              'Update Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    ),
  ),
),
            const SizedBox(height: 30),

            // const SizedBox(height: 16),
            
            // Security Tip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 18, color: Color(0xFF6366F1)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Use a strong password that you don\'t use for other accounts',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDarkMode ? Colors.white70 : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
// Error message state variables
String? _currentPasswordError;
String? _newPasswordError;
String? _confirmPasswordError;
bool _submitted = false;
Widget _buildNeomorphicField({
  required TextEditingController controller,
  required String label,
  required String hint,
  required IconData icon,
  required bool isDarkMode,
  required bool obscure,
  required VoidCallback onToggle,
  required String? Function(String?) validator,
  required String? errorText,
  required Function(String?) onErrorChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Label
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.white70 : const Color(0xFF1E293B),
        ),
      ),
      const SizedBox(height: 8),
      
      // Text Field Container
      Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(4, 4),
            ),
            BoxShadow(
              color: isDarkMode ? Colors.grey[800]!.withOpacity(0.2) : Colors.white,
              blurRadius: 8,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(color: isDarkMode ? Colors.white : const Color(0xFF1E293B), fontSize: 15),
          onChanged: (value) {
            final error = validator(value);
            onErrorChanged(error);
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.white38 : const Color(0xFF94A3B8),
              fontSize: 13,
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF6366F1), size: 20),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18),
              color: isDarkMode ? Colors.white60 : const Color(0xFF64748B),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            errorText: null,
            errorStyle: const TextStyle(height: 0),
          ),
        ),
      ),
      
      // Error Message Below Field
      if (errorText != null && errorText.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 4),
          child: Row(
            children: [
              const Icon(Icons.error_outline_rounded, size: 12, color: Color(0xFFEF4444)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  errorText,
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}
  
  Widget _buildStrengthMeter(bool isDarkMode) {
    final strengthPercent = (_passwordStrength * 100).toInt();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _strengthColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Password Strength',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _strengthColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _strengthText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _strengthColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _passwordStrength,
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              color: _strengthColor,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$strengthPercent% Secure',
            style: TextStyle(
              fontSize: 10,
              color: isDarkMode ? Colors.white60 : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildRequirementChip('8+ characters', _hasMinLength),
              _buildRequirementChip('Uppercase', _hasUppercase),
              _buildRequirementChip('Lowercase', _hasLowercase),
              _buildRequirementChip('Number', _hasNumber),
              _buildRequirementChip('Special char', _hasSpecialChar),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildRequirementChip(String text, bool isValid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isValid ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFEF4444).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isValid ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 10,
            color: isValid ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isValid ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }
}