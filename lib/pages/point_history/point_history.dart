import 'package:beat/entities/point/index.dart';
import 'package:beat/features/authentication/index.dart';
import 'package:beat/features/point/index.dart';
import 'package:beat/features/profile/index.dart';
import 'package:beat/widgets/index.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

    final String authorization = authenticationController.state!.authorization;
    final int memberId = authenticationController.state!.memberId;
    await pointHistoryController.fetchPointHistory(authorization, memberId);

    setState(() {
      loading = false;
    });
  }

  Future<void> onRefresh() async {
    final String authorization = authenticationController.state!.authorization;
    final int memberId = authenticationController.state!.memberId;
    await pointHistoryController.fetchPointHistory(authorization, memberId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.designWhite,
      body: SafeArea(
        child: NestedScrollView(
          physics: NeverScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              BEATSliverBackAppBar(
                title: LocalizationService.instance.phPointHistory,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
