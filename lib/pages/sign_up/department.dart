import 'package:auto_size_text/auto_size_text.dart';
import 'package:beat/app/route/app_pages.dart';
import 'package:beat/shared/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class Department extends StatefulWidget {
  const Department({super.key});

  @override
  State<Department> createState() => _DepartmentState();
}

class _DepartmentState extends State<Department> {
  final int selectedCampusIndex = Get.arguments["selectedCampusIndex"];
  final int selectedCollegeIndex = Get.arguments["selectedCollegeIndex"];

  late final String departmentsKey;
  late final List<String> requestDepartments;
  late final List<String> uiDepartments;

  @override
  void initState() {
    departmentsKey = LocalizationService.instance.signUpColleges.split(
      ", ",
    )[selectedCollegeIndex];

    requestDepartments = LocalizationService.instance
        .signUpRequestDepartments(departmentsKey)
        .split(", ");

    uiDepartments = LocalizationService.instance
        .signUpDepartments(departmentsKey)
        .split(", ");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationService.instance.signUpDepartment,
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
            items: uiDepartments,
            onSelectedItemChanged: (i) => setState(() {
              selectedDepartmentIndex = i;
            }),
          ),
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () => Get.toNamed(
          BEATRoute.fillInform,
          arguments: {
            "selectedCampusIndex": selectedCampusIndex,
            "selectedCollegeIndex": selectedCollegeIndex,
            "selectedDepartmentIndex": selectedDepartmentIndex,
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
                  uiDepartments[selectedDepartmentIndex],
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

  int selectedDepartmentIndex = 0;
}
