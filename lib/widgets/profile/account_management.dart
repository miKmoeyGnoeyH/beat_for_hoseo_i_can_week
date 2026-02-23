import 'package:beat/features/authentication/authentication_controller.dart';
import 'package:beat/features/profile/index.dart';
import 'package:beat/features/step_count/index.dart';
import 'package:beat/shared/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../app/route/index.dart';

class AccountManagement extends StatelessWidget {
  AccountManagement({super.key});

  final ProfileController profileController = ProfileController.to;

  void onChangePasswordTap() {
    Get.toNamed(BEATRoute.changePassword);
  }

  void onSignOutTap() async {
    await StepCountController.to.stopService();
    AuthenticationController.to.SignOut();
    Get.offAndToNamed(BEATRoute.signIn);
  }

  void onWithdrawalTap() {
    Get.toNamed(BEATRoute.withdrawal);
  }

  @override
  Widget build(BuildContext context) {
    final double rowSpacing = 16.w;

    return BEATShadowContainer(
      contentPadding: EdgeInsetsGeometry.all(16.w),
      shadowBlurRadius: 30.w,
      shadowSpreadRadius: -17.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocalizationService.instance.profileAccountManagement,
            style: AppTextTheme.subtitle1,
          ),
          SizedBox(height: rowSpacing),
          GestureDetector(
            onTap: onChangePasswordTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  LocalizationService.instance.profileChangePassword,
                  style: AppTextTheme.body1,
                ),
                SvgPicture.asset(
                  BEATAssets.svg.rightArrow,
                  width: 12.w,
                  colorFilter: ColorFilter.mode(
                    AppColors.common300,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: rowSpacing),
          GestureDetector(
            onTap: onSignOutTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  LocalizationService.instance.profileSignOut,
                  style: AppTextTheme.body1,
                ),
                SvgPicture.asset(
                  BEATAssets.svg.rightArrow,
                  width: 12.w,
                  colorFilter: ColorFilter.mode(
                    AppColors.common300,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: rowSpacing),
          GestureDetector(
            onTap: onWithdrawalTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  LocalizationService.instance.profileWithdrawal,
                  style: AppTextTheme.body1,
                ),
                SvgPicture.asset(
                  BEATAssets.svg.rightArrow,
                  width: 12.w,
                  colorFilter: ColorFilter.mode(
                    AppColors.common300,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
