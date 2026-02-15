import 'package:beat/entities/profile/index.dart';
import 'package:beat/features/authentication/index.dart';
import 'package:beat/features/profile/index.dart';
import 'package:beat/features/team/index.dart';
import 'package:beat/pages/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../app/route/index.dart';
import '../../shared/index.dart';

class Profile extends StatefulWidget {
  const Profile({super.key, ScrollController? scrollController})
    : _scrollController = scrollController;

  @override
  State<Profile> createState() => _ProfileState();

  final ScrollController? _scrollController;
}

class _ProfileState extends State<Profile> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // 사용자 정보를 사용하기 위한 GetX Controller
  final AuthenticationController authenticationController =
      AuthenticationController.to;

  // 프로필 정보를 불러오고 관리하기 위한 Getx Controller
  final ProfileController profileController = ProfileController.to;

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
    await profileController.fetchDataOnce(authorization);

    setState(() {
      loading = false;
    });
  }

  Future<void> onRefresh() async {
    final String authorization = authenticationController.state!.authorization;
    await profileController.fetchData(authorization);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () {
        return onRefresh();
      },
      child: CustomScrollView(
        controller: widget._scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          // SliverToBoxAdapter(child: SizedBox(height: 16.w)),
          SliverToBoxAdapter(
            child: Skeletonizer(
              enabled: loading,
              // enabled: true,
              containersColor: AppColors.common200,
              effect: SolidColorEffect(color: AppColors.common200),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.w),
                child: ProfileCard(),
              ),
            ),
          ),
          // TODO: 빌드 시 변경
          // if (profileController.state?.studentType == StudentType.mentor)
          if (profileController.state?.studentType == StudentType.mentee)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: BEATTextButton(
                  text: LocalizationService.instance.profileTeamManagement,
                  onTap: () {
                    TeamBingoStatusController.to.teamId =
                        profileController.state!.teamId;
                    Get.toNamed(BEATRoute.teamManagement);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
