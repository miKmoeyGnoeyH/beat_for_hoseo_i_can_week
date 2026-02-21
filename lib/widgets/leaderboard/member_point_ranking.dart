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

class MemberPointRanking extends StatefulWidget {
  const MemberPointRanking({super.key});

  @override
  State<MemberPointRanking> createState() => MemberPointRankingState();
}

class MemberPointRankingState extends State<MemberPointRanking> {
  final AuthenticationController authenticationController =
      AuthenticationController.to;
  final MemberPointRankingListController memberPointRankingListController =
      MemberPointRankingListController.to;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    initMemberPointRanking();
  }

  Future<void> initMemberPointRanking() async {
    setState(() {
      loading = true;
    });

    String authorization = authenticationController.state!.authorization;

    try {
      await memberPointRankingListController.fetchPointRankingMemberOnce(
        authorization,
      );
    } on BEATTokenExpired catch (e) {
      await authenticationController.reissueToken();
      authorization = authenticationController.state!.authorization;
      await memberPointRankingListController.fetchPointRankingMemberOnce(
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
      await memberPointRankingListController.pointRankingMember(authorization);
    } on BEATTokenExpired catch (e) {
      await authenticationController.reissueToken();
      authorization = authenticationController.state!.authorization;
      await memberPointRankingListController.pointRankingMember(authorization);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: loading,
      containersColor: AppColors.common300,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: memberPointRankingListController.obx(
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
                return MemberPointRankingCard(index, state[index]);
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
          onLoading: memberPointRankingListController.state == null
              ? ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return MemberPointRankingCard(
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
                    return MemberPointRankingCard(
                      index,
                      memberPointRankingListController.state[index],
                    );
                  },
                  separatorBuilder: (_, _) => SizedBox(height: 10.w),
                  itemCount: memberPointRankingListController.state.length,
                ),
          onError: (error) {
            return Column(
              children: [
                Text(
                  LocalizationService.instance.errorConnectivity,
                  style: AppTextTheme.subtitle1.common300,
                ),
                SizedBox(height: 10.w),
                GestureDetector(
                  onTap: () {
                    initMemberPointRanking();
                  },
                  child: Icon(Icons.refresh),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
