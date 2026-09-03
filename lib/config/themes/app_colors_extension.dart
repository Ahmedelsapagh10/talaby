import 'package:flutter/material.dart';

/// A custom ThemeExtension to hold app-specific color definitions.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.lightGray,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.backgroundAppBar,
    required this.background2,
    required this.surface,
    required this.surfaceMuted,
    required this.cardColor,
    required this.borderColor,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.warning,
    required this.error,
    required this.grey,
    required this.grey85,
    required this.white,
    required this.black,
    required this.lightGrey,
    required this.greyFA,
    required this.greyE8,
    required this.greyE0,
    required this.greyE1,
    required this.greyCF,
    required this.greyA8,
    required this.grey5C,
    required this.grey32,
    required this.grey1F,
    required this.greyE7,
    required this.greyCE,
    required this.greyF3,
    required this.greyF4,
    required this.greyBB,
    required this.primaryBackground,
    required this.onPrimaryBackground,
    required this.fixedPrimary,
    required this.greenStatus,
    required this.greenTextStatus,
    required this.redStatus,
    required this.redTextStatus,
    required this.yellowStatus,
    required this.yellowTextStatus,
    required this.completeStatus,
    required this.completeTextStatus,
    required this.holdStatus,
    required this.holdTextStatus,
    required this.text242,
    required this.text464,
  });

  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color backgroundAppBar;
  final Color background2;
  final Color surface;
  final Color surfaceMuted;
  final Color cardColor;
  final Color borderColor;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color success;
  final Color warning;
  final Color error;
  final Color grey85;
  final Color white;
  final Color black;
  final Color lightGrey;
  final Color grey;
  final Color greyFA;
  final Color greyE8;
  final Color greyE0;
  final Color greyE1;
  final Color greyCF;
  final Color greyA8;
  final Color grey5C;
  final Color grey32;
  final Color grey1F;
  final Color greyE7;
  final Color greyCE;
  final Color greyF3;
  final Color greyF4;
  final Color greyBB;
  final Color primaryBackground;
  final Color onPrimaryBackground;
  final Color fixedPrimary; // Same in both light and dark mode
  final Color? lightGray;
  final Color text242;
  final Color text464;

  //status colors
  final Color greenStatus;

  final Color redStatus;

  final Color yellowStatus;

  final Color completeStatus;

  final Color holdStatus;

  //text status colors
  final Color greenTextStatus;

  final Color redTextStatus;

  final Color yellowTextStatus;

  final Color completeTextStatus;

  final Color holdTextStatus;

  /// Light theme colors
  static const AppColorsExtension light = AppColorsExtension(
    primary: Color(0xFF176B4D),
    secondary: Color(0xFFF2C14E),
    accent: Color(0xFFEB7D00),
    background: Color(0xFFFCFBF8),
    backgroundAppBar: Color(0xFF176B4D),
    background2: Color(0xFFF4F3ED),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF4F3ED),
    cardColor: Color(0xFFFFFFFF),
    borderColor: Color(0xFFE0DCCF),
    border: Color(0xFFE0DCCF),
    textPrimary: Color(0xFF2E2910),
    textSecondary: Color(0xFF7A7563),
    success: Color(0xFF176B4D),
    warning: Color(0xFFEB7D00),
    error: Color(0xFFD64A4A),
    grey85: Color(0xFF7A7563),
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    grey: Color(0xFFA19C8A),
    lightGrey: Color(0xFFE0DCCF),
    greyFA: Color(0xFFF4F3ED),
    greyE8: Color(0xFFE0DCCF),
    greyE0: Color(0xFFD1CDBF),
    greyE1: Color(0xFFD1CDBF),
    greyCF: Color(0xFFB8B4A5),
    greyA8: Color(0xFFA19C8A),
    grey5C: Color(0xFF7A7563),
    grey32: Color(0xFF423E2D),
    grey1F: Color(0xFF2E2910),
    greyE7: Color(0xFFE0DCCF),
    greyCE: Color(0xFFB8B4A5),
    greyF3: Color(0xFFF4F3ED),
    greyF4: Color(0xFFF4F3ED),
    greyBB: Color(0xFFA19C8A),
    primaryBackground: Color(0xFF176B4D),
    onPrimaryBackground: Color(0xFFFFFFFF),
    fixedPrimary: Color(0xFF176B4D),
    greenStatus: Color(0xFF176B4D),
    redStatus: Color(0xFFD64A4A),
    yellowStatus: Color(0xFFEB7D00),
    completeStatus: Color(0xFF176B4D),
    holdStatus: Color(0xFFF2C14E),
    greenTextStatus: Color(0xFF176B4D),
    redTextStatus: Color(0xFFD64A4A),
    yellowTextStatus: Color(0xFFEB7D00),
    completeTextStatus: Color(0xFF176B4D),
    holdTextStatus: Color(0xFF7A7563),
    lightGray: Color(0xFFF4F3ED),
    text242: Color(0xFF423E2D),
    text464: Color(0xFF7A7563),
  );

  /// Dark theme colors
  static const AppColorsExtension dark = AppColorsExtension(
    primary: Color(0xFF176B4D),
    secondary: Color(0xFFF2C14E),
    accent: Color(0xFFEB7D00),
    background: Color(0xFF1C1A14),
    backgroundAppBar: Color(0xFF15130F),
    background2: Color(0xFF24211A),
    surface: Color(0xFF24211A),
    surfaceMuted: Color(0xFF2E2A21),
    cardColor: Color(0xFF24211A),
    borderColor: Color(0xFF38342A),
    border: Color(0xFF38342A),
    textPrimary: Color(0xFFFCFBF8),
    textSecondary: Color(0xFFB8B4A5),
    success: Color(0xFF176B4D),
    warning: Color(0xFFEB7D00),
    error: Color(0xFFD64A4A),
    grey85: Color(0xFF7A7563),
    white: Color(0xFF24211A),
    black: Color(0xFFFFFFFF),
    lightGrey: Color(0xFF423E2D),
    grey: Color(0xFF7A7563),
    greyFA: Color(0xFF1C1A14),
    greyE8: Color(0xFF38342A),
    greyE0: Color(0xFF38342A),
    greyE1: Color(0xFF38342A),
    greyCF: Color(0xFF423E2D),
    greyA8: Color(0xFF7A7563),
    grey5C: Color(0xFFB8B4A5),
    grey32: Color(0xFFD1CDBF),
    grey1F: Color(0xFFE0DCCF),
    greyE7: Color(0xFF38342A),
    greyCE: Color(0xFF423E2D),
    greyF3: Color(0xFF1C1A14),
    greyF4: Color(0xFF1C1A14),
    greyBB: Color(0xFF423E2D),
    primaryBackground: Color(0xFF15130F),
    onPrimaryBackground: Color(0xFFFCFBF8),
    fixedPrimary: Color(0xFF176B4D),
    greenStatus: Color(0xFF176B4D),
    redStatus: Color(0xFFD64A4A),
    yellowStatus: Color(0xFFEB7D00),
    completeStatus: Color(0xFF176B4D),
    holdStatus: Color(0xFF38342A),
    greenTextStatus: Color(0xFF423E2D),
    redTextStatus: Color(0xFFE0DCCF),
    yellowTextStatus: Color(0xFFF2C14E),
    completeTextStatus: Color(0xFFE0DCCF),
    holdTextStatus: Color(0xFFB8B4A5),
    lightGray: Color(0xFF38342A),
    text242: Color(0xFFE0DCCF),
    text464: Color(0xFFB8B4A5),
  );

  @override
  AppColorsExtension copyWith({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? background,
    Color? backgroundAppBar,
    Color? background2,
    Color? surface,
    Color? surfaceMuted,
    Color? cardColor,
    Color? borderColor,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? success,
    Color? warning,
    Color? error,
    Color? grey85,
    Color? white,
    Color? black,
    Color? lightGrey,
    Color? grey,
    Color? greyFA,
    Color? greyE8,
    Color? greyE0,
    Color? greyE1,
    Color? greyCF,
    Color? greyA8,
    Color? grey5C,
    Color? grey32,
    Color? grey1F,
    Color? greyE7,
    Color? greyCE,
    Color? greyF3,
    Color? greyF4,
    Color? greyBB,
    Color? primaryBackground,
    Color? onPrimaryBackground,
    Color? fixedPrimary,
    Color? lightGray,
    Color? text242,
    Color? text464,
    Color? greenStatus,
    Color? redStatus,
    Color? yellowStatus,
    Color? completeStatus,
    Color? holdStatus,
    Color? greenTextStatus,
    Color? redTextStatus,
    Color? yellowTextStatus,
    Color? completeTextStatus,
    Color? holdTextStatus,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      background: background ?? this.background,
      backgroundAppBar: backgroundAppBar ?? this.backgroundAppBar,
      background2: background2 ?? this.background2,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      cardColor: cardColor ?? this.cardColor,
      borderColor: borderColor ?? this.borderColor,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      grey85: grey85 ?? this.grey85,
      white: white ?? this.white,
      black: black ?? this.black,
      lightGrey: lightGrey ?? this.lightGrey,
      grey: grey ?? this.grey,
      greyFA: greyFA ?? this.greyFA,
      greyE8: greyE8 ?? this.greyE8,
      greyE0: greyE0 ?? this.greyE0,
      greyE1: greyE1 ?? this.greyE1,
      greyCF: greyCF ?? this.greyCF,
      greyA8: greyA8 ?? this.greyA8,
      grey5C: grey5C ?? this.grey5C,
      grey32: grey32 ?? this.grey32,
      grey1F: grey1F ?? this.grey1F,
      greyE7: greyE7 ?? this.greyE7,
      greyCE: greyCE ?? this.greyCE,
      greyF3: greyF3 ?? this.greyF3,
      greyF4: greyF4 ?? this.greyF4,
      greyBB: greyBB ?? this.greyBB,
      primaryBackground: primaryBackground ?? this.primaryBackground,
      onPrimaryBackground: onPrimaryBackground ?? this.onPrimaryBackground,
      fixedPrimary: fixedPrimary ?? this.fixedPrimary,
      greenStatus: greenStatus ?? this.greenStatus,
      redStatus: redStatus ?? this.redStatus,
      yellowStatus: yellowStatus ?? this.yellowStatus,
      completeStatus: completeStatus ?? this.completeStatus,
      holdStatus: holdStatus ?? this.holdStatus,
      greenTextStatus: greenTextStatus ?? this.greenTextStatus,
      redTextStatus: redTextStatus ?? this.redTextStatus,
      yellowTextStatus: yellowTextStatus ?? this.yellowTextStatus,
      completeTextStatus: completeTextStatus ?? this.completeTextStatus,
      holdTextStatus: holdTextStatus ?? this.holdTextStatus,
      lightGray: lightGray ?? this.lightGray,
      text242: text242 ?? this.text242,
      text464: text464 ?? this.text464,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;

    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      background: Color.lerp(background, other.background, t)!,
      backgroundAppBar: Color.lerp(
        backgroundAppBar,
        other.backgroundAppBar,
        t,
      )!,
      background2: Color.lerp(background2, other.background2, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      grey85: Color.lerp(grey85, other.grey85, t)!,
      white: Color.lerp(white, other.white, t)!,
      black: Color.lerp(black, other.black, t)!,
      lightGrey: Color.lerp(lightGrey, other.lightGrey, t)!,
      grey: Color.lerp(grey, other.grey, t)!,
      greyFA: Color.lerp(greyFA, other.greyFA, t)!,
      greyE8: Color.lerp(greyE8, other.greyE8, t)!,
      greyE0: Color.lerp(greyE0, other.greyE0, t)!,
      greyE1: Color.lerp(greyE1, other.greyE1, t)!,
      greyCF: Color.lerp(greyCF, other.greyCF, t)!,
      greyA8: Color.lerp(greyA8, other.greyA8, t)!,
      grey5C: Color.lerp(grey5C, other.grey5C, t)!,
      grey32: Color.lerp(grey32, other.grey32, t)!,
      grey1F: Color.lerp(grey1F, other.grey1F, t)!,
      greyE7: Color.lerp(greyE7, other.greyE7, t)!,
      greyCE: Color.lerp(greyCE, other.greyCE, t)!,
      greyF3: Color.lerp(greyF3, other.greyF3, t)!,
      greyF4: Color.lerp(greyF4, other.greyF4, t)!,
      greyBB: Color.lerp(greyBB, other.greyBB, t)!,
      primaryBackground: Color.lerp(
        primaryBackground,
        other.primaryBackground,
        t,
      )!,
      onPrimaryBackground: Color.lerp(
        onPrimaryBackground,
        other.onPrimaryBackground,
        t,
      )!,
      fixedPrimary: Color.lerp(fixedPrimary, other.fixedPrimary, t)!,
      greenStatus: Color.lerp(greenStatus, other.greenStatus, t)!,
      redStatus: Color.lerp(redStatus, other.redStatus, t)!,
      yellowStatus: Color.lerp(yellowStatus, other.yellowStatus, t)!,
      completeStatus: Color.lerp(completeStatus, other.completeStatus, t)!,
      holdStatus: Color.lerp(holdStatus, other.holdStatus, t)!,
      greenTextStatus: Color.lerp(greenTextStatus, other.greenTextStatus, t)!,
      redTextStatus: Color.lerp(redTextStatus, other.redTextStatus, t)!,
      yellowTextStatus: Color.lerp(
        yellowTextStatus,
        other.yellowTextStatus,
        t,
      )!,
      completeTextStatus: Color.lerp(
        completeTextStatus,
        other.completeTextStatus,
        t,
      )!,
      holdTextStatus: Color.lerp(holdTextStatus, other.holdTextStatus, t)!,
      lightGray: Color.lerp(lightGray, other.lightGray, t),
      text242: Color.lerp(text242, other.text242, t)!,
      text464: Color.lerp(text464, other.text464, t)!,
    );
  }

  @override
  String toString() {
    return 'AppColorsExtension('
        'primary: $primary, secondary: $secondary, accent: $accent, '
        'background: $background, surface: $surface, '
        'surfaceMuted: $surfaceMuted, cardColor: $cardColor, border: $border, '
        'textPrimary: $textPrimary, textSecondary: $textSecondary, success: $success, '
        'warning: $warning, error: $error, grey85: $grey85, '
        'primaryBackground: $primaryBackground, onPrimaryBackground: $onPrimaryBackground, '
        'fixedPrimary: $fixedPrimary, text242: $text242, text464: $text464)';
  }
}
