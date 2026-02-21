import 'package:beat/entities/leaderboard/leaderboard_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../shared/index.dart';

class BingoRankingCard extends StatelessWidget {
  const BingoRankingCard(this.index, this.leaderboardModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BEATShadowContainer(
        shadowBlurRadius: 15.w,
        shadowSpreadRadius: -10.w,
        contentPadding: EdgeInsetsGeometry.all(16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (index == 0)
              Image.asset(
                BEATAssets.images.crownGold,
                width: 36.w,
                height: 36.w,
              )
            else if (index == 1)
              Image.asset(
                BEATAssets.images.crownSilver,
                width: 36.w,
                height: 36.w,
              )
            else if (index == 2)
                Image.asset(
                  BEATAssets.images.crownBronze,
                  width: 36.w,
                  height: 36.w,
                )
              else
                SizedBox(
                  width: 36.w,
                  height: 36.w,
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: AppTextTheme.title1,
                    ),
                  ),
                ),
            Text(leaderboardModel.teamName, style: AppTextTheme.title1),
            Row(
              children: [
                Image.asset(
                  width: 24.w,
                  height: 24.w,
                  BEATAssets.images.greenCampusPoint,
                ),
                SizedBox(width: 5.w),
                Text(
                  leaderboardModel.num.toString(),
                  style: AppTextTheme.subtitle1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  final int index;
  final BingoRankingInfoDto leaderboardModel;
}
