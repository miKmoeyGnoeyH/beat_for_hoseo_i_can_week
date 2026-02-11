import 'package:auto_size_text/auto_size_text.dart';
import 'package:beat/app/route/app_pages.dart';
import 'package:beat/shared/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class College extends StatefulWidget {
  College({super.key});

  @override
  State<College> createState() => _CollegeState();
}

class _CollegeState extends State<College> {
  final int selectedCampusIndex = Get.arguments["selectedCampusIndex"];

  final List<String> requestColleges = LocalizationService
      .instance
      .signUpRequestColleges
      .split(", ");

  final List<String> uiColleges = LocalizationService.instance.signUpColleges
      .split(", ");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationService.instance.signUpCollege,
          style: AppTextTheme.subtitle2,
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.commonWhite,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: SvgPicture.asset(
            BEATAssets.svg.backArrow,
            width: 24.w,
            height: 24.w,
          ),
        ),
      ),
      backgroundColor: AppColors.designWhite,
      body: SafeArea(
        child: Center(
          child: BEATCupertinoPicker(
            items: uiColleges,
            onSelectedItemChanged: (i) => setState(() {
              selectedCollegeIndex = i;
            }),
          ),
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () => Get.toNamed(
          BEATRoute.department,
          arguments: {
            "selectedCampusIndex": selectedCampusIndex,
            "selectedCollegeIndex": selectedCollegeIndex,
          },
        ),
        child: BottomAppBar(
          color: AppColors.primary,
          height: 56.w,
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Center(
              child: AutoSizeText(
                LocalizationService.instance.signUpContinueWith(
                  uiColleges[selectedCollegeIndex],
                ),
                style: AppTextTheme.title1.designWhite,
                maxLines: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  int selectedCollegeIndex = 0;
}
