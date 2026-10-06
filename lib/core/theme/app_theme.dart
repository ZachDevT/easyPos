import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color successColor = Color(0xFF16A34A);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color dangerColor = Color(0xFFDC2626);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF0F172A);
  static const Color mutedTextColor = Color(0xFF64748B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Gilroy',
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        surface: backgroundColor,
        error: dangerColor,
        onPrimary: Colors.white,
        onSurface: textColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor),
        titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontFamily: 'Enzyme'),
        headlineSmall: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontFamily: 'Enzyme'),
        headlineMedium: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontFamily: 'Enzyme'),
        displaySmall: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontFamily: 'Enzyme'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cardColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
