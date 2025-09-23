import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AppTheme {
  // Color constants
  static const Color primaryPink = Color(0xFFFFC0CB);
  static const Color lightPink = Color(0xFFFFEFF2);
  static const Color accentPink = Color(0xFFFFD6E8);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGrey = Color(0xFF333333);
  static const Color lightGrey = Color(0xFFF5F5F5);

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.pink,
      primaryColor: primaryPink,
      scaffoldBackgroundColor: white,
      fontFamily: 'Nunito',
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryPink,
        foregroundColor: darkGrey,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkGrey,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: darkGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: lightPink,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkGrey,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkGrey,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 16,
          color: darkGrey,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          color: darkGrey,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryPink,
        onPrimary: darkGrey,
        secondary: accentPink,
        onSecondary: darkGrey,
        surface: lightPink,
        onSurface: darkGrey,
      ),
    );
  }
}
