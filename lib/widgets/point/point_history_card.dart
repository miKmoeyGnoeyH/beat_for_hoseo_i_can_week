import 'package:beat/entities/point/index.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../shared/index.dart';

class PointHistoryCard extends StatelessWidget {
  const PointHistoryCard(this.pointHistoryModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return BEATShadowContainer(
      contentPadding: EdgeInsetsGeometry.all(16.w),
      shadowBlurRadius: 30.w,
      shadowSpreadRadius: -20.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pointHistoryModel.historyName,
                style: AppTextTheme.subtitle1,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              SizedBox(height: 10.w),
              Text(
                DateFormat(
                  "yyyy.MM.dd HH:mm",
                ).format(pointHistoryModel.checkTime),
                style: AppTextTheme.body2.common300,
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                BEATAssets.images.greenCampusPoint,
                width: 30.w,
              ),
              SizedBox(height: 5.w),
              Text(
                NumberFormat(
                  "+###,###;-###,###",
                ).format(pointHistoryModel.point),
                style: (pointHistoryModel.point >= 0)
                    ? AppTextTheme.subtitle2.statusError
                    : AppTextTheme.subtitle2.statusError,
              ),
            ],
          ),
        ],
      ),
    );
  }

  final PointHistoryModel pointHistoryModel;
}
