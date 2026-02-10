import 'package:beat/entities/quest/quest_model.dart';
import 'package:beat/features/quest/index.dart';
import 'package:beat/shared/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

// TODO: 빙고판에 null인 칸이 있으면?
// TODO: 등록된 퀘스트가 없어서 빈 배열일 때는?
class BingoBoard extends StatelessWidget {
  BingoBoard({
    super.key,
    required this.questSummaryAppView,
    required this.countPerAxis,
    this.rowSpacing = 5,
    this.columnSpacing = 5,
  });

  final QuestListController questListController = QuestListController.to;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: countPerAxis,
          crossAxisSpacing: rowSpacing,
          mainAxisSpacing: columnSpacing,
        ),
        itemCount: countPerAxis * countPerAxis,
        itemBuilder: (context, i) {
          // TODO: 조건문들 더 줄일 수 있을 것 같은데?
          return Container(
            decoration: BoxDecoration(
              color: questSummaryAppView[i]!.completed!
                  ? AppColors.primary
                  : AppColors.commonWhite,
              borderRadius: BorderRadius.circular(5),
            ),
            padding: EdgeInsets.all(10.w),
            child: questSummaryAppView[i]!.questInfoView?.questType == QuestType.walk
                ? SvgPicture.asset(
                    BEATAssets.svg.footprint,
                    colorFilter: ColorFilter.mode(
                      questSummaryAppView[i]!.completed!
                          ? AppColors.designWhite
                          : AppColors.common300,
                      BlendMode.srcIn,
                    ),
                  )
                : questSummaryAppView[i]!.completed!
                ? SvgPicture.asset(
                    BEATAssets.svg.hori,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      AppColors.designWhite,
                      BlendMode.srcIn,
                    ),
                  )
                : Center(
                    child: Text(
                      "${questSummaryAppView[i]!.questInfoView?.rewardPoint}P",
                      style: AppTextTheme.headline3.common300,
                    ),
                  ),
          );
        },
      ),
    );
  }

  final List<QuestSummaryModel?> questSummaryAppView;
  final int countPerAxis;
  final double rowSpacing;
  final double columnSpacing;
}
