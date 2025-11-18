import 'package:flutter/material.dart';
import 'package:beat/shared/theme/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BEATSliverAppBar extends StatelessWidget {
  const BEATSliverAppBar({super.key, this.title = ""});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leadingWidth: (20.w + 24.w),
      leading: Padding(
        padding: EdgeInsets.only(left: 20.w),
        child: SvgPicture.asset(
          "assets/svg/beat_logo_2.svg",
          width: 24.w,
          height: 24.w,
        ),
      ),
      title: Text(title, style: AppTextTheme.body2),
      actions: [
        // TODO: 각 아이콘들 대응되는 페이지로 이동하는 버튼으로 변경
        Icon(Icons.leaderboard_outlined, size: 24.w),
        SizedBox(width: 8.w),
        Icon(Icons.info_outline_rounded, size: 24.w),
        SizedBox(width: 8.w),
        Icon(Icons.notifications_outlined, size: 24.w),
        SizedBox(width: 8.w),
        Padding(
          padding: EdgeInsets.only(right: 20.w),
          child: Icon(Icons.settings_outlined, size: 24.w),
        ),
      ],
    );
  }

  final String title;
}
