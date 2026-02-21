import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:beat/app/route/app_pages.dart';
import 'package:beat/entities/quest/quest_model.dart';
import 'package:beat/features/authentication/authentication_controller.dart';
import 'package:beat/features/quest/index.dart';
import 'package:beat/features/step_count/index.dart';
import 'package:beat/shared/index.dart';
import 'package:beat/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../features/point/index.dart';

// TODO: 빙고판에 null인 칸이 있으면?
// TODO: 등록된 퀘스트가 없어서 빈 배열일 때는?
class BingoBoard extends StatelessWidget {
  BingoBoard({
    super.key,
    required this.board,
    required this.countPerAxis,
    this.rowSpacing = 5,
    this.columnSpacing = 5,
  });

  final AuthenticationController authenticationController =
      AuthenticationController.to;
  final PointController pointController = PointController.to;
  final QuestListController questListController = QuestListController.to;
  final StepCountController stepCountController = StepCountController.to;
  final QuestDetailController questDetailController = QuestDetailController.to;

  // Future<void> checkQuest(QuestType questType) async {
  //   switch (questType) {
  //     case QuestType.qr:
  //       await qrCheck();
  //       break;
  //     case QuestType.walk:
  //       await walkCheck();
  //       break;
  //     default:
  //       break;
  //   }
  // }

  Future<void> qrCheck(QuestInfoView quest) async {
    return;
  }

  Future<void> walkCheck(QuestInfoView quest) async {
    final String authorization = authenticationController.state!
        .authorization;

    try {
      final response = await Get.showOverlay(
        asyncFunction: () async {
          await Future.delayed(Duration(milliseconds: 500));
          return await APIService().post(
              endpoint: DotEnvService.instance.walkCheck,
              header: {
                "Content-Type": "application/json",
                "authorization": authorization,
              },
              body: jsonEncode({
                "questId": quest.questId,
                "walkHistoryRequest": {
                  "historyDateTime": DateTime.now().toIso8601String(),
                  "walkCount": stepCountController.stepCount,
                  "walkDataType": "QUEST"
                }
              })
          );
        },
        loadingWidget: BEATCircularProgressIndicator(),
        opacity: 0.3,
      );

      log(response.body);

      switch (response.statusCode) {
        case 200:
          DialogService.to.addDialogEvent(
            AlertDialogEvent(
              title: LocalizationService.instance.homeQuestCheckSuccessTitle,
              message: LocalizationService
                  .instance
                  .homeQuestCheckSuccessContent,
              onConfirm: () {
                pointController.fetchPointBalance(authorization);
                questListController.fetchQuestList(authorization);
              },
            ),
          );
          break;
        case 401:
          throw BEATTokenExpired();
        default:
          throw BEATException(
            title: LocalizationService.instance.errorQuestCheckFailedTitle,
            message:
            LocalizationService.instance.errorQuestCheckFailedContent,
          );
      }
    } on TimeoutException {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      ExceptionService.to.addException(BEATTimeoutException());
    } on BEATTokenExpired catch (e) {
      await authenticationController.reissueToken();
      await walkCheck(quest);
    } on BEATException catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      ExceptionService.to.addException(e);
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      ExceptionService.to.addException(
        BEATException(
          title: LocalizationService.instance.errorQuestCheckFailedTitle,
          message: LocalizationService.instance.errorUnknown,
        ),
      );
    }
  }

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
              if (board[i]?.completed == false) {
                if ((board[i]!.questInfoView!.questType ==
                    QuestType.walk) &&
                    (stepCountController.stepCount >=
                        board[i]!.questInfoView!.required)) {
                  walkCheck(board[i]!.questInfoView!);
                  return;
                }

                if ((board[i]!.questInfoView!.questType ==
                    QuestType.qr) &&
                    (board[i]!.questInfoView!.completeCount! >=
                        board[i]!.questInfoView!.required)) {
                  qrCheck(board[i]!.questInfoView!);
                  return;
                }
              }

              questDetailController.questInfoView = board[i]!.questInfoView!;
              Get.toNamed(BEATRoute.questDetail);
            },
            child: Container(
              decoration: BoxDecoration(
                color: board[i]!.completed!
                    ? AppColors.primary
                    : AppColors.commonWhite,
                border: board[i]!.completed!
                    ? null
                    : (board[i]!.questInfoView!.questType ==
                    QuestType.walk)
                    ? (stepCountController.stepCount >=
                    board[i]!.questInfoView!.required)
                    ? Border.all(width: 0.5.w, color: AppColors.primary)
                    : null
                    : (board[i]!.questInfoView!.completeCount! >=
                    board[i]!.questInfoView!.required)
                    ? Border.all(width: 0.5.w, color: AppColors.primary)
                    : null,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.all(10.w),
              child:
              board[i]!.questInfoView?.questType ==
                  QuestType.walk
                  ? SvgPicture.asset(
                BEATAssets.svg.footprint,
                colorFilter: ColorFilter.mode(
                  board[i]!.completed!
                      ? AppColors.designWhite
                      : AppColors.common300,
                  BlendMode.srcIn,
                ),
              )
                  : board[i]!.completed!
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
                  "${board[i]!.questInfoView?.rewardPoint}P",
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

  final List<ItemSummaryModel?> board;
  final int countPerAxis;
  final double rowSpacing;
  final double columnSpacing;
}
