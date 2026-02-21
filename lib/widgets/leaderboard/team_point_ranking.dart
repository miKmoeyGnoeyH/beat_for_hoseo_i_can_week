import 'package:beat/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../entities/leaderboard/leaderboard_model.dart';
import '../../features/authentication/index.dart';
import '../../features/leaderboard/index.dart';
import '../../shared/index.dart';

class TeamPointRanking extends StatefulWidget {
  const TeamPointRanking({super.key});

  @override
  State<TeamPointRanking> createState() => TeamPointRankingState();
}

class TeamPointRankingState extends State<TeamPointRanking> {
  final AuthenticationController authenticationController =
      AuthenticationController.to;
  final TeamPointRankingListController teamPointRankingListController =
      TeamPointRankingListController.to;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    initTeamPointRanking();
  }

  Future<void> initTeamPointRanking() async {
    setState(() {
      loading = true;
    });

    String authorization = authenticationController.state!.authorization;

    try {
      await teamPointRankingListController.fetchPointRankingTeamOnce(
        authorization,
      );
    } on BEATTokenExpired {
      await authenticationController.reissueToken();
      authorization = authenticationController.state!.authorization;
      await teamPointRankingListController.fetchPointRankingTeamOnce(
        authorization,
      );
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> onRefresh() async {
    String authorization = authenticationController.state!.authorization;

    try {
      await teamPointRankingListController.pointRankingTeam(authorization);
    } on BEATTokenExpired {
      await authenticationController.reissueToken();
      authorization = authenticationController.state!.authorization;
      await teamPointRankingListController.pointRankingTeam(authorization);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: loading,
      containersColor: AppColors.common300,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: teamPointRankingListController.obx(
          (state) {
            if (state.length == 0) {
              return Center(
                child: Text(
                  LocalizationService.instance.leaderboardNoData,
                  style: AppTextTheme.subtitle1.common300,
                ),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return TeamPointRankingCard(index, state[index]);
              },
              separatorBuilder: (_, _) => SizedBox(height: 10.w),
              itemCount: state.length,
            );
          },
          onEmpty: Center(
            child: Text(
              LocalizationService.instance.leaderboardNoData,
              style: AppTextTheme.subtitle1.common300,
            ),
          ),
          onLoading: teamPointRankingListController.state == null
              ? ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return TeamPointRankingCard(
                      index,
                      TeamRankingInfoDto.empty(),
                    );
                  },
                  separatorBuilder: (_, _) => SizedBox(height: 10.w),
                  itemCount: 20,
                )
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return TeamPointRankingCard(
                      index,
                      teamPointRankingListController.state[index],
                    );
                  },
                  separatorBuilder: (_, _) => SizedBox(height: 10.w),
                  itemCount: teamPointRankingListController.state.length,
                ),
          onError: (error) {
            return SizedBox(
              height: 350.w,
              child: GestureDetector(
                onTap: () {
                  initTeamPointRanking();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      LocalizationService.instance.errorConnectivity,
                      style: AppTextTheme.subtitle1.common300,
                    ),
                    SizedBox(height: 10.w),
                    Icon(Icons.refresh),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
