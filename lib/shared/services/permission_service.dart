import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService instance = PermissionService._internal();
  late final MethodChannel? iOSPermissionChannel;

  PermissionService._internal() {
    if (Platform.isIOS) {
      iOSPermissionChannel = MethodChannel("beat/permission");
    }
  }

  Future<void> requestActivityPermission() async {
    await Permission.activityRecognition.request();
  }

  Future<bool> isActivityPermissionGranted() async {
    if (Platform.isIOS) {
      final bool isActivityRecognitionGranted =
          await Permission.activityRecognition.isGranted;
      final bool isHealthKitGranted =
          await iOSPermissionChannel!.invokeMethod('isHealthHealthKitGranted') ??
          false;
      return isActivityRecognitionGranted && isHealthKitGranted;
    } else {
      return await Permission.activityRecognition.isGranted;
    }
  }
}
