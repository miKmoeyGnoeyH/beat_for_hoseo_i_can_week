import 'dart:developer';
import 'dart:io';

import 'package:beat/app/route/app_pages.dart';
import 'package:beat/fcm.dart';
import 'package:beat/features/authentication/authentication_controller.dart';
import 'package:beat/features/point/index.dart';
import 'package:beat/shared/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => await bootstrap(),
    );
  }

  Future<void> bootstrap() async {
    await Future.delayed(Duration(seconds: 1));
    await fcmInit();
    await _checkUpdate();
    await checkLoginStatusAndNavigate();
  }

  Future<void> _checkUpdate() async {
    final String appleId = DotEnvService.instance.appstoreID;
    final String playStoreId = DotEnvService.instance.googleplayID;

    try {
      final data = NewVersionPlus(
        iOSId: appleId,
        iOSAppStoreCountry: 'kr',
        androidId: playStoreId,
        androidPlayStoreCountry: 'kr'
      );

      final version = await data.getVersionStatus();

      if (version == null) return;

      if (version.canUpdate == true) {
        DialogService.to.addDialogEvent(
          AlertDialogEvent(
            title: LocalizationService.instance.generalUpdateAvailable,
            message: LocalizationService.instance.generalUpdateAvailableContent,
            onConfirm: () => _openStore(
              iosHttpsUrl: version.appStoreLink,
              androidPkgId: playStoreId,
            ),
          ),
        );
      } else {
        return;
      }
    } catch (e) {
      log("splash.dart: _checkUpdate: error: $e}");
    }
  }

  Future<void> _openStore({
    required String iosHttpsUrl,
    required String androidPkgId,
  }) async {
    if (Platform.isIOS) {
      final itms = Uri.parse(
        iosHttpsUrl.replaceFirst('https://', 'itms-apps://'),
      );
      if (!await launchUrl(itms, mode: LaunchMode.externalApplication)) {
        await launchUrl(
          Uri.parse(iosHttpsUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } else {
      final market = Uri.parse('market://details?id=$androidPkgId');
      if (!await launchUrl(market, mode: LaunchMode.externalApplication)) {
        final web = Uri.parse(
          'https://play.google.com/store/apps/details?id=$androidPkgId',
        );
        await launchUrl(web, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> checkLoginStatusAndNavigate() async {
    final Map<String, dynamic>? savedUser = PrefsService.instance.getUser();

    if (savedUser == null) {
      Get.offAllNamed(BEATRoute.signIn);
      return;
    }

    final AuthenticationController authenticationController =
        AuthenticationController.to;
    authenticationController.signInFromJson(savedUser);

    try {
      /// 토큰 만료 여부를 확인하기 위해 아무 요청을 하나 보냄
      // await PointController.to.fetchPointBalance(
      //   authenticationController.state!.authorization,
      // );
      await authenticationController.reissueToken();
      Get.offAllNamed(BEATRoute.mainPageView);
      return;
    } on BEATTokenExpired {
      try {
        await authenticationController.reissueToken();
        if (Get.isRegistered<PointController>()) {
          await PointController.to.fetchPointBalance(
            authenticationController.state!.authorization,
          );
        }
        Get.offAllNamed(BEATRoute.mainPageView);
        return;
      } catch (e) {
        log("Splash: checkLoginStatusAndNavigate: error: ${e.toString()}");
        await authenticationController.signOut();
        Get.offAllNamed(BEATRoute.signIn);
        return;
      }
    } catch (e) {
      log("Splash: checkLoginStatusAndNavigate: error: ${e.toString()}");
      await authenticationController.signOut();
      Get.offAllNamed(BEATRoute.signIn);
      return;
    }
  }
}
