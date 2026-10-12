import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFFFF5252); // Enerjik mercan kırmızı
  static const Color primaryDark = Color(0xFFD32F2F);
  static const Color accent = Color(0xFF00E676); // Başarı / fit yeşili
  static const Color background = Color(0xFF0F1115); // Koyu modern arka plan
  static const Color cardColor = Color(0xFF1A1D24); // Kart arka planı
  static const Color surfaceColor = Color(0xFF242831);
  static const Color textPrimary = Color(0xFFF5F6F8);
  static const Color textSecondary = Color(0xFF9E9EA7);
  static const Color proteinColor = Color(0xFFFF5252);
  static const Color carbColor = Color(0xFFFFB300);
  static const Color fatColor = Color(0xFF29B6F6);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: cardColor,
        background: background,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
