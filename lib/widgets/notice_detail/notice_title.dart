import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../shared/index.dart';

class NoticeTitle extends StatelessWidget {
  const NoticeTitle(this.title, this.createdAt, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: BEATShadowContainer(
        width: double.infinity,
        shadowBlurRadius: 30.w,
        shadowSpreadRadius: -20.w,
        contentPadding: EdgeInsetsGeometry.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextTheme.title1,
            ),
            SizedBox(height: 5.w),
            Text(
              DateFormat("yyyy.MM.dd HH:mm").format(createdAt),
              style: AppTextTheme.body2.common300,
            ),
          ],
        ),
      ),
    );
  }

  final String title;
  final DateTime createdAt;
}
