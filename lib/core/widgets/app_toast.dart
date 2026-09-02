import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';

abstract final class AppToast {
  static void success(BuildContext context, String message) {
    CherryToast.success(
      title: _title(message),
      textDirection: _direction(context),
      animationType: AnimationType.fromTop,
      toastDuration: const Duration(seconds: 3),
    ).show(context);
  }

  static void error(BuildContext context, String message) {
    CherryToast.error(
      title: _title(message),
      textDirection: _direction(context),
      animationType: AnimationType.fromTop,
      toastDuration: const Duration(seconds: 4),
    ).show(context);
  }

  static void info(BuildContext context, String message) {
    CherryToast.info(
      title: _title(message),
      textDirection: _direction(context),
      animationType: AnimationType.fromTop,
      toastDuration: const Duration(seconds: 3),
    ).show(context);
  }

  static Text _title(String message) => Text(
    message,
    textAlign: TextAlign.center,
    style: const TextStyle(color: Colors.black87),
  );

  static TextDirection _direction(BuildContext context) =>
      Directionality.maybeOf(context) ?? TextDirection.rtl;
}
