import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../entities/quest/index.dart';
import '../../shared/index.dart';
import 'qr_card.dart';

class QRInfo extends StatelessWidget {
  const QRInfo({super.key, required this.qrMissionItemAppDtoList});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: BEATShadowContainer(
        contentPadding: EdgeInsetsGeometry.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.instance.questType(QuestType.qr.value),
              style: AppTextTheme.title1,
            ),
            SizedBox(height: 16.w),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final QRMissionItemAppDto item = qrMissionItemAppDtoList[index];
                return QRCard(qrMissionItemAppDto: item);
              },
              separatorBuilder: (context, index) => SizedBox(height: 5.w),
              itemCount: qrMissionItemAppDtoList.length,
            ),
          ],
        ),
      ),
    );
  }

  final List<QRMissionItemAppDto> qrMissionItemAppDtoList;
}
