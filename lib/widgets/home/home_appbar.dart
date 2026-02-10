import 'dart:developer';

import 'package:beat/features/authentication/authentication_controller.dart';
import 'package:beat/shared/theme/index.dart';
import 'package:beat/shared/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'index.dart';

class HomeAppbar extends StatelessWidget {
  const HomeAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.designWhite,
      toolbarHeight: 56.w,
      leadingWidth: 200.w,
      actionsPadding: EdgeInsets.symmetric(horizontal: 16.w),
      shape: Border(
        bottom: BorderSide(width: 0.5, color: AppColors.disabledColorLight),
      ),
      leading: Row(
        children: [
          SizedBox(width: 16.w),
          SvgPicture.asset(
            BEATAssets.svg.greenCampusLogoType3,
            colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
            width: 28.w,
            height: 28.w,
          ),
          SizedBox(width: 10.w),
          Text(
            AuthenticationController.to.state?.nickname ?? '',
            style: AppTextTheme.body1,
          ),
        ],
      ),
      actions: [
        HomeAppbarIconButton(
          onTap: onLeaderboardTap,
          icon: SvgPicture.asset(
            BEATAssets.svg.leaderboard,
            width: 28.w,
            height: 28.w,
          ),
        ),
        HomeAppbarIconButton(
          onTap: onNotificationTap,
          icon: SvgPicture.asset(
            BEATAssets.svg.notification,
            width: 28.w,
            height: 28.w,
          ),
        ),
        HomeAppbarIconButton(
          onTap: onSettingsTap,
          icon: SvgPicture.asset(
            BEATAssets.svg.settings,
            width: 24.w,
            height: 24.w,
          ),
        ),
      ],
    );
  }

  void onLeaderboardTap() {
    log("home.dart: appbar: leaderboard tapped");
  }

  void onNotificationTap() {
    log("home.dart: appbar: notification tapped");
  }

  void onSettingsTap() {
    log("home.dart: appbar: settings tapped");
  }
}
