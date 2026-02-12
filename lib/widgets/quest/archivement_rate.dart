import 'package:beat/shared/index.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ArchivementRate extends StatelessWidget {
  const ArchivementRate({
    super.key,
    required this.totalPoints,
    required this.totalCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.commonWhite,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.homeArchivementRate,
              style: AppTextTheme.subtitle2.common500,
            ),
            SizedBox(height: 10.w),
            Column(
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: LinearProgressIndicator(
                    value: completedCount / totalCount,
                    color: AppColors.common100,
                    backgroundColor: AppColors.common100,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 25.w,
                    semanticsLabel: 'semanticsLabel',
                    semanticsValue: 'semanticsValue',
                  ),
                ),
                SizedBox(height: 5.w),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LocalizationService.instance.homeNumber("0"),
                      style: AppTextTheme.caption1.common400,
                    ),
                    Text(
                      LocalizationService.instance.homeNumber("$totalCount"),
                      style: AppTextTheme.caption1.common400,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.w),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocalizationService.instance.homeTotalPoints,
                  style: AppTextTheme.body2.common400,
                ),
                Text(
                  LocalizationService.instance.homePoints(
                    NumberFormat("###,###,###").format(totalPoints),
                  ),
                  style: AppTextTheme.body2.primary,
                ),
              ],
            ),
            SizedBox(height: 10.w),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocalizationService.instance.homeBingoSquareLeft,
                  style: AppTextTheme.body2.common400,
                ),
                Text(
                  LocalizationService.instance.homeSquareLeft(
                    NumberFormat(
                      "###,###,###",
                    ).format(totalCount - completedCount),
                  ),
                  style: AppTextTheme.body2.common400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  final int totalPoints;
  final int totalCount;
  final int completedCount;
}
