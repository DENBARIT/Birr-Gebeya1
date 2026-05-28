import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BirrTheme {
  // Theme Color System
  static const Color primary = Color(0xFF005440); // Deep Green
  static const Color primaryContainer = Color(0xFF0F6E56);
  static const Color secondary = Color(0xFF885200); // Amber/Gold Accent
  static const Color secondaryContainer = Color(0xFFFDAD4E);
  static const Color background = Color(0xFFF8F7F2); // Warm white
  static const Color surface = Color(0xFFF7FAF6);
  static const Color surfaceContainerLow = Color(0xFFF1F4F1);
  static const Color surfaceContainer = Color(0xFFEBEFEB);
  static const Color surfaceContainerHighest = Color(0xFFE0E3E0);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF181D1A);
  static const Color onSurfaceVariant = Color(0xFF3F4944);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color outlineVariant = Color(0xFFBEC9C3);

  // Border Radii
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;

  // Custom Elevation Shadow
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0xFF00478D).withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Text Styling — BuildContext is nullable so these can be used inside static theme getters
  static TextStyle getDisplayCurrency(BuildContext? context) {
    return GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.64,
      height: 1.25,
      color: onSurface,
    );
  }

  static TextStyle getHeadlineLg(BuildContext? context) {
    return GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: onSurface,
    );
  }

  static TextStyle getHeadlineLgMobile(BuildContext? context) {
    return GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: onSurface,
    );
  }

  static TextStyle getHeadlineMd(BuildContext? context) {
    return GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: onSurface,
    );
  }

  static TextStyle getHeadlineMdMobile(BuildContext? context) {
    return GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: onSurface,
    );
  }

  static TextStyle getBodyLg(BuildContext? context) {
    return GoogleFonts.notoSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: onSurface,
    );
  }

  static TextStyle getBodyMd(BuildContext? context) {
    return GoogleFonts.notoSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: onSurface,
    );
  }

  static TextStyle getLabelBold(BuildContext? context) {
    return GoogleFonts.notoSans(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
      color: onSurface,
    );
  }

  static TextStyle getLabelMd(BuildContext? context) {
    return GoogleFonts.notoSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: onSurfaceVariant,
    );
  }

  // App Theme Setup
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: onSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: getLabelMd(null).copyWith(color: onSurfaceVariant),
        floatingLabelStyle: getLabelBold(null).copyWith(color: primary),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: primary,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}
