import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../entities/quest/index.dart';
import '../../shared/index.dart';

class WalkInfo extends StatelessWidget {
  const WalkInfo({super.key, required this.walkMissionAppDto});

  @override
  Widget build(BuildContext context) {
    final double rowSpacing = 10.w;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: BEATShadowContainer(
        width: double.infinity,
        contentPadding: EdgeInsetsGeometry.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocalizationService.instance.questType(QuestType.walk.value),
                  style: AppTextTheme.title1,
                ),
                if (walkMissionAppDto.completed == true)
                  BeatStatusGood(
                    text:
                        LocalizationService.instance.questDetailQuestCompleted,
                  ),
              ],
            ),
            SizedBox(height: 16.w),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocalizationService.instance.questDetailWalkRequirement,
                  style: AppTextTheme.body1,
                ),
                Text(
                  NumberFormat(
                    "###,###,###,###",
                  ).format(walkMissionAppDto.conditionRequirement),
                  style: AppTextTheme.body1,
                ),
              ],
            ),
            SizedBox(height: rowSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocalizationService.instance.questDetailRewardPoints,
                  style: AppTextTheme.body1,
                ),
                Row(
                  children: [
                    Image.asset(
                      BEATAssets.images.greenCampusPoint,
                      width: 20.w,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      NumberFormat(
                        "###,###,###,###",
                      ).format(walkMissionAppDto.conditionRewardPoint),
                      style: AppTextTheme.body1,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  final WalkMissionAppDto walkMissionAppDto;
}
