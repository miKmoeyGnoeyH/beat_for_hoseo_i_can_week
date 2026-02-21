import 'dart:developer';

import 'package:beat/entities/notice/index.dart';
import 'package:beat/features/authentication/index.dart';
import 'package:beat/features/leaderboard/index.dart';
import 'package:beat/features/notice/index.dart';
import 'package:beat/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../shared/index.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  final AuthenticationController authenticationController =
      AuthenticationController.to;
  final TeamPointRankingListController teamPointRankingListController =
      TeamPointRankingListController.to;
  final MemberPointRankingListController memberPointRankingListController =
      MemberPointRankingListController.to;

  final TeamWalkRankingListController teamWalkRankingListController =
      TeamWalkRankingListController.to;
  final MemberWalkRankingListController memberWalkRankingListController =
      MemberWalkRankingListController.to;

  final BingoRankingListController asanBingoRankingListController =
      BingoRankingListController.to;

  final ScrollController bodyController = ScrollController();

  int selectedRankingIndex = 0;
  int selectedRankingTypeIndex = 0;

  final GlobalKey<TeamPointRankingState> teamPointRankingKey =
      GlobalKey<TeamPointRankingState>();
  final GlobalKey<MemberPointRankingState> memberPointRankingKey =
      GlobalKey<MemberPointRankingState>();
  final GlobalKey<TeamWalkRankingState> teamWalkRankingKey =
      GlobalKey<TeamWalkRankingState>();
  final GlobalKey<MemberWalkRankingState> memberWalkRankingKey =
      GlobalKey<MemberWalkRankingState>();
  final GlobalKey<BingoRankingState> bingoRankingKey =
      GlobalKey<BingoRankingState>();

  late final List<List<Widget>> rankingWidgets;
  late final List<String> rankingTitles;
  late final List<List<String>> rankingTypeTitles;
  late final List<String> rankingDescriptions;

  void initRankingWidgets() {
    log(authenticationController.state!.campus);

    rankingWidgets = [
      [
        TeamPointRanking(key: teamPointRankingKey),
        MemberPointRanking(key: memberPointRankingKey),
      ],
      [
        TeamWalkRanking(key: teamWalkRankingKey),
        MemberWalkRanking(key: memberWalkRankingKey),
      ],
      [BingoRanking(key: bingoRankingKey)],
    ];
  }

  void initRankingTitles() {
    rankingTitles = [
      LocalizationService.instance.leaderboardPointRanking,
      LocalizationService.instance.leaderboardWalkRanking,
      LocalizationService.instance.leaderboardBingoRanking,
    ];
  }

  void initRankingTypeTitles() {
    rankingTypeTitles = [
      [
        LocalizationService.instance.leaderboardTeam,
        LocalizationService.instance.leaderboardMember,
      ],
      [
        LocalizationService.instance.leaderboardTeam,
        LocalizationService.instance.leaderboardMember,
      ],
      [],
    ];
  }

  void initRankingDescriptions() {
    rankingDescriptions = [
      LocalizationService.instance.leaderboardPointRankingDescription,
      LocalizationService.instance.leaderboardWalkRankingDescription,
      LocalizationService.instance.leaderboardBingoRankingDescription,
    ];
  }

  @override
  void initState() {
    initLeaderboard();
    super.initState();
  }

  Future<void> initLeaderboard() async {
    initRankingTitles();
    initRankingTypeTitles();
    initRankingWidgets();
    initRankingDescriptions();
  }

  Future<void> onRefresh() async {
    if (selectedRankingIndex == 0 && selectedRankingTypeIndex == 0) {
      await teamPointRankingKey.currentState?.onRefresh();
      return;
    } else if (selectedRankingIndex == 0 && selectedRankingTypeIndex == 1) {
      await memberPointRankingKey.currentState?.onRefresh();
      return;
    } else if (selectedRankingIndex == 1 && selectedRankingTypeIndex == 0) {
      await teamWalkRankingKey.currentState?.onRefresh();
      return;
    } else if (selectedRankingIndex == 1 && selectedRankingTypeIndex == 1) {
      await memberWalkRankingKey.currentState?.onRefresh();
      return;
    } else if (selectedRankingIndex == 2 && selectedRankingTypeIndex == 0) {
      await bingoRankingKey.currentState?.onRefresh();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.designWhite,
      body: SafeArea(
        top: false,
        bottom: false,
        child: NestedScrollView(
          // physics: NeverScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              BEATSliverBackAppBar(
                title: LocalizationService.instance.leaderboardLeaderboard,
              ),
            ];
          },
          body: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.commonWhite,
            onRefresh: () {
              return onRefresh();
            },
            child: CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              controller: bodyController,
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: 16.w)),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 56.w,
                    child: ListView.separated(
                      primary: false,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: 130.w,
                          child: BEATTextButton(
                            text: rankingTitles[index],
                            textColor: selectedRankingIndex == index
                                ? AppColors.designWhite
                                : AppColors.designBlack,
                            buttonColor: selectedRankingIndex == index
                                ? AppColors.primary
                                : AppColors.commonWhite,
                            onTap: () {
                              setState(() {
                                selectedRankingIndex = index;
                                selectedRankingTypeIndex = 0;
                              });
                            },
                          ),
                        );
                      },
                      separatorBuilder: (_, _) => SizedBox(width: 10.w),
                      itemCount: rankingTitles.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: rankingTypeTitles[selectedRankingIndex].isEmpty
                      ? SizedBox.shrink()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.w),
                            SizedBox(
                              height: 56.w,
                              child: ListView.separated(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return SizedBox(
                                    width: 130.w,
                                    child: BEATTextButton(
                                      text:
                                          rankingTypeTitles[selectedRankingIndex][index],
                                      textColor:
                                          selectedRankingTypeIndex == index
                                          ? AppColors.designWhite
                                          : AppColors.designBlack,
                                      buttonColor:
                                          selectedRankingTypeIndex == index
                                          ? AppColors.primary
                                          : AppColors.commonWhite,
                                      onTap: () {
                                        setState(() {
                                          selectedRankingTypeIndex = index;
                                        });
                                      },
                                    ),
                                  );
                                },
                                separatorBuilder: (_, _) =>
                                    SizedBox(width: 10.w),
                                itemCount:
                                    rankingTypeTitles[selectedRankingIndex]
                                        .length,
                              ),
                            ),
                          ],
                        ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 16.w)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: BEATShadowContainer(
                      shadowBlurRadius: 15.w,
                      shadowSpreadRadius: -10.w,
                      contentPadding: EdgeInsetsGeometry.all(16.w),
                      child: Text(
                        rankingDescriptions[selectedRankingIndex],
                        style: AppTextTheme.body1,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 16.w)),
                SliverToBoxAdapter(
                  child:
                      rankingWidgets[selectedRankingIndex][selectedRankingTypeIndex],
                ),
                SliverToBoxAdapter(child: SizedBox(height: 32.w)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
