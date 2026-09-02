import re

with open('lib/config/themes/light_theme.dart', 'r') as f:
    content = f.read()

replacement = """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design_system/tokens.dart';
import 'app_colors_extension.dart';

class LightTheme {
  LightTheme._();

  static ThemeData get theme {
    final baseTextTheme = ThemeData.light().textTheme;
    
    // Create base Manrope theme, then apply Cairo for Arabic support implicitly if needed
    // In a real multi-locale app, we would resolve this dynamically, 
    // but for ThemeData we can set a fallback or use GoogleFonts directly.
    final textTheme = GoogleFonts.manropeTextTheme(baseTextTheme).copyWith(
      displayLarge: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: AppColorsExtension.light.textPrimary),
      displayMedium: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: AppColorsExtension.light.textPrimary),
      displaySmall: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: AppColorsExtension.light.textPrimary),
      headlineLarge: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: AppColorsExtension.light.textPrimary),
      headlineMedium: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: AppColorsExtension.light.textPrimary),
      headlineSmall: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: AppColorsExtension.light.textPrimary),
      titleLarge: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: AppColorsExtension.light.textPrimary),
      titleMedium: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: AppColorsExtension.light.textPrimary),
      titleSmall: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: AppColorsExtension.light.textPrimary),
      bodyLarge: GoogleFonts.manrope(fontWeight: FontWeight.w500, color: AppColorsExtension.light.textPrimary),
      bodyMedium: GoogleFonts.manrope(fontWeight: FontWeight.w400, color: AppColorsExtension.light.textPrimary),
      bodySmall: GoogleFonts.manrope(fontWeight: FontWeight.w400, color: AppColorsExtension.light.textSecondary),
      labelLarge: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: AppColorsExtension.light.textPrimary),
      labelMedium: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: AppColorsExtension.light.textSecondary),
      labelSmall: GoogleFonts.manrope(fontWeight: FontWeight.w500, color: AppColorsExtension.light.textSecondary),
    );

    return ThemeData(
      dividerColor: AppColorsExtension.light.borderColor,
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColorsExtension.light.primary,
      colorScheme: ColorScheme.light(
        primary: AppColorsExtension.light.primary,
        secondary: AppColorsExtension.light.secondary,
        surface: AppColorsExtension.light.surface,
        error: AppColorsExtension.light.error,
        onPrimary: AppColorsExtension.light.white,
        onSecondary: AppColorsExtension.light.textPrimary,
        onSurface: AppColorsExtension.light.textPrimary,
        onError: AppColorsExtension.light.white,
      ),

      scaffoldBackgroundColor: AppColorsExtension.light.background,
      cardColor: AppColorsExtension.light.cardColor,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsExtension.light.background,
        foregroundColor: AppColorsExtension.light.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),

      cardTheme: CardThemeData(
        color: AppColorsExtension.light.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.r16),
          side: BorderSide(
            color: AppColorsExtension.light.borderColor.withOpacity(0.5),
            width: AppTokens.bThin,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColorsExtension.light.surface,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppTokens.s16, vertical: AppTokens.s16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.r12),
          borderSide: BorderSide(color: AppColorsExtension.light.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.r12),
          borderSide: BorderSide(color: AppColorsExtension.light.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.r12),
          borderSide: BorderSide(color: AppColorsExtension.light.primary, width: AppTokens.bThick),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.r12),
          borderSide: BorderSide(color: AppColorsExtension.light.error),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColorsExtension.light.textSecondary),
      ),

      textTheme: textTheme,

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsExtension.light.primary,
          foregroundColor: AppColorsExtension.light.white,
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
          foregroundColor: AppColorsExtension.light.textPrimary,
          side: BorderSide(color: AppColorsExtension.light.borderColor),
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
          foregroundColor: AppColorsExtension.light.primary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.r12),
          ),
        ),
      ),

      extensions: [AppColorsExtension.light],
    );
  }
}
"""

with open('lib/config/themes/light_theme.dart', 'w') as f:
    f.write(replacement)
