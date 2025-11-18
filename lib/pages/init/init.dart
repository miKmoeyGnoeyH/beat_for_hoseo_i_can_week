import 'dart:developer';
import 'dart:io';

import 'package:app_version_update/app_version_update.dart';
import 'package:beat/shared/services/dialog_service.dart';
import 'package:beat/shared/services/dotenv_service.dart';
import 'package:beat/shared/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Init extends InheritedWidget with WidgetsBindingObserver {
  const Init({super.key, required super.child});

  @override
  bool updateShouldNotify(Init oldWidget) {
    // TODO: implement updateShouldNotify
    throw UnimplementedError();
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        _checkUpdate();
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
