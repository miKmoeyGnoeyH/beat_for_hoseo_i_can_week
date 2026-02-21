import 'package:beat/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../entities/leaderboard/leaderboard_model.dart';
import '../../features/authentication/index.dart';
import '../../features/leaderboard/index.dart';
import '../../shared/index.dart';

class TeamWalkRanking extends StatefulWidget {
  const TeamWalkRanking({super.key});

  @override
  State<TeamWalkRanking> createState() => TeamWalkRankingState();
}

class TeamWalkRankingState extends State<TeamWalkRanking> {
  final AuthenticationController authenticationController =
      AuthenticationController.to;
  final TeamWalkRankingListController teamWalkRankingListController =
      TeamWalkRankingListController.to;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    initTeamWalkRanking();
  }

  Future<void> initTeamWalkRanking() async {
    setState(() {
      loading = true;
    });

    String authorization = authenticationController.state!.authorization;

    try {
      await teamWalkRankingListController.fetchWalkRankingTeamOnce(
        authorization,
      );
    } on BEATTokenExpired catch (e) {
      await authenticationController.reissueToken();
      authorization = authenticationController.state!.authorization;
      await teamWalkRankingListController.fetchWalkRankingTeamOnce(
        authorization,
      );
    } catch (e) {}

    setState(() {
      loading = false;
    });
  }

  Future<void> onRefresh() async {
    String authorization = authenticationController.state!.authorization;

    try {
      await teamWalkRankingListController.walkRankingTeam(authorization);
    } on BEATTokenExpired catch (e) {
      await authenticationController.reissueToken();
      authorization = authenticationController.state!.authorization;
      await teamWalkRankingListController.walkRankingTeam(authorization);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: loading,
      containersColor: AppColors.common300,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: teamWalkRankingListController.obx(
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
                return TeamWalkRankingCard(index, state[index]);
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
          onLoading: teamWalkRankingListController.state == null
              ? ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return TeamWalkRankingCard(
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
                    return TeamWalkRankingCard(
                      index,
                      teamWalkRankingListController.state[index],
                    );
                  },
                  separatorBuilder: (_, _) => SizedBox(height: 10.w),
                  itemCount: teamWalkRankingListController.state.length,
                ),
          onError: (error) {
            return SizedBox(
              height: 350.w,
              child: GestureDetector(
                onTap: () {
                  initTeamWalkRanking();
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
