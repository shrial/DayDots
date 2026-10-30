import 'package:flutter/material.dart';

class AppColors {
  static const primary    = Color(0xFF6C63FF);
  static const urgent     = Color(0xFFFF6B6B);
  static const recurring  = Color(0xFF48CFAD);
  static const normal     = Color(0xFF4FC3F7);
  static const background = Color(0xFFF8F9FF);
  static const cardBg     = Colors.white;
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: AppColors.background,
    useMaterial3: true,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      bodyLarge:      TextStyle(fontSize: 18),
      bodyMedium:     TextStyle(fontSize: 16),
    ),
  );
}