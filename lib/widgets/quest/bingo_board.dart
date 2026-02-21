import 'package:auto_size_text/auto_size_text.dart';
import 'package:beat/app/route/app_pages.dart';
import 'package:beat/entities/quest/quest_model.dart';
import 'package:beat/features/quest/index.dart';
import 'package:beat/features/step_count/index.dart';
import 'package:beat/shared/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

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
  final StepCountController stepCountController = StepCountController.to;
  final QuestDetailController questDetailController = QuestDetailController.to;

  Future<void> requestReward() async {}

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: countPerAxis,
          crossAxisSpacing: rowSpacing,
          mainAxisSpacing: columnSpacing,
        ),
        itemCount: countPerAxis * countPerAxis,
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () {
              /// 퀘스트를 완료하지 않았고(보상을 수령하지 않았고)
              /// 각 퀘스트 타입 별 완료 조건을 충족했을 때만 보상 수령 활성화
              if (questSummaryAppView[i]?.completed == false) {
                if ((questSummaryAppView[i]!.questInfoView!.questType ==
                        QuestType.walk) &&
                    (stepCountController.stepCount >=
                        questSummaryAppView[i]!.questInfoView!.required)) {
                  requestReward();
                  return;
                }

                if ((questSummaryAppView[i]!.questInfoView!.questType ==
                        QuestType.qr) &&
                    (questSummaryAppView[i]!.questInfoView!.completeCount! >=
                        questSummaryAppView[i]!.questInfoView!.required)) {
                  requestReward();
                  return;
                }
              }

              questDetailController.questInfoView = questSummaryAppView[i]!.questInfoView!;
              Get.toNamed(BEATRoute.questDetail);
            },
            child: Container(
              decoration: BoxDecoration(
                color: questSummaryAppView[i]!.completed!
                    ? AppColors.primary
                    : AppColors.commonWhite,
                border: questSummaryAppView[i]!.completed!
                    ? null
                    : (questSummaryAppView[i]!.questInfoView!.questType ==
                          QuestType.walk)
                    ? (stepCountController.stepCount >=
                              questSummaryAppView[i]!.questInfoView!.required)
                          ? Border.all(width: 0.5.w, color: AppColors.primary)
                          : null
                    : (questSummaryAppView[i]!.questInfoView!.completeCount! >=
                          questSummaryAppView[i]!.questInfoView!.required)
                    ? Border.all(width: 0.5.w, color: AppColors.primary)
                    : null,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.all(10.w),
              child:
                  questSummaryAppView[i]!.questInfoView?.questType ==
                      QuestType.walk
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
                      child: AutoSizeText(
                        "${questSummaryAppView[i]!.questInfoView?.rewardPoint}P",
                        style: AppTextTheme.headline3.common300,
                        maxLines: 1,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  final List<ItemSummaryModel?> questSummaryAppView;
  final int countPerAxis;
  final double rowSpacing;
  final double columnSpacing;
}
