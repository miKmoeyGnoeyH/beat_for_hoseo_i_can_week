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

  final BorderRadius topLeftBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(15),
    topRight: Radius.circular(5),
    bottomLeft: Radius.circular(5),
    bottomRight: Radius.circular(5),
  );

  final BorderRadius topRightBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(5),
    topRight: Radius.circular(15),
    bottomLeft: Radius.circular(5),
    bottomRight: Radius.circular(5),
  );

  final BorderRadius bottomLeftBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(5),
    topRight: Radius.circular(5),
    bottomLeft: Radius.circular(15),
    bottomRight: Radius.circular(5),
  );

  final BorderRadius bottomRightBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(5),
    topRight: Radius.circular(5),
    bottomLeft: Radius.circular(5),
    bottomRight: Radius.circular(15),
  );

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
    final String authorization = authenticationController.state!.authorization;

    try {
      final response = await Get.showOverlay(
        asyncFunction: () async {
          await Future.delayed(Duration(milliseconds: 500));
          return await APIService().post(
            endpoint: DotEnvService.instance.qrCheck,
            header: {
              "Content-Type": "application/json",
              "authorization": authorization,
            },
            body: jsonEncode({"questId": quest.questId}),
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
              message: response.body,
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
            message: response.body,
          );
      }
    } on TimeoutException {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      ExceptionService.to.addException(BEATTimeoutException());
    } on BEATTokenExpired {
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

  Future<void> walkCheck(QuestInfoView quest) async {
    final String authorization = authenticationController.state!.authorization;

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
                "walkDataType": "QUEST",
              },
            }),
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
              message: response.body,
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
            message: response.body,
          );
      }
    } on TimeoutException {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      ExceptionService.to.addException(BEATTimeoutException());
    } on BEATTokenExpired {
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
    final double borderWidth = 2.w;

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
              if (board[i]?.rewardGiven == false) {
                if ((board[i]!.questInfoView!.questType == QuestType.walk) &&
                    (stepCountController.stepCount >=
                        board[i]!.questInfoView!.required)) {
                  walkCheck(board[i]!.questInfoView!);
                  return;
                }

                if ((board[i]!.questInfoView!.questType == QuestType.qr) &&
                    (board[i]!.memberCompleted == true &&
                        board[i]!.rewardGiven == false)) {
                  qrCheck(board[i]!.questInfoView!);
                  return;
                }
              }

              questDetailController.questInfoView = board[i]!.questInfoView!;
              Get.toNamed(BEATRoute.questDetail);
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: board[i]!.questInfoView!.questType == QuestType.walk
                        ? board[i]!.rewardGiven
                              ? AppColors.primary
                              : AppColors.commonWhite
                        : board[i]!.rewardGiven == true
                        ? AppColors.primary
                        : AppColors.commonWhite,
                    // border: board[i]!.rewardGiven == true
                    //     ? null
                    //     : (board[i]!.questInfoView!.questType == QuestType.walk)
                    //     ? (stepCountController.stepCount >=
                    //               board[i]!.questInfoView!.required)
                    //           ? Border.all(
                    //               width: borderWidth,
                    //               color: AppColors.primary,
                    //             )
                    //           : null
                    //     : board[i]!.memberCompleted == true
                    //     ? Border.all(
                    //         width: borderWidth,
                    //         color: AppColors.primary,
                    //       )
                    //     : board[i]!.teamCompleted == true
                    //     ? Border.all(
                    //         width: borderWidth,
                    //         color: AppColors.common300,
                    //       )
                    //     : null,
                    // borderRadius: i == 0
                    //     ? topLeftBorderRadius
                    //     : i == (countPerAxis - 1)
                    //     ? topRightBorderRadius
                    //     : i == (countPerAxis * (countPerAxis - 1))
                    //     ? bottomLeftBorderRadius
                    //     : i == ((countPerAxis * countPerAxis) - 1)
                    //     ? bottomRightBorderRadius
                    //     : BorderRadius.circular(5),
                    borderRadius: BorderRadiusGeometry.circular(5),
                  ),
                  padding: EdgeInsets.all(10.w),
                  child: board[i]!.questInfoView?.questType == QuestType.walk
                      ? SvgPicture.asset(
                          BEATAssets.svg.footprint,
                          colorFilter: ColorFilter.mode(
                            board[i]!.memberCompleted
                                ? AppColors.designWhite
                                : AppColors.common300,
                            BlendMode.srcIn,
                          ),
                        )
                      : board[i]!.rewardGiven == true
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
                            // "보상\n받기",
                            style: AppTextTheme.headline3.common300,
                            maxLines: 1,
                          ),
                        ),
                ),
                if (board[i]!.questInfoView?.questType == QuestType.walk)
                  if (!board[i]!.rewardGiven)
                    Obx(() {
                      if (stepCountController.stepCount <= 0) {
                        return const SizedBox.shrink();
                      }

                      return Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadiusGeometry.circular(5),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10.w),
                            child: Center(
                              child: AutoSizeText(
                                textAlign: TextAlign.center,
                                (stepCountController.stepCount >=
                                        board[i]!.questInfoView!.required)
                                    ? LocalizationService
                                          .instance
                                          .homeClaimReward
                                    : LocalizationService
                                          .instance
                                          .homeInProgress,
                                style: AppTextTheme.subtitle3.designWhite,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                if (board[i]!.questInfoView?.questType == QuestType.qr)
                  if (!board[i]!.rewardGiven)
                    if (board[i]!.memberCompleted)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadiusGeometry.circular(5),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10.w),
                            child: Center(
                              child: AutoSizeText(
                                textAlign: TextAlign.center,
                                board[i]!.teamCompleted == true
                                    ? LocalizationService
                                          .instance
                                          .homeClaimReward
                                    : LocalizationService
                                          .instance
                                          .homeInProgress,
                                style: AppTextTheme.subtitle3.designWhite,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
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
