import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ===== LUXORA COLOR PALETTE =====
  static const Color primaryColor = Color(0xFFD6C7B2); // Beige utama
  static const Color secondaryColor = Color(0xFFBFAF9B); // Beige lebih gelap
  static const Color accentColor = Color(0xFF8C7A64); // Accent coklat
  static const Color backgroundColor = Color(0xFFF6EFE6); // Cream background
  static const Color cardColor = Color(0xFFFFFFFF); // Putih card
  static const Color textPrimary = Color(0xFF1C1C1C); // Hitam lembut
  static const Color textSecondary = Color(0xFF7A7A7A); // Abu hangat
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFF9A825);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: cardColor,
      error: errorColor,
    ),

    scaffoldBackgroundColor: backgroundColor,

    // ===== TEXT THEME =====
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: textSecondary,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    // ===== APP BAR =====
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: backgroundColor,
      foregroundColor: textPrimary,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    ),

    // ===== INPUT FIELD =====
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1E8DC),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black),
      ),
      hintStyle: TextStyle(color: textSecondary),
    ),

    // ===== BUTTON =====
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ===== ICON =====
    iconTheme: const IconThemeData(
      color: textPrimary,
      size: 22,
    ),
  );
}

// ===== GRADIENT (HEADER / HERO) =====
class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFFE7DCCB),
      Color(0xFFD6C7B2),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
