import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFE91E63); // Vibrant Pink/Magenta
  static const Color accentColor = Color(0xFFD946EF); // Fuchsia gradient stop
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color dangerColor = Color(0xFFEF4444);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF111827); // Darker pro text
  static const Color mutedTextColor = Color(0xFF6B7280);
  
  // Pastel backgrounds for cards from EasyHR screenshot inspiration
  static const Color pastelPurple = Color(0xFFF3E8FF);
  static const Color pastelPink = Color(0xFFFCE7F3);
  static const Color pastelGreen = Color(0xFFDCFCE7);
  static const Color pastelBlue = Color(0xFFDBEAFE);
  static const Color pastelOrange = Color(0xFFFFEDD5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Gilroy', // Clean modern font
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: backgroundColor,
        error: dangerColor,
        onPrimary: Colors.white,
        onSurface: textColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Highly rounded like EasyHR
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textColor, letterSpacing: -0.2),
        bodyMedium: TextStyle(color: textColor, letterSpacing: -0.2),
        titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        headlineSmall: TextStyle(color: textColor, fontWeight: FontWeight.w800, letterSpacing: -0.8),
        headlineMedium: TextStyle(color: textColor, fontWeight: FontWeight.w800, letterSpacing: -1.0),
        displaySmall: TextStyle(color: textColor, fontWeight: FontWeight.w900, letterSpacing: -1.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded pill-ish buttons
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: -0.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          fontFamily: 'Gilroy',
        ),
      ),
    );
  }
}
