import 'package:beat/entities/point/index.dart';
import 'package:beat/features/authentication/index.dart';
import 'package:beat/features/point/index.dart';
import 'package:beat/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../shared/index.dart';

class PointHistory extends StatefulWidget {
  const PointHistory({super.key});

  @override
  State<PointHistory> createState() => _PointHistoryState();
}

class _PointHistoryState extends State<PointHistory> {
  final AuthenticationController authenticationController =
      AuthenticationController.to;
  final PointHistoryController pointHistoryController =
      PointHistoryController.to;

  bool loading = true;

  @override
  void initState() {
    initPointHistory();
    super.initState();
  }

  Future<void> initPointHistory() async {
    setState(() {
      loading = true;
    });

    String authorization = authenticationController.state!.authorization;
    final int memberId = authenticationController.state!.memberId;

    try {
      await pointHistoryController.fetchPointHistory(authorization, memberId);
    } on BEATTokenExpired {
      await authenticationController.reissueToken();
      authorization = authenticationController.state!.authorization;
      await pointHistoryController.fetchPointHistory(authorization, memberId);
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> onRefresh() async {
    String authorization = authenticationController.state!.authorization;
    final int memberId = authenticationController.state!.memberId;

    try {
      await pointHistoryController.fetchPointHistory(authorization, memberId);
    } on BEATTokenExpired {
      await authenticationController.reissueToken();
      authorization = authenticationController.state!.authorization;
      await pointHistoryController.fetchPointHistory(authorization, memberId);
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
          physics: NeverScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              BEATSliverBackAppBar(
                title: LocalizationService.instance.phPointHistory,
                pinned: true,
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
              containersColor: AppColors.common300,
              effect: SolidColorEffect(color: AppColors.common300),
              child: pointHistoryController.obx(
                (state) {
                  return ListView.separated(
                    padding: EdgeInsetsGeometry.all(16.w),
                    itemBuilder: (context, index) {
                      final PointHistoryModel item = state![index];
                      return PointHistoryCard(item);
                    },
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 10.w),
                    itemCount: state.length,
                  );
                },
                onEmpty: ListView.separated(
                  padding: EdgeInsetsGeometry.all(16.w),
                  itemBuilder: (context, index) {
                    return PointHistoryCard(PointHistoryModel.empty());
                  },
                  separatorBuilder: (context, index) => SizedBox(height: 10.w),
                  itemCount: 10,
                ),
                onLoading: ListView.separated(
                  padding: EdgeInsetsGeometry.all(16.w),
                  itemBuilder: (context, index) {
                    final PointHistoryModel item =
                        (pointHistoryController.state == null)
                        ? PointHistoryModel.empty()
                        : pointHistoryController.state![index];
                    return PointHistoryCard(item);
                  },
                  separatorBuilder: (context, index) => SizedBox(height: 10.w),
                  itemCount: (pointHistoryController.state == null)
                      ? 10
                      : pointHistoryController.state!.length,
                ),
                onError: (_) {
                  return SizedBox(
                    height: 500.w,
                    child: GestureDetector(
                      onTap: () {
                        initPointHistory();
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
                }
              ),
            ),
          ),
        ),
      ),
    );
  }
}
