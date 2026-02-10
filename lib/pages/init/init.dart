import 'dart:developer';
import 'dart:io';

import 'package:app_version_update/app_version_update.dart';
import 'package:beat/features/step_count/index.dart';
import 'package:beat/shared/services/index.dart';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:url_launcher/url_launcher.dart';

/// 앱의 초기 설정을 수행하는 페이지입니다.
/// 업데이트 확인을 진행합니다.
/// 자식으로 Splash Screen을 갖는 WidgetsBindingObserver로서,
/// 스플래시 화면과는 달리 다음 화면으로 넘어갈 때 위젯 트리에서 사라지지 않고 남아있게 됩니다.
/// 따라서, 앱의 라이프사이클에 걸쳐 앱 전역적으로 수행되어야 하는 작업의 경우, 이곳에서 처리합니다.
/// 만약 이와 같은 작업이 필요하다면 *절대로* 개별 페이지에 WidgetsBindingObserver를 추가하지 마십시오.
class Init extends StatefulWidget {
  const Init({super.key, required this.child});

  final Widget child;

  @override
  State<Init> createState() => _InitState();
}

class _InitState extends State<Init> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkUpdate() async {
    final String appleId = DotEnvService.instance.appstoreID;
    final String playStoreId = DotEnvService.instance.googleplayID;

    try {
      final data = await AppVersionUpdate.checkForUpdates(
        appleId: appleId,
        playStoreId: playStoreId,
        country: 'kr',
      );

      if (data.canUpdate == true) {
        DialogService.to.addDialogEvent(
          AlertDialogEvent(
            title: LocalizationService.instance.generalUpdateAvailable,
            message: LocalizationService.instance.generalUpdateAvailableContent,
            onConfirm: () => _openStore(
              iosHttpsUrl: data.storeUrl!,
              androidPkgId: playStoreId,
            ),
          ),
        );
      } else {
        return;
      }
    } catch (e) {
      log("app.dart: _checkUpdate: error: $e}");
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

  Future<void> _checkPermissionsAndRequestIfNotGranted() async {
    final bool isActivityPermissionGranted = await PermissionService.instance.isActivityPermissionGranted();
    if (!isActivityPermissionGranted) await PermissionService.instance.requestActivityPermission();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    log("init.dart: didChangeAppLifecycleState: $state");
    switch (state) {
      case AppLifecycleState.resumed:
        await _checkUpdate();
        await _checkPermissionsAndRequestIfNotGranted();
        StepCountController.to.onStateChangedBG2FGiOS();
        break;
      case AppLifecycleState.inactive:
        StepCountController.to.onStateChangedFG2BGiOS();
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