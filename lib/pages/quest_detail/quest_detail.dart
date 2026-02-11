import 'dart:async';

import 'package:beat/features/authentication/authentication_controller.dart';
import 'package:beat/features/quest/index.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../entities/quest/index.dart';
import '../../shared/index.dart';

class QuestDetail extends StatefulWidget {
  const QuestDetail({super.key});

  @override
  State<QuestDetail> createState() => _QuestDetailState();
}

class _QuestDetailState extends State<QuestDetail> {
  // 사용자 정보를 사용하기 위한 GetX Controller
  final AuthenticationController authenticationController =
      AuthenticationController.to;

  // 퀘스트 상세 정보를 불러오고 관리하기 위한 Getx Controller
  final QuestDetailController questDetailController = QuestDetailController.to;

  // Skeleton 활성화/비활성화를 나타내기 위한 변수
  bool loading = true;

  // 상단 포인트/걸음 수 카드를 위한 PageController
  final PageController imageController = PageController();

  // SmoothPageIndecator 투명화 애니메이션을 위한 타이며, 변수
  Timer? hideTimer;
  bool indicatorVisible = true;

  @override
  void initState() {
    super.initState();
    initProfile();
  }

  Future<void> initProfile() async {
    setState(() {
      loading = true;
    });

    final String authorization = authenticationController.state!.authorization;

    await questDetailController.fetchQuestDetail(authorization);

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double rowSpacing = 16.w;

    return Scaffold(
      backgroundColor: AppColors.designWhite,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [BEATSliverBackAppBar()];
          },
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () {
              return initProfile();
            },
            child: CustomScrollView(
              slivers: [
                // SliverToBoxAdapter(child: SizedBox(height: 16.w)),
                SliverToBoxAdapter(
                  child: Skeletonizer(
                    enabled: loading,
                    // enabled: true,
                    containersColor: AppColors.common200,
                    effect: SolidColorEffect(color: AppColors.common200),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.w,
                      ),
                      child: questDetailController.obx((state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LocalizationService
                                      .instance
                                      .questDetailQuestName,
                                  style: AppTextTheme.title1,
                                ),
                                SizedBox(height: 5.w),
                                Text(
                                  state.questDetailCommonAppDto.name,
                                  style: AppTextTheme.body1,
                                ),
                              ],
                            ),
                            SizedBox(height: 16.w),
                            Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: PageView(
                                    controller: imageController,
                                    children: List.generate(
                                      state
                                          .questDetailCommonAppDto
                                          .fileList
                                          .length,
                                      (i) => Image.network(
                                        "${DotEnvService.instance.baseURL}/${state.questDetailCommonAppDto.fileList[i].publicUrl}",
                                        headers: {
                                          "authorization":
                                              authenticationController
                                                  .state!
                                                  .authorization,
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 175.w,
                                  bottom: 22.w,
                                  child: IgnorePointer(
                                    ignoring: !indicatorVisible,
                                    child: AnimatedOpacity(
                                      opacity: indicatorVisible ? 1.0 : 0.0,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeOut,
                                      child: SmoothPageIndicator(
                                        controller: imageController,
                                        count: state
                                            .questDetailCommonAppDto
                                            .fileList
                                            .length,
                                        effect: ColorTransitionEffect(
                                          dotWidth: 7.w,
                                          dotHeight: 7.w,
                                          spacing: 5.w,
                                          dotColor:
                                              AppColors.disabledColorLight,
                                          activeDotColor: AppColors.designWhite,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.w),
                            BEATShadowContainer(
                              width: double.infinity,
                              contentPadding: EdgeInsetsGeometry.all(16.w),
                              shadowBlurRadius: 20.w,
                              shadowSpreadRadius: -15.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    LocalizationService
                                        .instance
                                        .questDetailQuestDescription,
                                    style: AppTextTheme.title1,
                                  ),
                                  SizedBox(height: 5.w),
                                  Text(
                                    state
                                        .questDetailCommonAppDto
                                        .descriptionLong,
                                    style: AppTextTheme.body1,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.w),
                            BEATShadowContainer(
                              width: double.infinity,
                              contentPadding: EdgeInsetsGeometry.all(16.w),
                              shadowBlurRadius: 20.w,
                              shadowSpreadRadius: -15.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        LocalizationService
                                            .instance
                                            .questDetailTotalReward,
                                        style: AppTextTheme.subtitle3,
                                      ),
                                      Row(
                                        children: [
                                          Image.asset(
                                            BEATAssets.images.greenCampusPoint,
                                            width: 18.w,
                                          ),
                                          SizedBox(width: 5.w),
                                          Text(
                                            NumberFormat(
                                              "###,###,###,###",
                                            ).format(
                                              state
                                                  .questDetailCommonAppDto
                                                  .totalPoint,
                                            ),
                                            style: AppTextTheme.subtitle3,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: rowSpacing),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        LocalizationService
                                            .instance
                                            .questDetailQuestType,
                                        style: AppTextTheme.subtitle3,
                                      ),
                                      Text(
                                        state
                                            .questDetailCommonAppDto
                                            .questType
                                            .value,

                                        style: AppTextTheme.subtitle3,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: rowSpacing),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        LocalizationService
                                            .instance
                                            .questDetailStartDate,
                                        style: AppTextTheme.subtitle3,
                                      ),
                                      Text(
                                        state.questDetailCommonAppDto.startDate,

                                        style: AppTextTheme.subtitle3,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: rowSpacing),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        LocalizationService
                                            .instance
                                            .questDetailEndDate,
                                        style: AppTextTheme.subtitle3,
                                      ),
                                      Text(
                                        state.questDetailCommonAppDto.endDate,
                                        style: AppTextTheme.subtitle3,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.w),
                            if (state.questDetailCommonAppDto.questType ==
                                QuestType.qr)
                              ListView.separated(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final QRMissionItemAppDto item = state
                                      .qrMissionAppDto
                                      .qrMissionItemAppDtoList[index];
                                  return BEATShadowContainer();
                                },
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 5.w),
                                itemCount: state
                                    .qrMissionAppDto
                                    .qrMissionItemAppDtoList
                                    .length,
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
