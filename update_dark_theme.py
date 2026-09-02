import re

replacement = """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design_system/tokens.dart';
import 'app_colors_extension.dart';

class DarkTheme {
  DarkTheme._();

  static ThemeData get theme {
    final baseTextTheme = ThemeData.dark().textTheme;
    
    final textTheme = GoogleFonts.manropeTextTheme(baseTextTheme).copyWith(
      displayLarge: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: AppColorsExtension.dark.textPrimary),
      displayMedium: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: AppColorsExtension.dark.textPrimary),
      displaySmall: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: AppColorsExtension.dark.textPrimary),
      headlineLarge: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: AppColorsExtension.dark.textPrimary),
      headlineMedium: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: AppColorsExtension.dark.textPrimary),
      headlineSmall: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: AppColorsExtension.dark.textPrimary),
      titleLarge: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: AppColorsExtension.dark.textPrimary),
      titleMedium: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: AppColorsExtension.dark.textPrimary),
      titleSmall: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: AppColorsExtension.dark.textPrimary),
      bodyLarge: GoogleFonts.manrope(fontWeight: FontWeight.w500, color: AppColorsExtension.dark.textPrimary),
      bodyMedium: GoogleFonts.manrope(fontWeight: FontWeight.w400, color: AppColorsExtension.dark.textPrimary),
      bodySmall: GoogleFonts.manrope(fontWeight: FontWeight.w400, color: AppColorsExtension.dark.textSecondary),
      labelLarge: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: AppColorsExtension.dark.textPrimary),
      labelMedium: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: AppColorsExtension.dark.textSecondary),
      labelSmall: GoogleFonts.manrope(fontWeight: FontWeight.w500, color: AppColorsExtension.dark.textSecondary),
    );

    return ThemeData(
      dividerColor: AppColorsExtension.dark.borderColor,
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColorsExtension.dark.primary,
      colorScheme: ColorScheme.dark(
        primary: AppColorsExtension.dark.primary,
        secondary: AppColorsExtension.dark.secondary,
        surface: AppColorsExtension.dark.surface,
        error: AppColorsExtension.dark.error,
        onPrimary: AppColorsExtension.dark.white,
        onSecondary: AppColorsExtension.dark.textPrimary,
        onSurface: AppColorsExtension.dark.textPrimary,
        onError: AppColorsExtension.dark.white,
      ),

      scaffoldBackgroundColor: AppColorsExtension.dark.background,
      cardColor: AppColorsExtension.dark.cardColor,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsExtension.dark.background,
        foregroundColor: AppColorsExtension.dark.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),

      cardTheme: CardThemeData(
        color: AppColorsExtension.dark.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.r16),
          side: BorderSide(
            color: AppColorsExtension.dark.borderColor,
            width: AppTokens.bThin,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColorsExtension.dark.surface,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppTokens.s16, vertical: AppTokens.s16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.r12),
          borderSide: BorderSide(color: AppColorsExtension.dark.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.r12),
          borderSide: BorderSide(color: AppColorsExtension.dark.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.r12),
          borderSide: BorderSide(color: AppColorsExtension.dark.primary, width: AppTokens.bThick),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.r12),
          borderSide: BorderSide(color: AppColorsExtension.dark.error),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColorsExtension.dark.textSecondary),
      ),

      textTheme: textTheme,

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsExtension.dark.primary,
          foregroundColor: AppColorsExtension.dark.white,
          elevation: 0,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.r12),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppTokens.s16,
            horizontal: AppTokens.s24,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorsExtension.dark.textPrimary,
          side: BorderSide(color: AppColorsExtension.dark.borderColor),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.r12),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppTokens.s16,
            horizontal: AppTokens.s24,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorsExtension.dark.primary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.r12),
          ),
        ),
      ),

      extensions: [AppColorsExtension.dark],
    );
  }
}
"""

with open('lib/config/themes/dark_theme.dart', 'w') as f:
    f.write(replacement)
