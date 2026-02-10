import 'dart:developer';

import 'package:beat/features/step_count/index.dart';
import 'package:beat/shared/index.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class StepCountCard extends StatelessWidget {
  StepCountCard({super.key});

  final StepCountController stepCountController = StepCountController.to;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          onTap: () {
            log("onTap");
          },
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
                    // TODO: 권한 상태에 따라 권한이 없다면 권한을 요청하는 UI를 출력해야함. 권한 확인은 상위의 home에서 처리하는데, 권한 상태 변경을 어떻게 감지할 것인지?
                    Obx(() {
                      return Text(
                        NumberFormat(
                          "###,###,###,###",
                        ).format(stepCountController.stepCount),
                        style: AppTextTheme.headline1.designWhite,
                      );
                    }),
                    // Text(
                    //   LocalizationService.instance.homeMonthlyWalkCount(
                    //     NumberFormat("###,###,###,###").format(1000),
                    //   ),
                    //   style: AppTextTheme.subtitle1.designWhite,
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
