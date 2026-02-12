import 'package:beat/entities/quest/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../shared/index.dart';

class QuestName extends StatelessWidget {
  const QuestName({
    super.key,
    required this.questDetailCommonAppDto,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: BEATShadowContainer(
        width: double.infinity,
        shadowBlurRadius: 30.w,
        shadowSpreadRadius: -20.w,
        contentPadding: EdgeInsetsGeometry.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService
                  .instance
                  .questDetailQuestName,
              style: AppTextTheme.title1,
            ),
            SizedBox(height: 16.w),
            Text(
              questDetailCommonAppDto.name,
              style: AppTextTheme.body1,
            ),
          ],
        ),
      ),
    );
  }

  final QuestDetailCommonAppDto questDetailCommonAppDto;
}