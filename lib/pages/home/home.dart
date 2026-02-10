import 'dart:async';

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
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
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
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
          ),
          child: StepCountCard(),
        ),
      ),
    ),
    Center(
      child: SizedBox(
        height: 120.w,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
          ),
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

    // TODO: API 변경으로 인해 API 호출 파라미터 변경 필요
    // await pointController.fetchPointBalance(authorization);
    // await questListController.fetchQuestList(authorization);

    setState(() {
      loading = false;
    });

    showIndicatorThenAutoHide();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.designWhite,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [HomeAppbar()];
          },
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () {
              return initHome();
            },
            child: CustomScrollView(
              slivers: [
                // SliverToBoxAdapter(child: SizedBox(height: 16.w)),
                SliverToBoxAdapter(
                  child: Skeletonizer(
                    enabled: loading,
                    // enabled: true,
                    containersColor: AppColors.common300,
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
                // SliverToBoxAdapter(child: Container(color: AppColors.statusError,height: 10.w, width: 10.w,),),
                SliverToBoxAdapter(
                  child: Skeletonizer(
                    enabled: loading,
                    containersColor: AppColors.common300,
                    child: QuestList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BEATBNB(),
    );
  }
}
