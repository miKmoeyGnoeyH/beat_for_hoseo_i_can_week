import 'package:auto_size_text/auto_size_text.dart';
import 'package:beat/shared/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../entities/team/index.dart';

// TODO: 빙고판에 null인 칸이 있으면?
// TODO: 등록된 퀘스트가 없어서 빈 배열일 때는?
// TODO: 홈 화면 빙고와 팀 관리 화면 빙고를 따로 구현할 필요가 있나? 모델/뷰 수정 필요
class BingoBoardView extends StatelessWidget {
  const BingoBoardView({
    super.key,
    required this.board,
    required this.countPerAxis,
    this.rowSpacing = 5,
    this.columnSpacing = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: AspectRatio(
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
                color: board[i].completed
                    ? AppColors.primary
                    : AppColors.commonWhite,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.all(10.w),
              child:
              board[i].questInfoView.questType ==
                  QuestType.walk
                  ? SvgPicture.asset(
                BEATAssets.svg.footprint,
                colorFilter: ColorFilter.mode(
                  board[i].completed
                      ? AppColors.designWhite
                      : AppColors.common300,
                  BlendMode.srcIn,
                ),
              )
                  : board[i].completed
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
                  "${board[i].questInfoView.rewardPoint}P",
                  style: AppTextTheme.headline3.common300,
                  maxLines: 1,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  final List<BingoQuestItemSummaryDto> board;
  final int countPerAxis;
  final double rowSpacing;
  final double columnSpacing;
}
