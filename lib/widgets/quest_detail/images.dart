import 'dart:async';

import 'package:beat/entities/quest/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../features/authentication/index.dart';
import '../../shared/index.dart';

class Images extends StatefulWidget {
  const Images({super.key, required this.questDetailCommonAppDto});

  @override
  State<Images> createState() => _ImagesState();

  final QuestDetailCommonAppDto questDetailCommonAppDto;
}

class _ImagesState extends State<Images> {
  // 사용자 정보를 사용하기 위한 GetX Controller
  final AuthenticationController authenticationController =
      AuthenticationController.to;

  // 상단 포인트/걸음 수 카드를 위한 PageController
  final PageController imageController = PageController();

  // SmoothPageIndecator 투명화 애니메이션을 위한 타이며, 변수
  Timer? hideTimer;

  bool indicatorVisible = true;

  @override
  void initState() {
    showIndicatorThenAutoHide();
    super.initState();
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
    imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.questDetailCommonAppDto.fileList.isNotEmpty)
          AspectRatio(
            aspectRatio: 1,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification ||
                    notification is UserScrollNotification ||
                    notification is ScrollUpdateNotification) {
                  showIndicatorThenAutoHide();
                }
                return false;
              },
              child: PageView(
                controller: imageController,
                physics: PageScrollPhysics(),
                children: List.generate(
                  widget.questDetailCommonAppDto.fileList.length,
                  (i) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      width: double.infinity,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: AppColors.common300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.network(
                        "${DotEnvService.instance.fetchQuestDetailImage}${widget.questDetailCommonAppDto.fileList[i].fileId}",
                        headers: {
                          "authorization":
                              authenticationController.state!.authorization,
                        },
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (widget.questDetailCommonAppDto.fileList.isNotEmpty)
          Positioned(
            left: 175.w,
            bottom: 16.w,
            child: IgnorePointer(
              ignoring: !indicatorVisible,
              child: AnimatedOpacity(
                opacity: indicatorVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.commonBlack.withAlpha(100),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: EdgeInsetsGeometry.all(3.w),
                  child: SmoothPageIndicator(
                    controller: imageController,
                    count: widget.questDetailCommonAppDto.fileList.length,
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
          ),
      ],
    );
  }
}
