import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:beat/features/step_count/index.dart';
import 'package:beat/shared/index.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class StepCountCard extends StatefulWidget {
  const StepCountCard({super.key});

  @override
  State<StepCountCard> createState() => _StepCountCardState();
}

class _StepCountCardState extends State<StepCountCard> {
  final StepCountController stepCountController = StepCountController.to;
  Timer? _permissionCheckTimer;
  bool _isLocationPermissionGranted = false;
  bool _isActivityPermissionGranted = false;

  void startPermissionCheckTimer() {
    _permissionCheckTimer?.cancel();
    _permissionCheckTimer = Timer.periodic(Duration(seconds: 10), (
      timer,
    ) async {
      try {
        final locationStatus = Platform.isIOS
            ? await PermissionService.instance
                  .isLocationWhenInUsePermissionGranted()
            : await PermissionService.instance
                  .isLocationAlwaysPermissionGranted();
        final activityStatus = await PermissionService.instance
            .isActivityPermissionGranted();

        // log(locationStatus.toString());
        // log(activityStatus.toString());

        setState(() {
          _isLocationPermissionGranted = locationStatus;
          _isActivityPermissionGranted = activityStatus;
        });
      } catch (e) {
        log("Error checking permissions: $e");
      }
    });
  }

  void stopPermissionCheckTimer() {
    _permissionCheckTimer?.cancel();
    _permissionCheckTimer = null;
  }

  Future<void> initStepCountCard() async {
    final locationStatus = Platform.isIOS
        ? await PermissionService.instance
              .isLocationWhenInUsePermissionGranted()
        : await PermissionService.instance.isLocationAlwaysPermissionGranted();
    final activityStatus = await PermissionService.instance
        .isActivityPermissionGranted();

    setState(() {
      _isLocationPermissionGranted = locationStatus;
      _isActivityPermissionGranted = activityStatus;
    });

    startPermissionCheckTimer();
  }

  @override
  void initState() {
    super.initState();
    initStepCountCard();
  }

  @override
  void dispose() {
    stopPermissionCheckTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 15.w,
                spreadRadius: -10.w,
                color: AppColors.common500,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {},
              highlightColor: AppColors.disabledColorLight,
              splashColor: AppColors.disabledColorLight,
              child: Ink(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(color: AppColors.primary),
                child: Stack(
                  children: [
                    Positioned(
                      height: 86.w,
                      right: 0,
                      child: SvgPicture.asset(
                        BEATAssets.svg.footprint,
                        colorFilter: ColorFilter.mode(
                          AppColors.designWhite,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocalizationService.instance.homeTodaysWalkCount,
                          style: AppTextTheme.subtitle1.designWhite,
                        ),
                        Obx(() {
                          return Text(
                            NumberFormat(
                              "###,###,###,###",
                            ).format(stepCountController.stepCount),
                            style: AppTextTheme.headline1.designWhite,
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Obx(() {
          if (!stepCountController.isInCampus) {
            return Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoSizeText(
                      LocalizationService.instance.homeNotInCampus,
                      style: AppTextTheme.subtitle1.designWhite,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            );
          } else if (!_isActivityPermissionGranted) {
            return Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoSizeText(
                      LocalizationService
                          .instance
                          .generalRequiresActivityPermissionTitle,
                      style: AppTextTheme.subtitle1.designWhite,
                      maxLines: 1,
                    ),
                    SizedBox(height: 10.w),
                    SizedBox(
                      width: 150.w,
                      height: 40.w,
                      child: BEATTextButton(
                        contentPadding: EdgeInsets.zero,
                        text: LocalizationService.instance.generalGoToSettings,
                        onTap: () => AppSettings.openAppSettings(
                          type: AppSettingsType.settings,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (!_isLocationPermissionGranted) {
            return Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoSizeText(
                      LocalizationService
                          .instance
                          .generalPleaseAllowAlwaysLocation,
                      style: AppTextTheme.subtitle1.designWhite,
                      maxLines: 1,
                    ),
                    SizedBox(height: 10.w),
                    SizedBox(
                      width: 150.w,
                      height: 40.w,
                      child: BEATTextButton(
                        contentPadding: EdgeInsets.zero,
                        text: LocalizationService.instance.generalGoToSettings,
                        onTap: () => AppSettings.openAppSettings(
                          type: AppSettingsType.settings,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        }),
      ],
    );
  }
}
