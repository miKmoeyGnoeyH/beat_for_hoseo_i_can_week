import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../shared/index.dart';

class NoticeBody extends StatelessWidget {
  const NoticeBody(this.noticeBody, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: BEATShadowContainer(
        width: double.infinity,
        contentPadding: EdgeInsetsGeometry.all(16.w),
        shadowBlurRadius: 20.w,
        shadowSpreadRadius: -15.w,
        child: Text(
          noticeBody,
          style: AppTextTheme.body1,
        ),
      ),
    );
  }

  final String noticeBody;
}
