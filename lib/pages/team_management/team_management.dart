import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
            return [
              BEATSliverBackAppBar(
                title: LocalizationService.instance.teamTeamManagement,
              ),
            ];
          },
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () {
              return initTeamManagement();
            },
            child: ListView(
              children: [
                Skeletonizer(
                  enabled: loading,
                  // enabled: true,
                  containersColor: AppColors.common200,
                  effect: SolidColorEffect(color: AppColors.common200),
                  child: SizedBox(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
