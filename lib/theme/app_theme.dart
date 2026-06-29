import 'package:flutter/material.dart';

/// Design tokens for the Bus 3rd brand, ported from the prototype.
/// Red + purple + chrome, cream surfaces, Singlish-grade sarcasm.
class AppColors {
  AppColors._();

  // Brand
  static const red = Color(0xFFE2231A);
  static const redDark = Color(0xFFC81C13);
  static const purple = Color(0xFF6E2585);
  static const purpleLight = Color(0xFF7A2A90);
  static const purpleDark = Color(0xFF5C1E70);
  static const amber = Color(0xFFFFB300);
  static const amberDark = Color(0xFFC98A00);

  // Surfaces
  static const cream = Color(0xFFF4F1EA);
  static const card = Color(0xFFFFFFFF);
  static const darkChip = Color(0xFF0A0A0A);

  // Text
  static const ink = Color(0xFF1C1814);
  static const inkSoft = Color(0xFF6B6359);
  static const muted = Color(0xFF8A8178);
  static const muted2 = Color(0xFF9A9088);
  static const faint = Color(0xFFB5ADA3);

  // Status
  static const green = Color(0xFF1B9E4B);
  static const greenLight = Color(0xFF7CE0A0);

  // Tags / accents
  static const tagRedBg = Color(0xFFFBE9E8);
  static const tagRedFg = Color(0xFFC81C13);
  static const tagPurpleBg = Color(0xFFF3E6F7);
  static const tagPurpleFg = Color(0xFF6E2585);
  static const goldBg = Color(0xFFFBF4DF);
  static const goldBorder = Color(0xFFE0C97A);
  static const goldText = Color(0xFF8A6D1F);
  static const goldText2 = Color(0xFFA98C3F);

  // Gradients
  static const splashGradient = [Color(0xFF311614), Color(0xFF1C1814), Color(0xFF110E0C)];
  static const peaceGradient = [Color(0xFF2A2350), Color(0xFF161228), Color(0xFF0E0B1C)];
  static const redHeader = [red, redDark];
  static const purpleCard = [purpleLight, purpleDark];
}

/// Font family names (declared in pubspec.yaml).
class AppFonts {
  AppFonts._();
  static const display = 'Archivo'; // headings / heavy
  static const body = 'HankenGrotesk';
  static const mono = 'SpaceMono'; // numbers / terminal
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.red,
      primary: AppColors.red,
      secondary: AppColors.purple,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      fontFamily: AppFonts.body,
      splashFactory: InkRipple.splashFactory,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: TextStyle(fontFamily: AppFonts.body, color: Colors.white),
      ),
    );
  }
}

/// Convenience text-style builders so screens read cleanly.
class T {
  T._();

  static TextStyle display(double size,
          {Color color = AppColors.ink, FontWeight weight = FontWeight.w900, double spacing = -0.5}) =>
      TextStyle(
        fontFamily: AppFonts.display,
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: spacing,
        height: 1.05,
      );

  static TextStyle body(double size,
          {Color color = AppColors.ink, FontWeight weight = FontWeight.w500, double height = 1.45, FontStyle? style}) =>
      TextStyle(
        fontFamily: AppFonts.body,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        fontStyle: style,
      );

  static TextStyle mono(double size,
          {Color color = AppColors.ink, FontWeight weight = FontWeight.w700, double spacing = 0.2}) =>
      TextStyle(
        fontFamily: AppFonts.mono,
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: spacing,
      );
}
