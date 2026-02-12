import 'package:beat/shared/index.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../entities/quest/index.dart';

class QRCard extends StatelessWidget {
  const QRCard({super.key, required this.qrMissionItemAppDto});

  @override
  Widget build(BuildContext context) {
    final double rowSpacing = 10.w;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 0.5.w, color: AppColors.common300),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsetsGeometry.symmetric(horizontal: 10.w, vertical: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(qrMissionItemAppDto.name, style: AppTextTheme.subtitle1),
              if (qrMissionItemAppDto.completed == true)
                BeatStatusGood(
                  text: LocalizationService.instance.questDetailQuestCompleted,
                ),
            ],
          ),
          SizedBox(height: rowSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocalizationService.instance.questDetailLocation,
                style: AppTextTheme.body1,
              ),
              Text(qrMissionItemAppDto.location, style: AppTextTheme.body1),
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
                  Image.asset(BEATAssets.images.greenCampusPoint, width: 20.w),
                  SizedBox(width: 5.w),
                  Text(
                    NumberFormat(
                      "###,###,###,###",
                    ).format(qrMissionItemAppDto.rewardPoint),
                    style: AppTextTheme.body1,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  final QRMissionItemAppDto qrMissionItemAppDto;
}
