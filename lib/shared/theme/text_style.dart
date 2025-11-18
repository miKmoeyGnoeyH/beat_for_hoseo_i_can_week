import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppTextTheme {
  static const String _fontFamily = 'Pretendard';

  static TextStyle headline1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.25,
    // height: 1.4,
  );

  static TextStyle title1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    // height: 1.4,
  );

  static TextStyle subtitle1 = TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
      // height: 1.4,
  );

  static TextStyle subtitle2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    // height: 1.4,
  );

  static TextStyle body1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    // height: 1.4,
  );

  static TextStyle body2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    // height: 1.4,
  );

  static TextStyle caption1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13.sp,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    // height: 1.4,
  );
}
