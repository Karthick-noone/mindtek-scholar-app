import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors (keep consistent across themes)
  static const Color primary = Color(0xFF2A3B7C);
  static const Color secondary = Color(0xFF4A6CB0);
  
  // Gradient colors (keep consistent)
  static const Color gradientStart = Color(0xFF1116F4);
  static const Color gradientEnd = Color(0xFF3B82F6);

  // Static colors (same in both themes)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;
  
  // Transparent
  static const Color transparent = Color(0x00000000);

  // Theme dependent colors - use these with context
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFF5F7FA)
        : const Color(0xFF121212);
  }

  static Color card(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : const Color(0xFF1E1E1E);
  }

   static Color border(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.grey.shade300
        : Colors.grey.shade800;
  }

  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xFF1C1C1C)
        : Colors.white;
  }

  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xFF757575)
        : Colors.white70;
  }

  static Color title(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xFF1E293B)
        : Colors.white;
  }

  static Color iconColors(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xFF2A3B7C)
        : const Color(0xFF6B8CFF);
  }

  static Color white70(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xB3FFFFFF)
        : const Color(0xB3FFFFFF).withOpacity(0.7);
  }

  static Color cardShadow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.black.withOpacity(0.05)
        : Colors.black.withOpacity(0.3);
  }

  static Color divider(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.grey.shade200
        : Colors.grey.shade800;
  }
}