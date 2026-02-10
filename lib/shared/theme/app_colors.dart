import 'package:flutter/material.dart';

/// 앱에서 전역적으로 사용되는 색상들을 관리하는 클래스입니다.
///
/// 모든 색상은 정적으로 정의되어 앱에서 전역적으로 접근할 수 있습니다.
///
/// 해당 클래스는 추상 클래스로 선언이 되어 있는데, 이는 클래스가 인스턴스화되는 것을 막아 불필요한 메모리 사용을 최소화하기 위함입니다.
/// 정적 getter를 통해 필요할 때만 객체를 생성하고 할당하는 방식도 가능하지만,
/// 앱이 시작될 때 미리 객체를 정적으로 생성해놓는 것보다 필요할 때마다 메소드를 호출해 새로운 객체를 생성하는 것이 더 나은지는 확실히 모르겠습니다.
abstract class AppColors {
  // Primary
  static const Color primary = Color(0xff3A4CE0);

  // Design
  static const Color designWhite = Color(0xfff0f2f5);
  static const Color designBlack = Color(0xff1a1a1a);

  // Status
  static const Color statusComplete = Color(0xff2eaf0a);
  static const Color statusCompleteBackground = Color(0xffeef9eb);
  static const Color statusWarning = Color(0xffff8416);
  static const Color statusWarningBackground = Color(0xfffff5ec);
  static const Color statusError = Color(0xfff23d3d);
  static const Color statusErrorBackground = Color(0xfffeefef);

  // Border
  static const Color borderLight = Color(0xff76899c);
  static const Color borderDark = Color(0xff333333);
  static const Color highContrastBorderLight = Color(0xff000000);
  static const Color highContrastBorderDark = Color(0xff9f9f9f);

  static const Color disabledColorLight = Color(0xffd0d7de);
  static const Color disabledBorderColorLight = Color(0xfff5f8fb);
  static const Color disabledTextColorLight = Color(0xff76899c);

  // Skeleton
  static const Color skeletonOnPrimary = Color(0x4d3a4ce0);

  // Common
  /// [commonWhite]: 완전한 흰색입니다. 사용하지 마세요
  /// 대신 `designWhite`를 사용하세요.
  static const Color commonWhite = Color(0xffffffff);
  /// [commonBlack]: 완전한 검은색입니다. 사용하지 마세요
  /// 대신 `designBlack`를 사용하세요.
  static const Color commonBlack = Color(0x00000000);
  static const Color common800 = Color(0xff333333);
  static const Color common500 = Color(0xff76899c);
  static const Color common400 = Color(0xffb0becc);
  static const Color common300 = Color(0xffd0d7de);
  static const Color common200 = Color(0xffe6edf1);
  static const Color common100 = Color(0xfff5f8fb);
}

/// [MaterialApp], [GetMaterialApp]의 [theme]을 위해 [ThemeData]를 생성해야 하는데,
/// [ThemeData]의 [primarySwatch]는 [MaterialColor] 타입이어야 하기 때문에, 이를 생성해주는 메소드입니다..
MaterialColor createMaterialColor({required Color toColor, required Color fromColor, bool isSwatch50 = true}) {
  List<double> strengths = [if (isSwatch50) .05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
  Map<int, Color> swatch = <int, Color>{};

  for (var strength in strengths) {
    swatch[(strength * 1000).round()] = Color.lerp(toColor, fromColor, strength)!;
  }
  return MaterialColor(fromColor.value, swatch);
}