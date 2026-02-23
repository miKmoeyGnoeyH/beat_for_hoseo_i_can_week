import 'dart:developer';

import 'package:beat/shared/index.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'app.dart';
import 'features/step_count/index.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBGHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  if (message.notification != null) {
    log(
      '_firebaseMessagingBGHandler() : message.notification.title : ${message.notification!.title.toString()}',
    );
    log(
      '_firebaseMessagingBGHandler() : message.notification.body : ${message.notification!.body.toString()}',
    );
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingFGHandler(RemoteMessage message) async {
  if (message.notification != null) {
    log(
      '_firebaseMessagingFG() : message.notification.title : ${message.notification!.title.toString()}',
    );
    log(
      '_firebaseMessagingFG() : message.notification.body : ${message.notification!.body.toString()}',
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );

  await flutterLocalNotificationsPlugin.initialize(settings: initSettings);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBGHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      flutterLocalNotificationsPlugin.show(
        id: 0,
        title: message.notification!.title,
        body: message.notification!.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  });

  await LocalizationService.instance.init();
  await DotEnvService.instance.init();
  await PackageInfoService.instance.init();

  Get.put<DialogService>(DialogService(), permanent: true);
  Get.put<ExceptionService>(ExceptionService(), permanent: true);

  Get.put<StepCountController>(StepCountController(), permanent: true);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ko')],
      fallbackLocale: const Locale('en'),
      path: 'assets/translations',
      child: App(),
    ),
  );
}
