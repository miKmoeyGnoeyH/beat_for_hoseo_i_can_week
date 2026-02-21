import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';


Future<String?> _waitForApnsToken({
  Duration timeout = const Duration(seconds: 10),
  Duration interval = const Duration(milliseconds: 300),
}) async {
  final sw = Stopwatch()..start();

  while (sw.elapsed < timeout) {
    try {
      final token = await FirebaseMessaging.instance.getAPNSToken();
      if (token != null && token.isNotEmpty) return token;
    } catch (e) {
      log(e.toString());
    }
    await Future<void>.delayed(interval);
  }
  return null;
}

Future<String?> _waitForFCMToken({
  Duration timeout = const Duration(seconds: 10),
  Duration interval = const Duration(milliseconds: 300),
}) async {
  final sw = Stopwatch()..start();

  while (sw.elapsed < timeout) {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) return token;
    } catch (e) {
      log(e.toString());
    }
    await Future<void>.delayed(interval);
  }
  return null;
}

Future<void> fcmInit() async {
  if (Platform.isIOS) {
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    await FirebaseMessaging.instance.getNotificationSettings();
  }

  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  if (Platform.isIOS) {
    final apns = await _waitForApnsToken();
    log("APNs token: $apns");
  }

  final fcmToken = await _waitForFCMToken();
  log("FCM token: $fcmToken");
}
