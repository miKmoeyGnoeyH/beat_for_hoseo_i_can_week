import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:beat/features/step_count/health_kit_steps.dart';
import 'package:beat/shared/index.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pedometer/pedometer.dart';

class StepCountController extends GetxController {
  static StepCountController get to => Get.find<StepCountController>();

  final Rx<int> _stepCount = 0.obs;
  int get stepCount => _stepCount.value;
  set _stepCount(int v) => _stepCount.value = v;

  final Rx<bool> _isInCampus = false.obs;
  bool get isInCampus => _isInCampus.value;
  set _isInCampus(bool v) => _isInCampus.value = v;

  static const MethodChannel _androidMethodChannel = MethodChannel("beat/steps");
  static const EventChannel _androidEventsChannel = EventChannel("beat/steps_events");

  StreamSubscription? _sub;

  static const MethodChannel _campusChannel = MethodChannel("beat/campus_location");

  StreamSubscription<StepCount>? _iOSSub;
  int? _iOSStepsAfterBoot;

  bool _isiOSServiceRunning = false;
  bool _campusHandlerRegistered = false;

  StepCountController();

  // -----------------------------
  // Public
  // -----------------------------

  Future<void> checkIsServiceRunningAndStartIfNot() async {
    if (Platform.isAndroid) {
      final bool isRunning =
          await _androidMethodChannel.invokeMethod("isServiceRunning") ?? false;
      if (!isRunning) await startService();
      return;
    }

    if (Platform.isIOS) {
      if (!_isiOSServiceRunning) {
        await startService();
      } else {
        await onStateChangedBG2FGiOS();
      }
      return;
    }

    throw BEATExceptionPlatformNotSupported();
  }

  Future<void> startService() async {
    if (Platform.isAndroid) {
      await _androidMethodChannel.invokeMethod("startService");
      await _refreshOnce();
      _listenEvents();
      return;
    }

    if (!Platform.isIOS) throw BEATExceptionPlatformNotSupported();
    if (_isiOSServiceRunning) return;

    await HealthKitSteps.requestAuth();
    await HealthKitSteps.startBGDelivery();

    _registerCampusHandler();
    await _campusChannel.invokeMethod("start");

    // Restore persisted campus state first
    final persistedIsInCampus = await PrefsService.instance.getIsInCampus();
    _isInCampus = persistedIsInCampus;

    // Sync "today state" without wiping persisted excluded/outSnapshot
    await _syncTodayStateIOS(source: "startService");

    // Pedometer stream policy: only when inside
    // await _stopPedometerStreamiOS();
    // if (isInCampus) _startPedometerStreamiOS();

    _isiOSServiceRunning = true;
  }

  Future<void> stopService() async {
    if (Platform.isAndroid) {
      await _androidMethodChannel.invokeMethod("stopService");
      await _sub?.cancel();
      _sub = null;
      return;
    }

    if (!Platform.isIOS) throw BEATExceptionPlatformNotSupported();

    await HealthKitSteps.stopBGDelivery();
    await _campusChannel.invokeMethod("stop");
    await _stopPedometerStreamiOS();
    _isiOSServiceRunning = false;
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  // -----------------------------
  // Android
  // -----------------------------

  Future<void> _refreshOnce() async {
    final v = await _androidMethodChannel.invokeMethod('getTodaySteps') ?? 0;
    _stepCount = (v is num) ? v.toInt() : (v as int);
  }

  void _listenEvents() {
    _sub ??= _androidEventsChannel.receiveBroadcastStream().listen((dynamic v) {
      if (v is int) _stepCount = v;
      if (v is num) _stepCount = v.toInt();
    });
  }

  // -----------------------------
  // iOS core helpers
  // -----------------------------

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<int> _getHealthKitStepsAndUseCachedAsFallback() async {
    try {
      final live = await HealthKitSteps.getTodaySteps();
      if (live > 0) return live;
    } catch (_) {}

    return await HealthKitSteps.getCachedTodaySteps();
  }

  Future<int> _calcBaseStepsFrom(int hkNow) async {
    final excluded = await PrefsService.instance.getExcludedSteps() ?? 0;
    return math.max(0, hkNow - excluded);
  }

  /// Policy:
  /// - Inside: show hkNow - excluded (typically excluded=0)
  /// - Outside: show 0
  Future<void> _renderIOS(int hkNow) async {
    if (isInCampus) {
      _stepCount = await _calcBaseStepsFrom(hkNow);
    } else {
      _stepCount = 0;
    }
  }

  /// This is the ONLY place that handles "new day" initialization.
  ///
  /// Policy:
  /// - If you are outside at new day: all today's hkNow counts as outside => excludedSteps = hkNow, UI=0.
  /// - If you are inside at new day: excludedSteps = 0, UI=hkNow.
  Future<void> _handleNewDayIOS({required int hkNow, required bool inCampusNow}) async {
    // Record baseline for consistency / debugging
    await PrefsService.instance.setiOSBaseline(DateTime.now(), hkNow);

    if (inCampusNow) {
      await PrefsService.instance.setExcludedSteps(0);
      await PrefsService.instance.setOutSnapshot(outStepsSnapshot: null, outSnapshotYmd: null);
      _isInCampus = true;
      await PrefsService.instance.setIsInCampus(true);

      await _stopPedometerStreamiOS();
      _stepCount = hkNow; // inside => counts
      _startPedometerStreamiOS();
    } else {
      // outside at the start of the day => exclude everything accumulated so far
      await PrefsService.instance.setExcludedSteps(hkNow);
      await PrefsService.instance.setOutSnapshot(
        outStepsSnapshot: hkNow,
        outSnapshotYmd: DateTime.now(),
      );
      _isInCampus = false;
      await PrefsService.instance.setIsInCampus(false);

      await _stopPedometerStreamiOS();
      _stepCount = 0;
    }
  }

  /// Make persisted state consistent for "today".
  /// - If baseline day != today => call _handleNewDayIOS(...) based on current isInCampus.
  /// - Else:
  ///   - If outside and outSnapshot missing => set it to hkNow (so deltaOutside works on next enter).
  ///   - Clamp excludedSteps to <= hkNow to avoid negative base.
  Future<void> _syncTodayStateIOS({required String source}) async {
    final now = DateTime.now();
    final hkNow = await _getHealthKitStepsAndUseCachedAsFallback();

    final (ymd, _) = await PrefsService.instance.getiOSBaseline();
    if (ymd == null || !_sameDay(ymd, now)) {
      await _handleNewDayIOS(hkNow: hkNow, inCampusNow: isInCampus);
      return;
    }

    // Same day: ensure outside snapshot exists if outside
    if (!isInCampus) {
      final (outSteps, outYmd) = await PrefsService.instance.getOutSnapshot();
      if (outSteps == null || outYmd == null || !_sameDay(outYmd, now)) {
        await PrefsService.instance.setOutSnapshot(
          outStepsSnapshot: hkNow,
          outSnapshotYmd: now,
        );
      }
    }

    // Clamp excluded
    final excluded = await PrefsService.instance.getExcludedSteps() ?? 0;
    if (excluded > hkNow) {
      await PrefsService.instance.setExcludedSteps(hkNow);
    }

    await _renderIOS(hkNow);
  }

  // -----------------------------
  // iOS campus events
  // -----------------------------

  void _registerCampusHandler() {
    if (_campusHandlerRegistered) return;
    _campusHandlerRegistered = true;

    _campusChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "campusOut":
          await onCampusExit();
          break;
        case "campusIn":
          await onCampusEnter();
          break;
      }
    });
  }

  Future<void> onCampusExit() async {
    if (!Platform.isIOS) return;

    _isInCampus = false;
    await PrefsService.instance.setIsInCampus(false);

    final hkNow = await _getHealthKitStepsAndUseCachedAsFallback();

    // snapshot the moment we became outside (always overwrite; it's the "outside start" anchor)
    await PrefsService.instance.setOutSnapshot(
      outStepsSnapshot: hkNow,
      outSnapshotYmd: DateTime.now(),
    );

    await _stopPedometerStreamiOS();
    _stepCount = 0; // UI policy: outside => 0
  }

  Future<void> onCampusEnter() async {
    if (!Platform.isIOS) return;

    final hkNow = await _getHealthKitStepsAndUseCachedAsFallback();
    final now = DateTime.now();

    // If baseline is not today, treat as new day first (based on "we were outside until this enter")
    final (baselineYmd, _) = await PrefsService.instance.getiOSBaseline();
    final baselineIsToday = baselineYmd != null && _sameDay(baselineYmd, now);

    final (outSteps, outYmd) = await PrefsService.instance.getOutSnapshot();
    final outIsToday = outYmd != null && _sameDay(outYmd, now);

    if (!baselineIsToday) {
      // You are entering campus on a new day.
      // Your policy: "before entering, you were outside" => exclude all hkNow.
      await PrefsService.instance.setExcludedSteps(hkNow);
      await PrefsService.instance.setiOSBaseline(now, hkNow);
      await PrefsService.instance.setOutSnapshot(outStepsSnapshot: null, outSnapshotYmd: null);

      _isInCampus = true;
      await PrefsService.instance.setIsInCampus(true);

      await _stopPedometerStreamiOS();
      _stepCount = 0;
      _startPedometerStreamiOS();
      return;
    }

    // Same-day enter:
    // If we don't have a valid out snapshot for today, be conservative: anchor it now (deltaOutside = 0)
    if (outSteps == null || outYmd == null || !outIsToday) {
      await PrefsService.instance.setOutSnapshot(outStepsSnapshot: hkNow, outSnapshotYmd: now);
    } else {
      // Compute outside delta and add to excluded
      final deltaOutside = math.max(0, hkNow - outSteps);
      final excluded = await PrefsService.instance.getExcludedSteps() ?? 0;
      final newExcluded = excluded + deltaOutside;
      await PrefsService.instance.setExcludedSteps(newExcluded);

      // Snapshot consumed
      await PrefsService.instance.setOutSnapshot(outStepsSnapshot: null, outSnapshotYmd: null);
    }

    _isInCampus = true;
    await PrefsService.instance.setIsInCampus(true);

    await _stopPedometerStreamiOS();
    _stepCount = await _calcBaseStepsFrom(hkNow);
    _startPedometerStreamiOS();
  }

  // -----------------------------
  // iOS lifecycle events
  // -----------------------------

  /// Called on BG -> FG
  Future<void> onStateChangedBG2FGiOS() async {
    if (!Platform.isIOS || !_isiOSServiceRunning) return;

    // final live = await HealthKitSteps.getTodaySteps();

    // resync day + render
    await _syncTodayStateIOS(source: "BG2FG");

    // pedometer policy
    await _stopPedometerStreamiOS();
    if (isInCampus) _startPedometerStreamiOS();
  }

  /// Called on FG -> BG
  void onStateChangedFG2BGiOS() async {
    if (!Platform.isIOS || !_isiOSServiceRunning) return;
    await _stopPedometerStreamiOS();
    _iOSStepsAfterBoot = null;
  }

  // -----------------------------
  // iOS pedometer stream
  // -----------------------------

  void _startPedometerStreamiOS() {
    if (!Platform.isIOS) return;
    if (_iOSSub != null) return;

    _iOSSub = Pedometer.stepCountStream.listen(
      _oniOSStepCount,
      onError: (_) {},
    );
  }

  Future<void> _stopPedometerStreamiOS() async {
    await _iOSSub?.cancel();
    _iOSSub = null;
    _iOSStepsAfterBoot = null;
  }

  void _oniOSStepCount(StepCount event) {
    // Hard policy: only count increments while inside
    if (!isInCampus) return;

    log("oniOSStepCount: steps=${event.steps}, time=${event.timeStamp}");

    if (_iOSStepsAfterBoot == null) {
      _iOSStepsAfterBoot = event.steps;
      return;
    }

    final inc = event.steps - _iOSStepsAfterBoot!;
    _iOSStepsAfterBoot = event.steps;

    if (inc < 0) return; // ignore weird resets
    _stepCount = stepCount + inc;
  }
}