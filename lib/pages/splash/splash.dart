
import 'package:beat/app/route/app_pages.dart';
import 'package:beat/features/authentication/authentication_controller.dart';
import 'package:beat/features/step_count/index.dart';
import 'package:beat/shared/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:pedometer/pedometer.dart';

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
          BEATAssets.svg.greenCampusLogoType2,
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
    WidgetsBinding.instance.addPostFrameCallback((_) => bootstrap());
  }

  Future<void> bootstrap() async {
    await Future.delayed(Duration(seconds: 1));
    await checkLoginStatusAndNavigate();
  }

  Future<void> checkLoginStatusAndNavigate() async {
    final Map<String, dynamic>? savedUser = PrefsService.instance.getUser();

    if (savedUser == null) {
      Get.offAllNamed(BEATRoute.signIn);
    } else {
      AuthenticationController.to.signInFromJson(savedUser);
      await StepCountController.to.startService();
      Get.offAllNamed(BEATRoute.home);
    }
  }
}
