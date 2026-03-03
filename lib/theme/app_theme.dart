import 'package:flutter/material.dart';

/// SteriScan application theme — medical-grade indigo/blue palette.
class AppTheme {
  AppTheme._();

  // ── Brand Colors ────────────────────────────────────────────────

  static const Color primaryIndigo = Color(0xFF3730A3);
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color accentTeal = Color(0xFF0D9488);

  static const Color successGreen = Color(0xFF16A34A);
  static const Color warningOrange = Color(0xFFF97316);
  static const Color errorRed = Color(0xFFDC2626);

  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFE2E8F0);

  // ── Gradients ───────────────────────────────────────────────────

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3730A3), Color(0xFF2563EB)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
  );

  // ── Theme Data ──────────────────────────────────────────────────

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryIndigo,
          brightness: Brightness.light,
          primary: primaryIndigo,
          secondary: accentTeal,
          error: errorRed,
          surface: surfaceCard,
        ),
        scaffoldBackgroundColor: surfaceLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryIndigo,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        cardTheme: CardTheme(
          color: surfaceCard,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryIndigo,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryIndigo,
            side: const BorderSide(color: primaryIndigo, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryIndigo, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        dividerTheme: const DividerThemeData(
          color: borderLight,
          thickness: 1,
          space: 1,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      );
}
