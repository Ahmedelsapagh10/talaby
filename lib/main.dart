import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app.dart';
import 'core/init_config/initalization_config.dart';
import 'core/utils/restart_app_class.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/config/app_config.dart';
import 'core/firebase/firestore_paths.dart';

void main() async {
  usePathUrlStrategy();
  await initializationClass();

  try {
    debugPrint('Seeding admin role...');
    await FirebaseFirestore.instance
        .doc(FirestorePaths.member(AppConfig.ownerId))
        .set({'role': 'admin'}, SetOptions(merge: true));
    debugPrint('Admin role seeded successfully!');
  } catch (e) {
    debugPrint('Error seeding admin role: $e');
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar')],
      path: 'assets/lang',
      saveLocale: false,
      startLocale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      child: HotRestartController(
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (ctx, child) {
            return const MyApp();
          },
        ),
      ),
    ),
  );
}
