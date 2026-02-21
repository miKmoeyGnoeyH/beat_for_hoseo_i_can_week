import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../entities/leaderboard/leaderboard_model.dart';
import '../../features/authentication/index.dart';
import '../../features/leaderboard/index.dart';
import '../../shared/index.dart';
import 'member_walk_ranking_card.dart';

class MemberWalkRanking extends StatefulWidget {
  const MemberWalkRanking({super.key});

  @override
  State<MemberWalkRanking> createState() => MemberWalkRankingState();
}

class MemberWalkRankingState extends State<MemberWalkRanking> {
  final AuthenticationController authenticationController =
      AuthenticationController.to;
  final MemberWalkRankingListController teamWalkRankingListController =
      MemberWalkRankingListController.to;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    initMemberWalkRanking();
  }

  Future<void> initMemberWalkRanking() async {
    setState(() {
      loading = true;
    });

    String authorization = authenticationController.state!.authorization;

    try {
      await teamWalkRankingListController.fetchWalkRankingMemberOnce(
        authorization,
      );
    } on BEATTokenExpired {
      await authenticationController.reissueToken();
      authorization = authenticationController.state!.authorization;
      await teamWalkRankingListController.fetchWalkRankingMemberOnce(
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
      await teamWalkRankingListController.walkRankingMember(authorization);
    } on BEATTokenExpired {
      await authenticationController.reissueToken();
      authorization = authenticationController.state!.authorization;
      await teamWalkRankingListController.walkRankingMember(authorization);
    }
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
                return MemberWalkRankingCard(index, state[index]);
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
                    return MemberWalkRankingCard(
                      index,
                      MemberRankingInfoDto.empty(),
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
                    return MemberWalkRankingCard(
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
                  initMemberWalkRanking();
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
