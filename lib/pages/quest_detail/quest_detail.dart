import 'dart:async';

import 'package:beat/features/authentication/authentication_controller.dart';
import 'package:beat/features/quest/index.dart';
import 'package:beat/widgets/index.dart';
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
            child: ListView(
              children: [
                Skeletonizer(
                  enabled: loading,
                  // enabled: true,
                  containersColor: AppColors.common200,
                  effect: SolidColorEffect(color: AppColors.common200),
                  child: questDetailController.obx((state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.w),
                        QuestName(
                          questDetailCommonAppDto:
                              state.questDetailCommonAppDto,
                        ),
                        SizedBox(height: 16.w),
                        Images(
                          questDetailCommonAppDto:
                              state.questDetailCommonAppDto,
                        ),
                        SizedBox(height: 16.w),
                        QuestDescription(
                          questDetailCommonAppDto:
                              state.questDetailCommonAppDto,
                        ),
                        SizedBox(height: 16.w),
                        QuestInfo(
                          questDetailCommonAppDto:
                              state.questDetailCommonAppDto,
                        ),
                        SizedBox(height: 16.w),
                        if (state.questDetailCommonAppDto.questType ==
                            QuestType.qr)
                          QRInfo(
                            qrMissionItemAppDtoList:
                                state.qrMissionAppDto.qrMissionItemAppDtoList,
                          ),
                        if (state.questDetailCommonAppDto.questType ==
                            QuestType.walk)
                          WalkInfo(
                            walkMissionAppDto:
                            state.walkMissionAppDto,
                          ),
                        SizedBox(height: 16.w),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
