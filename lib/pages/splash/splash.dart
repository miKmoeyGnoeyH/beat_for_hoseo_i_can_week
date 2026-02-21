import 'package:beat/app/route/app_pages.dart';
import 'package:beat/fcm.dart';
import 'package:beat/features/authentication/authentication_controller.dart';
import 'package:beat/features/step_count/index.dart';
import 'package:beat/shared/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

/// 스플래시 스크린입니다.
/// 앱의 일부 초기 동작을 결정합니다.
/// 로그인 상태 확인 후, 상태에 맞게 초기 라우팅을 결정합니다.
/// 로그인되어있다면 자동 로그인 실행 -> 걸음 수 측정 시작 -> 홈 화면으로 이동합니다.
/// init 페이지와는 달리 필요한 동작이 모두 종료되면 pop되어 위젯 트리에서 사라지기 때문에,
/// 해당 페이지에서 수행되는 동작은 앱의 라이프사이클동안 두번다시 실행되지 않습니다.
class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: AppColors.primary,
        child: Center(
          child: SvgPicture.asset(
            BEATAssets.svg.logoType2,
            width: 100.w,
            height: 100.w,
            colorFilter: ColorFilter.mode(
              AppColors.designWhite,
              BlendMode.srcIn,
            ),
          ),
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
    await fcmInit();
    await checkLoginStatusAndNavigate();
  }

  Future<void> checkLoginStatusAndNavigate() async {
    final Map<String, dynamic>? savedUser = PrefsService.instance.getUser();

    if (savedUser == null) {
      Get.offAllNamed(BEATRoute.signIn);
    } else {
      AuthenticationController.to.signInFromJson(savedUser);
      Get.offAllNamed(BEATRoute.mainPageView);
    }
  }
}
