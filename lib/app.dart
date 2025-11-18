import 'package:beat/app/route/app_pages.dart';
import 'package:beat/shared/index.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
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
          transitionDuration: const Duration(milliseconds: 200),
          popGesture: true,
          getPages: BEATPages.pages,
          initialRoute: BEATRoute.init,
          // Theme
          theme: appLightTheme(),
          // darkTheme: appDarkTheme(),
        );
      },
    );
  }
}
