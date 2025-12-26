import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // New Color Palette
  static const Color primaryColor = Color(0xFF66FCF1); // Bright Cyan/Aqua
  static const Color accentColor = Color(0xFF45A29E); // Darker Teal/Cyan (for secondary actions)
  static const Color backgroundColor = Color(0xFF1F2833); // Very Dark Blue-Grey
  static const Color cardColor = Color(0xFF2C3540); // Slightly Lighter Dark Blue-Grey for cards
  static const Color cardColorLight = Color(0xFF3A4452); // Even Lighter for secondary cards/inputs
  static const Color textColor = Colors.white;
  static const Color textColorSecondary = Color(0xFFAAAAAA); // Light Grey
  static const Color errorColor = Colors.redAccent;

  // New static InputDecorationTheme
  static final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    hintStyle: GoogleFonts.lato(color: textColorSecondary),
    filled: true,
    fillColor: cardColorLight,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12), // Slightly less rounded for modern look
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.montserrat(fontSize: 24, color: textColor, fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.montserrat(fontSize: 20, color: textColor, fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.montserrat(fontSize: 18, color: textColor, fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.montserrat(fontSize: 16, color: textColorSecondary),
      bodyLarge: GoogleFonts.lato(fontSize: 16, color: textColor),
      bodyMedium: GoogleFonts.lato(fontSize: 14, color: textColorSecondary),
      bodySmall: GoogleFonts.lato(fontSize: 12, color: textColorSecondary),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor, // Use new background color
      foregroundColor: primaryColor,
      elevation: 0,
      titleTextStyle: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold), // Adjusted title style
    ),
    dialogTheme: DialogThemeData( // Changed DialogTheme to DialogThemeData
      backgroundColor: cardColor,
      titleTextStyle: GoogleFonts.montserrat(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
      contentTextStyle: GoogleFonts.lato(color: textColorSecondary, fontSize: 14),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: primaryColor),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: backgroundColor,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: primaryColor),
    inputDecorationTheme: inputDecorationTheme, // Use the static inputDecorationTheme
    iconTheme: const IconThemeData(color: primaryColor),
    // Add color scheme to ensure all material components use the new palette
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: cardColor,
      background: backgroundColor,
      error: errorColor,
      onPrimary: backgroundColor, // Text on primary color
      onSecondary: textColor,
      onSurface: textColor,
      onBackground: textColor,
      onError: Colors.white,
      brightness: Brightness.dark,
    ),
    // Add navigation bar theme for consistency
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: MaterialStateProperty.all(
        GoogleFonts.lato(fontSize: 10, fontWeight: FontWeight.w500, color: textColorSecondary),
      ),
      backgroundColor: backgroundColor,
      indicatorColor: primaryColor.withOpacity(0.2),
    )
  );
}