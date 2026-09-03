import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app.dart';
import 'core/init_config/initalization_config.dart';
import 'core/utils/restart_app_class.dart';

import 'core/config/app_flavor.dart';

void main() async {
  usePathUrlStrategy();
  await initializationClass(AppFlavor.user);
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
            return const MyApp(flavor: AppFlavor.user);
          },
        ),
      ),
    ),
  );
}
