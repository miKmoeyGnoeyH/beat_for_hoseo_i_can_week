import 'package:beat/entities/team/index.dart';
import 'package:beat/features/team/index.dart';
import 'package:beat/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../features/authentication/authentication_controller.dart';
import '../../shared/index.dart';

class TeamManagement extends StatefulWidget {
  const TeamManagement({super.key});

  @override
  State<TeamManagement> createState() => _TeamManagementState();
}

class _TeamManagementState extends State<TeamManagement> {
  // 사용자 정보를 사용하기 위한 GetX Controller
  final AuthenticationController authenticationController =
      AuthenticationController.to;

  final TeamBingoStatusController teamBingoStatusController =
      TeamBingoStatusController.to;

  // Skeleton 활성화/비활성화를 나타내기 위한 변수
  bool loading = true;

  @override
  void initState() {
    super.initState();
    initTeamManagement();
  }

  Future<void> initTeamManagement() async {
    setState(() {
      loading = true;
    });

    final String authorization = authenticationController.state!.authorization;
    await teamBingoStatusController.fetchTeamBingoStatus(authorization);

    setState(() {
      loading = false;
    });
  }

  Future<void> onRefresh() async {
    final String authorization = authenticationController.state!.authorization;
    await teamBingoStatusController.fetchTeamBingoStatus(authorization);
  }

  @override
  Widget build(BuildContext context) {
    final double rowSpacing = 16.w;

    return Scaffold(
      backgroundColor: AppColors.designWhite,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              BEATSliverBackAppBar(
                title: LocalizationService.instance.teamTeamManagement,
              ),
            ];
          },
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () {
              return onRefresh();
            },
            child: Skeletonizer(
              enabled: loading,
              // enabled: true,
              containersColor: AppColors.common200,
              effect: SolidColorEffect(color: AppColors.common200),
              child: teamBingoStatusController.obx(
                (state) {
                  return TeamBingoStatusListView(
                    state: teamBingoStatusController.state,
                  );
                },
                onEmpty: Center(
                  child: Text(
                    LocalizationService.instance.teamTeamInfoEmpty,
                    style: AppTextTheme.subtitle1.common300,
                  ),
                ),
                onLoading: TeamBingoStatusListView(
                  state: List.generate(3, (_) => TeamBingoStatusModel.empty()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TeamBingoStatusListView extends StatelessWidget {
  const TeamBingoStatusListView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsetsGeometry.all(16.w),
      itemBuilder: (context, index) {
        final TeamBingoStatusModel item = state![index];
        return BEATShadowContainer(
          contentPadding: EdgeInsetsGeometry.all(16.w),
          child: Column(
            children: [
              Row(
                children: [
                  Text(item.name, style: AppTextTheme.subtitle1),
                  SizedBox(width: 5.w),
                  Text(item.studentId, style: AppTextTheme.subtitle2.common300),
                ],
              ),
              SizedBox(height: 10.w),
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: AppColors.designWhite,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.common400,
                      blurRadius: 30.w,
                      spreadRadius: -20.w,
                      offset: Offset(0, -1.w),
                    ),
                  ],
                ),
                child: BingoBoardView(
                  board: item.localData.board,
                  countPerAxis: item.localData.countPerAxis,
                ),
              ),
              SizedBox(height: 10.w),
              Column(
                children: [
                  Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: LinearProgressIndicator(
                      value:
                          item.localData.completedItemCount /
                          item.bingoQuestItemSummaryDtoList.length,
                      color: AppColors.common100,
                      backgroundColor: AppColors.common100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      minHeight: 25.w,
                      semanticsLabel: 'semanticsLabel',
                      semanticsValue: 'semanticsValue',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocalizationService.instance.teamNumber("0"),
                        style: AppTextTheme.caption1.common400,
                      ),
                      Text(
                        LocalizationService.instance.teamNumber(
                          "${item.bingoQuestItemSummaryDtoList.length}",
                        ),
                        style: AppTextTheme.caption1.common400,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(height: 16.w);
      },
      itemCount: state.length,
    );
  }

  final List<TeamBingoStatusModel> state;
}
