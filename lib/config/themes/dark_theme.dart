import 'package:flutter/material.dart';
import '../../core/design_system/tokens.dart';
import '../../core/design_system/typography.dart';
import 'app_colors_extension.dart';

class DarkTheme {
  DarkTheme._();

  static ThemeData get theme => themeFor(const Locale('ar'));

  static ThemeData themeFor(Locale locale) {
    const colors = AppColorsExtension.dark;
    final fontFamily = AppTypography.familyFor(locale);
    final baseTextTheme = ThemeData.dark().textTheme.apply(
      fontFamily: fontFamily,
      bodyColor: colors.textPrimary,
      displayColor: colors.textPrimary,
    );
    final textTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      bodySmall: baseTextTheme.bodySmall?.copyWith(color: colors.textSecondary),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        color: colors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        color: colors.textSecondary,
      ),
    );

    return ThemeData(
      dividerColor: AppColorsExtension.dark.borderColor,
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      primaryColor: colors.primary,
      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        secondary: colors.accent,
        tertiary: colors.secondary,
        surface: colors.surface,
        surfaceContainerHighest: colors.surfaceMuted,
        error: colors.error,
        onPrimary: Colors.white,
        onSecondary: const Color(0xFF2E2910),
        onTertiary: const Color(0xFF2E2910),
        onSurface: colors.textPrimary,
        onError: Colors.white,
        outline: colors.border,
      ),

      scaffoldBackgroundColor: colors.background,
      cardColor: colors.cardColor,

      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),

      cardTheme: CardThemeData(
        color: colors.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.r16),
          side: BorderSide(color: colors.border, width: AppTokens.bThin),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        fillColor: colors.surface,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.s16,
          vertical: AppTokens.s16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.r12),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.r12),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.r12),
          borderSide: BorderSide(
            color: colors.primary,
            width: AppTokens.bThick,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.r12),
          borderSide: BorderSide(color: colors.error),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
      ),

      textTheme: textTheme,

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
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
          foregroundColor: colors.textPrimary,
          backgroundColor: colors.surfaceMuted,
          side: BorderSide(color: colors.border),
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
          foregroundColor: colors.secondary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.r12),
          ),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primary,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(color: colors.border, thickness: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.r24),
          side: BorderSide(color: colors.border),
        ),
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(colors.surface),
        elevation: const WidgetStatePropertyAll(0),
        side: WidgetStatePropertyAll(BorderSide(color: colors.border)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.r12),
          ),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(colors.surfaceMuted),
        headingTextStyle: textTheme.labelLarge,
        dataTextStyle: textTheme.bodyMedium,
        dividerThickness: 1,
      ),
      extensions: [colors],
    );
  }
}
