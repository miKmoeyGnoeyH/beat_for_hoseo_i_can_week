
import 'package:beat/app/route/app_pages.dart';
import 'package:beat/features/point/index.dart';
import 'package:beat/shared/index.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PointCard extends StatelessWidget {
  PointCard({super.key});

  final PointController pointController = PointController.to;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 15.w,
            spreadRadius: -10.w,
            color: AppColors.common300
          )
        ]
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Get.toNamed(BEATRoute.pointHistory);
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
                  child: Image.asset(BEATAssets.images.greenCampusPoints),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationService.instance.homePointsBalance,
                      style: AppTextTheme.subtitle1.designWhite,
                    ),
                    pointController.obx(
                      (state) {
                        return Text(
                          NumberFormat("###,###,###,###").format(state!),
                          style: AppTextTheme.headline1.designWhite,
                        );
                      },
                      onEmpty: Text(
                        NumberFormat("###,###,###,###").format(000),
                        style: AppTextTheme.headline1.designWhite,
                      ),
                      onLoading: Text(
                        NumberFormat("###,###,###,###").format(pointController.state ?? 000),
                        style: AppTextTheme.headline1.designWhite,
                      ),
                      // TODO: onError 추가
                    ),
                    Text(
                      LocalizationService.instance.homeTapToCheckYourHistory,
                      style: AppTextTheme.subtitle2.common300,
                    ),
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
