import 'package:beat/app/route/app_pages.dart';
import 'package:beat/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/index.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  void onOssLicencesTap() {
    Get.toNamed(BEATRoute.ossLicenses);
  }

  Future<void> onPrivacyPolicyTap() async {
    await launchUrl(Uri.parse(DotEnvService.instance.privacyPolicy));
  }

  @override
  Widget build(BuildContext context) {
    final double rowSpacing = 16.w;

    return Scaffold(
      backgroundColor: AppColors.designWhite,
      body: SafeArea(
        top: false,
        child: NestedScrollView(
          physics: NeverScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              BEATSliverBackAppBar(
                title: LocalizationService.instance.settingsSettings,
              ),
            ];
          },
          body: Column(
            children: [
              SizedBox(height: 16.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationService.instance.profileAccountManagement,
                      style: AppTextTheme.subtitle1,
                    ),
                    SizedBox(height: 10.w),
                    AccountManagement(),
                  ],
                ),
              ),
              SizedBox(height: rowSpacing),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationService.instance.settingsAppInfo,
                      style: AppTextTheme.subtitle1,
                    ),
                    SizedBox(height: 10.w),
                    BEATShadowContainer(
                      shadowBlurRadius: 25.w,
                      shadowSpreadRadius: -20.w,
                      contentPadding: EdgeInsetsGeometry.all(16.w),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                LocalizationService.instance.settingsVersion,
                                style: AppTextTheme.body1,
                              ),
                              Text(
                                "${PackageInfoService.instance.version}(${PackageInfoService.instance.buildNumber})",
                                style: AppTextTheme.body1,
                              ),
                            ],
                          ),
                          SizedBox(height: rowSpacing),
                          GestureDetector(
                            onTap: onOssLicencesTap,
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  LocalizationService
                                      .instance
                                      .settingsOssLicenses,
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
                            onTap: onPrivacyPolicyTap,
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  LocalizationService
                                      .instance
                                      .settingsPrivacyPolicy,
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
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationService.instance.settingsAppInquiry,
                      style: AppTextTheme.subtitle1,
                    ),
                    SizedBox(height: 10.w),
                    BEATShadowContainer(
                      shadowBlurRadius: 25.w,
                      shadowSpreadRadius: -20.w,
                      contentPadding: EdgeInsetsGeometry.all(16.w),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                LocalizationService.instance.settingsEmail,
                                style: AppTextTheme.body1,
                              ),
                              Text(
                                LocalizationService
                                    .instance
                                    .settingsEmailAddress,
                                style: AppTextTheme.body1,
                              ),
                            ],
                          ),
                          SizedBox(height: rowSpacing),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                LocalizationService.instance.settingsPhone,
                                style: AppTextTheme.body1,
                              ),
                              Text(
                                LocalizationService
                                    .instance
                                    .settingsPhoneNumber,
                                style: AppTextTheme.body1,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
