// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF66003E);
  static const onPrimary = Colors.white;

  static const gotIt = Color(0xFF7CB88F);   // soft sage green
  static const again = Color(0xFFE0A458);   // soft amber
  static const mastery = Color(0xFF9E9E9E); // neutral gray

  static const tierLocked = Color(0xFFBDBDBD);
  static const tierLearning = Color(0xFFE57373);
  static const tierBronze = Color(0xFFCD7F32);
  static const tierSilver = Color(0xFFB0BEC5);
  static const tierGold = Color(0xFFFFD54F);
  static const tierPlatinum = Color(0xFF80DEEA);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary, // controls title + icon color
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
        ),
      ),
    );
  }
}