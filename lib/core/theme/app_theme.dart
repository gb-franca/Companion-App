import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Palette
  static const Color lightPrimary = Color(0xFF6750A4);
  static const Color lightSecondary = Color(0xFFD29200);
  static const Color lightBackground = Color(0xFFF7F5FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightError = Color(0xFFB3261E);

  // Dark Palette (RPG Mystic Violet)
  static const Color darkPrimary = Color(0xFFB08CFF);
  static const Color darkSecondary = Color(0xFFFFC107);
  static const Color darkBackground = Color(0xFF0F0B18);
  static const Color darkSurface = Color(0xFF1A1428);
  static const Color darkSurfaceVariant = Color(0xFF251E38);
  static const Color darkError = Color(0xFFF2B8B5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lightPrimary,
        brightness: Brightness.light,
        primary: lightPrimary,
        secondary: lightSecondary,
        background: lightBackground,
        surface: lightSurface,
        error: lightError,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).copyWith(
        bodyLarge: GoogleFonts.inter(textStyle: ThemeData.light().textTheme.bodyLarge),
        bodyMedium: GoogleFonts.inter(textStyle: ThemeData.light().textTheme.bodyMedium),
        bodySmall: GoogleFonts.inter(textStyle: ThemeData.light().textTheme.bodySmall),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkSecondary,
        background: darkBackground,
        surface: darkSurface,
        onPrimary: Color(0xFF381E72),
        onSecondary: Color(0xFF493900),
        onBackground: Color(0xFFE6E1E9),
        onSurface: Color(0xFFE6E1E9),
        error: darkError,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: GoogleFonts.inter(textStyle: ThemeData.dark().textTheme.bodyLarge),
        bodyMedium: GoogleFonts.inter(textStyle: ThemeData.dark().textTheme.bodyMedium),
        bodySmall: GoogleFonts.inter(textStyle: ThemeData.dark().textTheme.bodySmall),
      ),
      cardTheme: CardThemeData(
        color: darkSurfaceVariant,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
