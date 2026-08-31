import 'package:flutter/material.dart';

class AppTypography {
  static const String fontFamily =
      'Alexandria'; // Assuming this is the main body font
  static const String titleFontFamily = 'MajorMonoDisplay';

  static TextStyle get _base => const TextStyle(
    fontFamily: fontFamily,
    color: Color(0xFF191B1A), // Near black
    letterSpacing: 0.2,
  );

  // Headlines
  static TextStyle get h1 => _base.copyWith(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -1.0,
  );

  static TextStyle get h2 => _base.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.5,
  );

  static TextStyle get h3 =>
      _base.copyWith(fontSize: 24, fontWeight: FontWeight.w600, height: 1.4);

  static TextStyle get h4 =>
      _base.copyWith(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4);

  static TextStyle get brandTitle => _base.copyWith(
    fontFamily: titleFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 1,
    letterSpacing: 1.2,
  );

  // Body
  static TextStyle get bodyLarge =>
      _base.copyWith(fontSize: 18, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle get bodyMedium =>
      _base.copyWith(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle get bodySmall =>
      _base.copyWith(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);

  // Captions / Overlines
  static TextStyle get caption => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF757575), // Neutral secondary
  );

  // Specifics
  static TextStyle get priceLarge =>
      _base.copyWith(fontSize: 24, fontWeight: FontWeight.w700);

  static TextStyle get priceMedium =>
      _base.copyWith(fontSize: 18, fontWeight: FontWeight.w600);

  static TextStyle get buttonText => _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}
