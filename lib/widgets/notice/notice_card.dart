import 'package:beat/entities/notice/index.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../shared/index.dart';

class NoticeCard extends StatelessWidget {
  const NoticeCard(this.notice, {super.key});

  @override
  Widget build(BuildContext context) {
    return BEATShadowContainer(
      contentPadding: EdgeInsetsGeometry.all(16.w),
      shadowBlurRadius: 30.w,
      shadowSpreadRadius: -20.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notice.title,
            style: AppTextTheme.subtitle1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 10.w),
          Text(
            DateFormat("yyyy.MM.dd HH:mm").format(notice.createdAt),
            style: AppTextTheme.body2.common300,
          ),
        ],
      ),
    );
  }

  final NoticeModel notice;
}
