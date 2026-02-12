import 'package:beat/entities/quest/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../shared/index.dart';

class QuestDescription extends StatelessWidget {
  const QuestDescription({super.key, required this.questDetailCommonAppDto});

  @override
  Widget build(BuildContext context) {
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
              LocalizationService.instance.questDetailQuestDescription,
              style: AppTextTheme.title1,
            ),
            SizedBox(height: 16.w),
            Text(
              questDetailCommonAppDto.descriptionLong,
              style: AppTextTheme.body1,
            ),
          ],
        ),
      ),
    );
  }

  final QuestDetailCommonAppDto questDetailCommonAppDto;
}
