import 'dart:async';
import 'dart:math';

import 'package:beat/entities/quest/index.dart';
import 'package:beat/features/authentication/authentication_controller.dart';
import 'package:beat/features/point/index.dart';
import 'package:beat/features/quest/index.dart';
import 'package:beat/shared/index.dart';
import 'package:beat/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Home extends StatefulWidget {
  Home({super.key, ScrollController? scrollController})
    : _scrollController = scrollController;

  @override
  State<Home> createState() => _HomeState();

  final ScrollController? _scrollController;
}

class _HomeState extends State<Home> {
  // 사용자 정보를 사용하기 위한 GetX Controller
  final AuthenticationController authenticationController =
      AuthenticationController.to;

  // 포인트 정보를 사용하기 위한 GetX Controller
  final PointController pointController = PointController.to;

  // 퀘스트 목록을 사용하기 위한 GetX Controller
  final QuestListController questListController = QuestListController.to;

  // Skeleton 활성화/비활성화를 나타내기 위한 변수
  bool loading = true;

  // 상단 포인트/걸음 수 카드를 위한 PageController
  final PageController cardController = PageController();

  // SmoothPageIndecator 투명화 애니메이션을 위한 타이며, 변수
  Timer? hideTimer;
  bool indicatorVisible = true;

  // PageView에 표시할 카드 목록
  // PageView의 children에 직접 지정할 경우, SmoothIndicator의 count에 직접 값을 입력해야 한다.
  // 카드 목록을 사전에 리스트로 생성해놓고, SmoothIndicator의 count에는 리스트의 길이를 넣는다.
  final List<Widget> cards = [
    Center(
      child: SizedBox(
        height: 120.w,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: StepCountCard(),
        ),
      ),
    ),
    Center(
      child: SizedBox(
        height: 120.w,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: PointCard(),
        ),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    initHome();
  }

  Future<void> initHome() async {
    setState(() {
      loading = true;
    });

    final String authorization = authenticationController.state!.authorization;

    await pointController.fetchPointBalanceOnce(authorization);
    await questListController.fetchQuestListOnce(authorization);

    setState(() {
      loading = false;
    });

    showIndicatorThenAutoHide();
  }

  Future<void> onRefresh() async {
    final String authorization = authenticationController.state!.authorization;
    await pointController.fetchPointBalance(authorization);
    await questListController.fetchQuestList(authorization);
  }

  void showIndicatorThenAutoHide() {
    if (!indicatorVisible) {
      setState(() => indicatorVisible = true);
    }
    hideTimer?.cancel();
    hideTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => indicatorVisible = false);
    });
  }

  @override
  void dispose() {
    hideTimer?.cancel();
    cardController.dispose();
    super.dispose();
  }

  // TODO: 홈 화면 에러 발생 시 어떻게?
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () {
        return onRefresh();
      },
      child: CustomScrollView(
        controller: widget._scrollController,
        slivers: [
          // SliverToBoxAdapter(child: SizedBox(height: 16.w)),
          SliverToBoxAdapter(
            child: Skeletonizer(
              enabled: loading,
              // enabled: true,
              containersColor: AppColors.common200,
              effect: SolidColorEffect(color: AppColors.common200),
              child: SizedBox(
                height: 150.w,
                child: Stack(
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollStartNotification ||
                            notification is UserScrollNotification ||
                            notification is ScrollUpdateNotification) {
                          showIndicatorThenAutoHide();
                        }
                        return false;
                      },
                      child: PageView(
                        controller: cardController,
                        children: cards,
                      ),
                    ),
                    Positioned(
                      left: 175.w,
                      bottom: 22.w,
                      child: IgnorePointer(
                        ignoring: !indicatorVisible,
                        child: AnimatedOpacity(
                          opacity: indicatorVisible ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          child: SmoothPageIndicator(
                            controller: cardController,
                            count: cards.length,
                            effect: ColorTransitionEffect(
                              dotWidth: 7.w,
                              dotHeight: 7.w,
                              spacing: 5.w,
                              dotColor: AppColors.disabledColorLight,
                              activeDotColor: AppColors.designWhite,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // TODO: pageview를 사용하도록 변경
          SliverToBoxAdapter(
            child: Skeletonizer(
              enabled: loading,
              containersColor: AppColors.common300,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: AppColors.designWhite,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.common400,
                        blurRadius: 30.w,
                        spreadRadius: -20.w,
                        offset: Offset(0, -3.w),
                      ),
                    ],
                  ),
                  // TODO: 조건문 더 줄일 수 있을 것 같은뎨?
                  child: BingoBoard(
                    questSummaryAppView: loading
                        ? List.generate(
                            25,
                            (index) => QuestSummaryModel.empty(),
                          )
                        : questListController.state.first.questSummaryAppView,
                    countPerAxis: loading
                        ? 5
                        : sqrt(
                            questListController
                                .state
                                .first
                                .questSummaryAppView
                                .length,
                          ).toInt(),
                    rowSpacing: 5.w,
                    columnSpacing: 5.w,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 16.w)),
          SliverToBoxAdapter(
            child: Skeletonizer(
              enabled: loading,
              containersColor: AppColors.common300,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: ArchivementRate(
                  totalPoints: loading
                      ? 0
                      : questListController
                            .state
                            .first
                            .questCommonSummaryDto
                            .totalPoint,
                  totalCount: loading
                      ? 25
                      : questListController
                            .state
                            .first
                            .questSummaryAppView
                            .length,
                  completedCount: loading
                      ? 0
                      : questListController.state.first.completedCount,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 16.w)),
        ],
      ),
    );
  }
}
