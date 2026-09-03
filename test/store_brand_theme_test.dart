import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/config/themes/app_colors_extension.dart';
import 'package:new_strucuture/config/themes/app_theme.dart';
import 'package:new_strucuture/features/store/data/models/owner.dart';
import 'package:new_strucuture/features/store/presentation/store_brand_theme.dart';

void main() {
  test('saved owner colors override the store theme with safe contrast', () {
    const owner = Owner(
      id: 'owner',
      name: 'Talaby',
      slug: 'talaby',
      primaryColor: '#087E8B',
      secondaryColor: '#F2C14E',
    );

    final theme = applyStoreBrandColors(AppTheme.lightTheme, owner);
    final colors = theme.extension<AppColorsExtension>();

    expect(theme.colorScheme.primary, const Color(0xFF087E8B));
    expect(theme.colorScheme.tertiary, const Color(0xFFF2C14E));
    expect(theme.colorScheme.onPrimary, Colors.white);
    expect(theme.colorScheme.onTertiary, const Color(0xFF2E2910));
    expect(colors?.primary, const Color(0xFF087E8B));
    expect(colors?.secondary, const Color(0xFFF2C14E));
  });

  test('invalid owner colors preserve the configured theme palette', () {
    const owner = Owner(
      id: 'owner',
      name: 'Talaby',
      slug: 'talaby',
      primaryColor: 'invalid',
      secondaryColor: '#123',
    );

    final base = AppTheme.lightTheme;
    final theme = applyStoreBrandColors(base, owner);

    expect(theme.colorScheme.primary, base.colorScheme.primary);
    expect(theme.colorScheme.tertiary, base.colorScheme.tertiary);
  });
}
