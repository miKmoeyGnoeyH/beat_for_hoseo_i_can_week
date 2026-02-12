import 'package:beat/shared/index.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../entities/quest/index.dart';

class BingoStep extends StatelessWidget {
  const BingoStep({
    super.key,
    required this.lineSummaryModel,
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
              LocalizationService.instance.homeBingoCompleteNthStep(
                "${lineSummaryModel.bingoLinePolicyId}",
              ),
              style: AppTextTheme.subtitle2.common500,
            ),
            SizedBox(height: 10.w),
            Column(
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: LinearProgressIndicator(
                    value: completedCount / lineSummaryModel.requiredLineCount,
                    color: AppColors.common100,
                    backgroundColor: AppColors.common100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
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
                      LocalizationService.instance.homeLineNumber("0"),
                      style: AppTextTheme.caption1.common400,
                    ),
                    Text(
                      LocalizationService.instance.homeLineNumber(
                        "${lineSummaryModel.requiredLineCount}",
                      ),
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
                  LocalizationService.instance.homeReward,
                  style: AppTextTheme.body2.common400,
                ),
                Text(
                  LocalizationService.instance.homePoints(
                    NumberFormat(
                      "###,###,###",
                    ).format(lineSummaryModel.rewardPoint),
                  ),
                  style: AppTextTheme.body2.primary,
                ),
              ],
            ),
            SizedBox(height: 10.w),
            BEATTextButton(
              contentPadding: EdgeInsetsGeometry.symmetric(vertical: 12.w),
              text: LocalizationService.instance.homeClaimReward,
              textColor: (completedCount >= lineSummaryModel.requiredLineCount)
                  ? AppColors.designWhite
                  : AppColors.common300,
              buttonColor:
                  (completedCount >= lineSummaryModel.requiredLineCount)
                  ? AppColors.primary
                  : AppColors.common200,
            ),
          ],
        ),
      ),
    );
  }

  final LineSummaryModel lineSummaryModel;
  final int completedCount;
}
