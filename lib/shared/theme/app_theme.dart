import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

import 'index.dart';

ThemeData appLightTheme() => ThemeData(
  useMaterial3: false,

  primarySwatch: createMaterialColor(
    fromColor: AppColors.primary,
    toColor: Colors.black,
  ),
  scaffoldBackgroundColor: AppColors.designWhite,
  canvasColor: AppColors.designWhite,
  dividerColor: AppColors.common100,

  colorScheme: const ColorScheme(
    primary: AppColors.designWhite,
    onPrimary: AppColors.designBlack,
    secondary: AppColors.primary,
    onSecondary: AppColors.designWhite,
    surface: AppColors.designWhite,
    onSurface: AppColors.designBlack,
    error: AppColors.statusError,
    onError: AppColors.designWhite,
    brightness: Brightness.light,
    shadow: AppColors.designBlack,
  ),

  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: AppColors.designBlack,
    displayColor: AppColors.designBlack,
    decorationColor: AppColors.designBlack,
  ),

  /// 텍스트필드 선택 시 색상입니다.
  /// [cursorColor]: 커서 색상입니다.
  /// [selectionColor]: 드래그로 선택된 텍스트 배경 색상입니다.
  /// [selectionHandleColor]: 선택 핸들 색상입니다.
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: AppColors.primary,
    selectionColor: AppColors.primary,
    selectionHandleColor: AppColors.primary,
  ),

  inputDecorationTheme: InputDecorationTheme(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 12.5.h),
    labelStyle: AppTextTheme.caption1,
    hintStyle: AppTextTheme.caption1,
    errorStyle: AppTextTheme.body2,
    enabledBorder: UnderlineInputBorder(
      borderSide: const BorderSide(color: AppColors.common300, width: 1),
    ),
    disabledBorder: UnderlineInputBorder(
      borderSide: const BorderSide(color: AppColors.common100, width: 1),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: const BorderSide(color: AppColors.primary, width: 1),
    ),
    errorBorder: UnderlineInputBorder(
      borderSide: const BorderSide(color: AppColors.statusError, width: 1),
    ),
    focusedErrorBorder: UnderlineInputBorder(
      borderSide: const BorderSide(color: AppColors.statusError, width: 1),
    ),
  ),

  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.designWhite,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
    titleTextStyle: AppTextTheme.subtitle1,
    contentTextStyle: AppTextTheme.body2,
    elevation: 8,
  ),

  unselectedWidgetColor: AppColors.common100,
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return null;
    }),
  ),

  sliderTheme: SliderThemeData(
    trackHeight: 13.h,
    activeTrackColor: AppColors.primary,
    activeTickMarkColor: AppColors.primary,
    inactiveTrackColor: AppColors.common100,
    inactiveTickMarkColor: AppColors.common300,
    thumbColor: AppColors.primary,
    disabledThumbColor: AppColors.common400,
    thumbShape: RoundSliderThumbShape(
      enabledThumbRadius: 13.r,
      elevation: 0,
      pressedElevation: 0,
    ),
    overlayColor: Colors.transparent,
    trackShape: CustomTrackShape(),
    tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 2.5.r),
    overlayShape: SliderComponentShape.noThumb,
  ),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    backgroundColor: AppColors.designWhite,
    selectedLabelStyle: AppTextTheme.caption1,
    unselectedLabelStyle: AppTextTheme.caption1,
    showSelectedLabels: true,
    showUnselectedLabels: true,
    selectedItemColor: AppColors.designBlack,
    unselectedItemColor: AppColors.common500,
  ),

  fontFamily: "Pretendard",
);

/// Dark Theme
ThemeData appDarkTheme() => ThemeData(
  useMaterial3: false,

  primarySwatch: createMaterialColor(
    fromColor: AppColors.primary,
    toColor: Colors.black,
  ),

  scaffoldBackgroundColor: AppColors.designBlack,
  canvasColor: AppColors.designWhite,
  dividerColor: AppColors.common100,

  colorScheme: const ColorScheme(
    primary: AppColors.designBlack,
    onPrimary: AppColors.designWhite,
    secondary: AppColors.primary,
    onSecondary: AppColors.designWhite,
    surface: AppColors.designBlack,
    onSurface: AppColors.designWhite,
    error: AppColors.statusError,
    onError: AppColors.designWhite,
    brightness: Brightness.dark,
    shadow: AppColors.designBlack,
  ),

  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: AppColors.designWhite,
    displayColor: AppColors.designWhite,
    decorationColor: AppColors.designWhite,
  ),

  /// 텍스트필드 선택 시 색상입니다.
  /// [cursorColor]: 커서 색상입니다.
  /// [selectionColor]: 드래그로 선택된 텍스트 배경 색상입니다.
  /// [selectionHandleColor]: 선택 핸들 색상입니다.
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: AppColors.primary,
    selectionColor: AppColors.primary,
    selectionHandleColor: AppColors.primary,
  ),

  inputDecorationTheme: InputDecorationTheme(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(vertical: 12.w),
    labelStyle: AppTextTheme.caption1,
    hintStyle: AppTextTheme.caption1,
    errorStyle: AppTextTheme.body2,
    enabledBorder: UnderlineInputBorder(
      borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
    ),
    disabledBorder: UnderlineInputBorder(
      borderSide: const BorderSide(color: AppColors.common100, width: 1),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: const BorderSide(color: AppColors.primary, width: 1),
    ),
    errorBorder: UnderlineInputBorder(
      borderSide: const BorderSide(color: AppColors.statusError, width: 1),
    ),
    focusedErrorBorder: UnderlineInputBorder(
      borderSide: const BorderSide(color: AppColors.statusError, width: 1),
    ),
  ),

  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.designBlack,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
    titleTextStyle: AppTextTheme.subtitle1,
    contentTextStyle: AppTextTheme.body2,
    elevation: 8,
  ),

  unselectedWidgetColor: AppColors.common100,
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return null;
    }),
  ),

  sliderTheme: SliderThemeData(
    trackHeight: 13.h,
    activeTrackColor: AppColors.primary,
    activeTickMarkColor: AppColors.primary,
    inactiveTrackColor: AppColors.common100,
    inactiveTickMarkColor: AppColors.common300,
    thumbColor: AppColors.primary,
    disabledThumbColor: AppColors.common400,
    thumbShape: RoundSliderThumbShape(
      enabledThumbRadius: 13.r,
      elevation: 0,
      pressedElevation: 0,
    ),
    overlayColor: Colors.transparent,
    trackShape: CustomTrackShape(),
    tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 2.5.r),
    overlayShape: SliderComponentShape.noThumb,
  ),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    backgroundColor: AppColors.designWhite,
    selectedLabelStyle: AppTextTheme.caption1,
    unselectedLabelStyle: AppTextTheme.caption1,
    showSelectedLabels: true,
    showUnselectedLabels: true,
    selectedItemColor: AppColors.designBlack,
    unselectedItemColor: AppColors.common500,
  ),

  fontFamily: "Pretendard",
);

/// Custom Track Shape for Slider
class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double thumbWidth = sliderTheme.thumbShape!
        .getPreferredSize(isEnabled, isDiscrete)
        .width;
    final double overlayWidth = sliderTheme.overlayShape!
        .getPreferredSize(isEnabled, isDiscrete)
        .width;
    final double trackHeight = sliderTheme.trackHeight!;
    assert(overlayWidth >= 0);
    assert(trackHeight >= 0);

    final double trackLeft = offset.dx + thumbWidth / 2;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackRight = trackLeft + parentBox.size.width - thumbWidth;
    final double trackBottom = trackTop + trackHeight;
    return Rect.fromLTRB(
      math.min(trackLeft, trackRight),
      trackTop,
      math.max(trackLeft, trackRight),
      trackBottom,
    );
  }
}