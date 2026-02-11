import 'package:auto_size_text/auto_size_text.dart';
import 'package:beat/app/route/app_pages.dart';
import 'package:beat/shared/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class Campus extends StatefulWidget {
  Campus({super.key});

  @override
  State<Campus> createState() => _CampusState();
}

class _CampusState extends State<Campus> {
  // final List<String> requestCampuses = LocalizationService
  final List<String> uiCampuses = LocalizationService.instance.signUpCampuses
      .split(", ");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationService.instance.signUpCampus,
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
            items: uiCampuses,
            onSelectedItemChanged: (i) => setState(() {
              selectedCampusIndex = i;
            }),
          ),
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () => Get.toNamed(
          BEATRoute.college,
          arguments: {"selectedCampusIndex": selectedCampusIndex},
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
                  uiCampuses[selectedCampusIndex],
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

  int selectedCampusIndex = 0;
}
