import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: Colors.white,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF1C1C1C),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF1C1C1C)),
      bodyMedium: TextStyle(color: Color(0xFF757575)),
      titleLarge: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
    ),
    iconTheme: const IconThemeData(color: AppColors.primary),
    dividerColor: Colors.grey.shade200,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: Color(0xFF1E1E1E),
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF6B8CFF)),
    dividerColor: Color(0xFF2A2A2A),
  );
}