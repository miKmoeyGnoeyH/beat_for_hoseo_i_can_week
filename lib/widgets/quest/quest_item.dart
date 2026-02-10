import 'package:beat/entities/quest/index.dart';
import 'package:beat/shared/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuestItem extends StatelessWidget {
  const QuestItem(this.questModel, {this.index, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: AppColors.disabledColorLight,
      splashColor: AppColors.disabledColorLight,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0.5, color: AppColors.disabledColorLight),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (index != null)
                        Column(
                          children: [
                            Text(
                              LocalizationService.instance.homeQuestNo(
                                index! + 1,
                              ),
                              style: AppTextTheme.caption1.primary,
                            ),
                            SizedBox(height: 5.w),
                          ],
                        ),
                      Text("abc", style: AppTextTheme.subtitle1),
                      SizedBox(height: 5.w),
                      Text(
                        questModel.questCommonSummaryDto.descriptionShort,
                        style: AppTextTheme.body2.disabled,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(
                          BEATAssets.images.greenCampusPoint,
                          width: 32.w,
                        ),
                      ),
                      Text(
                        "abc".toString(),
                        style: AppTextTheme.subtitle1,
                      ),
                    ],
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  void onTap() {}

  final QuestModel questModel;
  final int? index;
}
