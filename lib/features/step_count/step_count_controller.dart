import 'dart:async';
import 'dart:io';

import 'package:beat/features/step_count/health_kit_steps.dart';
import 'package:beat/shared/index.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 걸음 수 관리를 위한 GetxController.
/// 안드로이드용 컨트롤러, iOS용 컨트롤러를 따로 구현하기보다는
/// 단일 컨트롤러 내부에서 OS 종류에 따라 분기하는 편이 더 나아보임.
/// OS별 컨트롤러를 따로 두게 되면 이후에 걸음 수를 참조해야 하는 모든 부분에서 OS 종류를 확인하고
/// 그에 맞게 따로 호출해야 하기 때문.
/// 컨트롤러 자체를 UI와 비즈니스 로직 사이의 인터페이스로 사용하고,
/// UI로부터 비즈니스 로직의 구현 세부사항을 은닉한다.
class StepCountController extends GetxController {
  static StepCountController get to => Get.find<StepCountController>();

  final Rx<int> _stepCount = 0.obs;
  int get stepCount => _stepCount.value;
  set _stepCount(int value) => _stepCount.value = value;

  /// Android Specific Method Channel
  /// 안드로이드에서는 네이티브에서 센서 데이터를 수집/측정하고
  /// 이를 메소드 채널로 전달
  static const MethodChannel _method = MethodChannel("beat/steps");
  static const EventChannel _events = EventChannel("beat/steps_events");

  /// iOS Specific Step Count Stream
  /// iOS에서는 네이티브 코드를 통해 HealthKit의 걸음 수를 전달받아 앱 실행 시의 걸음 수 baseline을 설정
  /// 다만, 이 경우 실시간 걸음수 동기화는 불가능함
  /// 따라서 UI Isolate에서 Pedometer 패키지를 사용해 걸음 수 증분을 기록, 오늘 총 걸음 수는 baseline + 증분으로 계산
  /// 앱이 백그라운드로 전환되면 Pedometer 패키지의 걸음 수 증분 계산은 중지
  /// 다시 앱이 포어그라운드로 전환됐을 때 다시 HealthKit에 누적된 걸음 수를 전달받아 baseline을 갱신,
  /// Pedometer 패키지를 통한 걸음 수 증분 계산 재개
  /// 오늘 걸음 수는 이전과 마찬가지로 baseline + 증분
  /// 위 방식을 통해 걸음 수가 "실시간으로 반영되는 것처럼" 사용자를 속임
  StreamSubscription? _sub;

  StepCountController();

  Future<void> startService() async {
    if (Platform.isAndroid) {
      await _method.invokeMethod("startService");
      await refreshOnce();
      _listenEvents();
    } else if (Platform.isIOS) {
      await HealthKitSteps.requestAuth();
      await HealthKitSteps.startBGDelivery();

      _stepCount = await HealthKitSteps.getCachedTodaySteps();
      _stepCount = await HealthKitSteps.getTodaySteps();
    } else {
      throw BEATExceptionPlatformNotSupported();
    }
  }

  /// Android startService
  Future<void> refreshOnce() async {
    final v = await _method.invokeMethod('getTodaySteps') ?? 0;
    _stepCount = v;
  }

  void _listenEvents() {
    _sub ??= _events.receiveBroadcastStream().listen((dynamic v) {
      if (v is int) _stepCount = v;
      if (v is num) _stepCount = v.toInt();
    });
  }

  Future<void> stopService() async {
    if (Platform.isAndroid) {
      await _method.invokeMethod("stopService");
      await _sub?.cancel();
      _sub = null;
    } else if (Platform.isIOS) {
    } else {
      throw BEATExceptionPlatformNotSupported();
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
