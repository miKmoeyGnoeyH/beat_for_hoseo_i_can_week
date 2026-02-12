import 'package:beat/entities/quest/index.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../shared/index.dart';

class QuestInfo extends StatelessWidget {
  const QuestInfo({super.key, required this.questDetailCommonAppDto});

  @override
  Widget build(BuildContext context) {
    final double rowSpacing = 16.w;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: BEATShadowContainer(
        width: double.infinity,
        contentPadding: EdgeInsetsGeometry.all(16.w),
        shadowBlurRadius: 20.w,
        shadowSpreadRadius: -15.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.questDetailQuestInfo,
              style: AppTextTheme.title1,
            ),
            SizedBox(height: 16.w),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  LocalizationService.instance.questDetailTotalReward,
                  style: AppTextTheme.body1,
                ),
                Row(
                  children: [
                    Image.asset(BEATAssets.images.greenCampusPoint, width: 20.w),
                    SizedBox(width: 5.w),
                    Text(
                      NumberFormat(
                        "###,###,###,###",
                      ).format(questDetailCommonAppDto.totalPoint),
                      style: AppTextTheme.body1,
                    ),
                  ],
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
                  LocalizationService.instance.questDetailQuestType,
                  style: AppTextTheme.body1,
                ),
                Text(
                  LocalizationService.instance.questType(questDetailCommonAppDto.questType.value),
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
                  LocalizationService.instance.questDetailStartDate,
                  style: AppTextTheme.body1,
                ),
                Text(
                  questDetailCommonAppDto.startDate,

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
                  LocalizationService.instance.questDetailEndDate,
                  style: AppTextTheme.body1,
                ),
                Text(
                  questDetailCommonAppDto.endDate,
                  style: AppTextTheme.body1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  final QuestDetailCommonAppDto questDetailCommonAppDto;
}
