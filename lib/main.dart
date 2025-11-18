import 'package:beat/shared/index.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalizationService.instance.init();
  await PrefsService.instance.init();
  await DotEnvService.instance.init();

  Get.put<DialogService>(DialogService(), permanent: true);
  Get.put<ExceptionService>(ExceptionService(), permanent: true);

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
      ],
      fallbackLocale: const Locale('en'),
      path: 'assets/translations',
      child: App(),
    ),
  );
}