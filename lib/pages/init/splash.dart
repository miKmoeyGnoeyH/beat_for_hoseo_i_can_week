import 'package:beat/app/route/app_pages.dart';
import 'package:beat/shared/index.dart';
import 'package:beat/shared/widgets/beat_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: Center(
        child: SvgPicture.asset(
          BEATAssets.svg.greenCampusType2,
          width: 500.w,
          height: 500.w,
          colorFilter: ColorFilter.mode(AppColors.designWhite, BlendMode.srcIn),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await Future.delayed(Duration(seconds: 1));
    checkLoginStatusAndNavigate();
  }

  void checkLoginStatusAndNavigate() {
    if (PrefsService.instance.getUser() == null) {
      Get.toNamed(BEATRoute.signIn);
    }
  }
}
