import 'package:beat/entities/notice/index.dart';
import 'package:beat/entities/point/index.dart';
import 'package:beat/features/authentication/index.dart';
import 'package:beat/features/notice/index.dart';
import 'package:beat/features/notice/index.dart';
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

class NoticeList extends StatefulWidget {
  const NoticeList({super.key});

  @override
  State<NoticeList> createState() => _NoticeListState();
}

class _NoticeListState extends State<NoticeList> {
  final AuthenticationController authenticationController =
      AuthenticationController.to;
  final NoticeController noticeController = NoticeController.to;

  bool loading = true;

  @override
  void initState() {
    initNotice();
    super.initState();
  }

  Future<void> initNotice() async {
    setState(() {
      loading = true;
    });

    final String authorization = authenticationController.state!.authorization;
    await noticeController.fetchNoticeList(authorization);

    setState(() {
      loading = false;
    });
  }

  Future<void> onRefresh() async {
    final String authorization = authenticationController.state!.authorization;
    await noticeController.fetchNoticeList(authorization);
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
                title: LocalizationService.instance.noticeNotice,
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
              child: noticeController.obx(
                (state) {
                  if (state.length == 0) {
                    return Center(
                      child: Text(
                        LocalizationService.instance.noticeNoticeEmpty,
                        style: AppTextTheme.subtitle1.common300,
                      ),
                    );
                  } else {
                    return ListView.separated(
                      padding: EdgeInsetsGeometry.all(16.w),
                      itemBuilder: (context, index) {
                        final NoticeModel item = state![index];
                        return NoticeCard(item);
                      },
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 10.w),
                      itemCount: state.length,
                    );
                  }
                },
                onEmpty: ListView.separated(
                  padding: EdgeInsetsGeometry.all(16.w),
                  itemBuilder: (context, index) {
                    return NoticeCard(NoticeModel.empty());
                  },
                  separatorBuilder: (context, index) => SizedBox(height: 10.w),
                  itemCount: 10,
                ),
                onLoading: ListView.separated(
                  padding: EdgeInsetsGeometry.all(16.w),
                  itemBuilder: (context, index) {
                    final NoticeModel item = (noticeController.state == null)
                        ? NoticeModel.empty()
                        : noticeController.state![index];
                    return NoticeCard(item);
                  },
                  separatorBuilder: (context, index) => SizedBox(height: 10.w),
                  itemCount: (noticeController.state == null)
                      ? 10
                      : noticeController.state!.length,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
