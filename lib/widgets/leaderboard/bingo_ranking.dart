
import 'package:beat/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../entities/leaderboard/leaderboard_model.dart';
import '../../features/authentication/index.dart';
import '../../features/leaderboard/index.dart';
import '../../shared/index.dart';

class BingoRanking extends StatefulWidget {
  const BingoRanking({super.key});

  @override
  State<BingoRanking> createState() => BingoRankingState();
}

class BingoRankingState extends State<BingoRanking> {
  final AuthenticationController authenticationController =
      AuthenticationController.to;
  final BingoRankingListController bingoRankingListController =
      BingoRankingListController.to;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    initBingoRanking();
  }

  Future<void> initBingoRanking() async {
    setState(() {
      loading = true;
    });

    String authorization = authenticationController.state!.authorization;
    String campus = authenticationController.state!.campus;
    String requestCampus = LocalizationService.instance.generalCampus(campus);

    try {
      await bingoRankingListController.fetchBingoRankingOnce(
        authorization,
        requestCampus,
      );
    } on BEATTokenExpired {
      await authenticationController.reissueToken();
      authorization = authenticationController.state!.authorization;
      await bingoRankingListController.fetchBingoRankingOnce(
        authorization,
        requestCampus,
      );
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> onRefresh() async {
    String authorization = authenticationController.state!.authorization;
    String campus = authenticationController.state!.campus;
    String requestCampus = LocalizationService.instance.generalCampus(campus);

    try {
      await bingoRankingListController.bingoRankingAsan(
        authorization,
        requestCampus,
      );
    } on BEATTokenExpired {
      await authenticationController.reissueToken();
      authorization = authenticationController.state!.authorization;
      await bingoRankingListController.bingoRankingAsan(
        authorization,
        requestCampus,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: loading,
      // enabled: true,
      containersColor: AppColors.common300,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: bingoRankingListController.obx(
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
                return BingoRankingCard(index, state[index]);
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
          onLoading: bingoRankingListController.state == null
              ? ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return BingoRankingCard(index, BingoRankingInfoDto.empty());
                  },
                  separatorBuilder: (_, _) => SizedBox(height: 10.w),
                  itemCount: 20,
                )
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return BingoRankingCard(
                      index,
                      bingoRankingListController.state[index],
                    );
                  },
                  separatorBuilder: (_, _) => SizedBox(height: 10.w),
                  itemCount: bingoRankingListController.state.length,
                ),
          onError: (error) {
            return SizedBox(
              height: 350.w,
              child: GestureDetector(
                onTap: () {
                  initBingoRanking();
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
