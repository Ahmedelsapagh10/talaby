import 'package:flutter/material.dart';

import '../../../config/themes/app_colors_extension.dart';
import '../data/models/owner.dart';

ThemeData applyStoreBrandColors(ThemeData theme, Owner? owner) {
  final currentColors = theme.extension<AppColorsExtension>();
  if (currentColors == null || owner == null) return theme;

  final primary =
      _tryParseHexColor(owner.primaryColor) ?? currentColors.primary;
  final secondary =
      _tryParseHexColor(owner.secondaryColor) ?? currentColors.secondary;
  final brandColors = currentColors.copyWith(
    primary: primary,
    secondary: secondary,
    primaryBackground: primary,
    fixedPrimary: primary,
  );

  return theme.copyWith(
    primaryColor: primary,
    colorScheme: theme.colorScheme.copyWith(
      primary: primary,
      tertiary: secondary,
      onPrimary: _foregroundFor(primary),
      onTertiary: _foregroundFor(secondary),
    ),
    extensions: [
      for (final extension in theme.extensions.values)
        if (extension is! AppColorsExtension) extension,
      brandColors,
    ],
  );
}

Color? _tryParseHexColor(String? value) {
  final trimmed = value?.trim().replaceFirst('#', '') ?? '';
  if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(trimmed)) return null;
  return Color(int.parse('FF$trimmed', radix: 16));
}

Color _foregroundFor(Color background) =>
    ThemeData.estimateBrightnessForColor(background) == Brightness.dark
    ? Colors.white
    : const Color(0xFF2E2910);
