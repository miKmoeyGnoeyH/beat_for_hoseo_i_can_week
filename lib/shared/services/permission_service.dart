import 'dart:io';

import 'package:beat/features/step_count/health_kit_steps.dart';
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

  /// Notification
  Future<bool> requestNotificationPermission() async {
    final notificationStatus = await Permission.notification.request();
    return notificationStatus.isGranted;
  }

  Future<bool> isNotificationPermissionGranted() async {
    final notificationStatus = await Permission.notification.status;
    return notificationStatus.isGranted;
  }

  /// activity
  Future<void> requestActivityPermission() async {
    if (Platform.isIOS) {
      await HealthKitSteps.requestAuth();
    } else {
      await Permission.activityRecognition.request();
    }
  }

  Future<bool> isActivityPermissionGranted() async {
    if (Platform.isIOS) {
      final bool isHealthKitGranted = await iOSPermissionChannel!.invokeMethod(
        'canReadSteps',
      );
      return isHealthKitGranted;
      // return false;
    } else {
      return await Permission.activityRecognition.isGranted;
    }
  }

  /// location
  /// 위치 권한 요청 (앱 사용 중에만)
  Future<bool> requestLocationWhenInUsePermission() async {
    final locationWhenInUseStatus = await Permission.locationWhenInUse
        .request();
    return locationWhenInUseStatus.isGranted;
  }

  /// 위치 권한이 부여되었는지 확인 (앱 사용 중에만)
  Future<bool> isLocationWhenInUsePermissionGranted() async {
    final locationWhenInUseStatus = await Permission.locationWhenInUse.status;
    return locationWhenInUseStatus.isGranted;
  }

  /// 위치 권한 요청 (항상)
  Future<bool> requestLocationAlwaysPermission() async {
    final locationAlwaysStatus = await Permission.locationAlways.request();
    return locationAlwaysStatus.isGranted;
  }

  /// 위치 권한이 부여되었는지 확인 (항상)
  Future<bool> isLocationAlwaysPermissionGranted() async {
    final locationAlwaysStatus = await Permission.locationAlways.status;
    return locationAlwaysStatus.isGranted;
  }
}
