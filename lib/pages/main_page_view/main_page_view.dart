import 'dart:developer';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:beat/pages/index.dart';
import 'package:beat/shared/index.dart';
import 'package:beat/widgets/index.dart';
import 'package:flutter/material.dart';

import '../../features/step_count/index.dart';

class MainPageView extends StatefulWidget {
  const MainPageView({super.key});

  @override
  State<MainPageView> createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView>
    with WidgetsBindingObserver {
  // PageView 제어를 위한 GetX Controller
  final PageViewController pageViewController = PageViewController.to;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final bool isFirstLaunch =
          PrefsService.instance.getIsFirstLaunch() ?? true;

      if (isFirstLaunch) {
        await _requestPermissions();
        await PrefsService.instance.setIsFirstLaunch(false);
      }
      await _checkAndStartServiceIfPossible();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // TODO: 홈 화면 에러 발생 시 어떻게?
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.designWhite,
      body: SafeArea(
        top: false,
        child: NestedScrollView(
          physics: NeverScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [MainPageViewAppbar()];
          },
          body: PageView(
            controller: pageViewController.pageController,
            onPageChanged: pageViewController.onPageChanged,
            children: [
              QR(scrollController: pageViewController.scrollControllers[0]),
              Home(scrollController: pageViewController.scrollControllers[1]),
              Profile(
                scrollController: pageViewController.scrollControllers[2],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BEATBNB(),
    );
  }

  Future<void> _requestPermissions() async {
    await PermissionService.instance.requestLocationWhenInUsePermission();
    await PermissionService.instance.requestLocationAlwaysPermission();
    await PermissionService.instance.requestActivityPermission();
  }

  Future<void> _checkAndStartServiceIfPossible() async {
    final bool isLocationWhenInUsePermissionGranted = await PermissionService
        .instance
        .isLocationWhenInUsePermissionGranted();

    if (!isLocationWhenInUsePermissionGranted) {
      DialogService.to.addDialogEvent(
        ConfirmDialogEvent(
          title: LocalizationService
              .instance
              .generalRequiresLocationPermissionTitle,
          message: LocalizationService
              .instance
              .generalRequiresLocationPermissionContent,
          confirmText: LocalizationService.instance.generalGoToSettings,
          onConfirm: () =>
              AppSettings.openAppSettings(type: AppSettingsType.settings),
        ),
      );
      return;
    }

    if (Platform.isIOS) {
      await StepCountController.to.checkIsServiceRunningAndStartIfNot();
      return;
    }

    /// 안드로이드 분기
    final isActivityPermissionGranted = await PermissionService.instance
        .isActivityPermissionGranted();

    if (!isActivityPermissionGranted) {
      DialogService.to.addDialogEvent(
        ConfirmDialogEvent(
          title: LocalizationService
              .instance
              .generalRequiresActivityPermissionTitle,
          message: LocalizationService
              .instance
              .generalRequiresActivityPermissionContent,
          confirmText: LocalizationService.instance.generalGoToSettings,
          onConfirm: () =>
              AppSettings.openAppSettings(type: AppSettingsType.settings),
        ),
      );

      return;
    }

    final bool isLocationAlwaysPermissionGranted = await PermissionService
        .instance
        .isLocationAlwaysPermissionGranted();

    if (!isLocationWhenInUsePermissionGranted ||
        !isLocationAlwaysPermissionGranted) {
      DialogService.to.addDialogEvent(
        ConfirmDialogEvent(
          title: LocalizationService
              .instance
              .generalRequiresLocationPermissionTitle,
          message: LocalizationService
              .instance
              .generalRequiresLocationPermissionContent,
          confirmText: LocalizationService.instance.generalGoToSettings,
          onConfirm: () =>
              AppSettings.openAppSettings(type: AppSettingsType.settings),
        ),
      );
      return;
    }

    log(
      "MainPageView: _checkAndStartServiceIfPossible: isActivityPermissionGranted: $isActivityPermissionGranted, isLocationAlwaysPermissionGranted: $isLocationAlwaysPermissionGranted",
    );

    if (isActivityPermissionGranted && isLocationAlwaysPermissionGranted) {
      await StepCountController.to.checkIsServiceRunningAndStartIfNot();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await _checkAndStartServiceIfPossible();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      default:
        break;
    }
  }
}
