import 'package:flutter/material.dart';
import 'package:new_strucuture/config/themes/dark_theme.dart';

import 'package:new_strucuture/config/themes/light_theme.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // تعريف مستمع للتغييرات في الثيم
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(
    ThemeMode.light,
  );

  // الحصول على وضع الثيم الحالي
  static ThemeMode get currentThemeMode => themeNotifier.value;

  // الحصول على الثيم الحالي
  static ThemeData get currentTheme =>
      currentThemeMode == ThemeMode.dark ? darkTheme : lightTheme;

  // ثيم الوضع النهاري
  static ThemeData get lightTheme => LightTheme.theme;

  // ثيم الوضع الليلي
  static ThemeData get darkTheme => DarkTheme.theme;

  static ThemeData lightThemeFor(Locale locale) => LightTheme.themeFor(locale);

  static ThemeData darkThemeFor(Locale locale) => DarkTheme.themeFor(locale);

  // تبديل الثيم
  static void toggleTheme() {
    themeNotifier.value = currentThemeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  // تعيين وضع ثيم محدد
  static void setTheme(ThemeMode themeMode) {
    themeNotifier.value = themeMode;
  }

  // التحقق مما إذا كان الوضع الليلي نشطًا
  static bool get isDarkMode => currentThemeMode == ThemeMode.dark;
}
