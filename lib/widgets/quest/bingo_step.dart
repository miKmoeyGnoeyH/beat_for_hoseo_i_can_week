import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:beat/features/authentication/authentication_controller.dart';
import 'package:beat/shared/index.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../entities/quest/index.dart';
import '../../features/point/index.dart';
import '../../features/quest/index.dart';

class BingoStep extends StatelessWidget {
  BingoStep({
    super.key,
    required this.questId,
    required this.completedLines,
    required this.lineSummaryModel,
    // required this.index,
    required this.completedCount,
  });

  final AuthenticationController authenticationController =
      AuthenticationController.to;
  final PointController pointController = PointController.to;
  final QuestListController questListController = QuestListController.to;

  Future<void> bingoCheck() async {
    final String authorization = authenticationController.state!.authorization;

    try {
      if (completedLines.length < completedCount) {
        throw BEATException(
          title: LocalizationService.instance.errorBingoCheckFailedTitle,
          message:
              LocalizationService.instance.errorBingoCheckFailedPleaseRefresh,
        );
      }

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
              "questId": questId,
              "bingoLinePolicyId": lineSummaryModel.bingoLinePolicyId,
              "lineCompleteRequestList": List.generate(
                completedLines.length,
                (index) => {completedLines[index].toJson()},
              ),
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
              title: LocalizationService.instance.homeBingoCheckSuccessTitle,
              message:
                  LocalizationService.instance.homeBingoCheckSuccessContent,
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
            title: LocalizationService.instance.errorBingoCheckFailedTitle,
            message: LocalizationService.instance.errorBingoCheckFailedContent,
          );
      }
    } on TimeoutException {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      ExceptionService.to.addException(BEATTimeoutException());
    } on BEATTokenExpired {
      await authenticationController.reissueToken();
      await bingoCheck();
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
          title: LocalizationService.instance.errorBingoCheckFailedTitle,
          message: LocalizationService.instance.errorUnknown,
        ),
      );
    }
  }

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

  final int questId;
  final List<CompletedLineInfo> completedLines;
  final LineSummaryModel lineSummaryModel;
  // final int index;
  final int completedCount;
}
