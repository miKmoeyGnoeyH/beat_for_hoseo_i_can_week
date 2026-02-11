import 'package:beat/app/route/app_pages.dart';
import 'package:beat/pages/init/index.dart';
import 'package:beat/shared/index.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await PrefsService.instance.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return GetMaterialApp(
          // General
          title: "BEAT",
          debugShowCheckedModeBanner: false,
          // Localization
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          // Navigation
          defaultTransition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 100),
          popGesture: true,
          getPages: BEATPages.pages,
          initialRoute: BEATRoute.splash,
          initialBinding: AppBinding(),
          // Theme
          theme: appLightTheme(),
          // darkTheme: appDarkTheme(),
          builder: (context, child) {
            return Init(child: child ?? const SizedBox());
          },
        );
      },
    );
  }
}
