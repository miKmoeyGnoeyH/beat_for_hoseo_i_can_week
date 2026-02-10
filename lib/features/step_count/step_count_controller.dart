import 'dart:async';
import 'dart:io';

import 'package:beat/features/step_count/health_kit_steps.dart';
import 'package:beat/shared/index.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pedometer/pedometer.dart';

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
  static const MethodChannel _androidMethodChannel = MethodChannel(
    "beat/steps",
  );
  static const EventChannel _androidEventsChannel = EventChannel(
    "beat/steps_events",
  );

  StreamSubscription? _sub;

  /// iOS Specific Step Count Stream
  /// iOS에서는 네이티브 코드를 통해 HealthKit의 걸음 수를 전달받아 앱 실행 시의 걸음 수 baseline을 설정
  /// 다만, 이 경우 실시간 걸음수 동기화는 불가능함
  /// 따라서 UI Isolate에서 Pedometer 패키지를 사용해 걸음 수 증분을 기록, 오늘 총 걸음 수는 baseline + 증분으로 계산
  /// 앱이 백그라운드로 전환되면 Pedometer 패키지의 걸음 수 증분 계산은 중지
  /// 다시 앱이 포어그라운드로 전환됐을 때 다시 HealthKit에 누적된 걸음 수를 전달받아 baseline을 갱신,
  /// Pedometer 패키지를 통한 걸음 수 증분 계산 재개
  /// 오늘 걸음 수는 이전과 마찬가지로 baseline + 증분
  /// 위 방식을 통해 걸음 수가 "실시간으로 반영되는 것처럼" 사용자를 속임
  int _iOSBaseline = 0;
  int? _iOSStepsAfterBoot;
  // int _iOSIncrement = 0;
  Stream<StepCount>? _iOSStepCountStream;
  bool _isiOSServiceRunning = false;

  StepCountController();

  Future<void> startService() async {
    if (Platform.isAndroid) {
      await _androidMethodChannel.invokeMethod("startService");
      await _refreshOnce();
      _listenEvents();
    } else if (Platform.isIOS) {
      if (_isiOSServiceRunning) return;
      await HealthKitSteps.requestAuth();
      await HealthKitSteps.startBGDelivery();

      final (ymd, baseline) = await PrefsService.instance.getiOSBaseline();

      if (ymd == null || baseline == null) {
        _iOSBaseline = await _getHelthKitStepsAndUseCachedAsFallback();
        PrefsService.instance.setiOSBaseline(DateTime.now(), _iOSBaseline);
      } else {
        final int newBaseline = await _getHelthKitStepsAndUseCachedAsFallback();

        if ((newBaseline - baseline) > stepCount) {
          _stepCount = newBaseline - baseline;
        }
      }

      _startPedometerStreamiOS();
      _isiOSServiceRunning = true;
    } else {
      throw BEATExceptionPlatformNotSupported();
    }
  }

  /// Android startService
  Future<void> _refreshOnce() async {
    final v = await _androidMethodChannel.invokeMethod('getTodaySteps') ?? 0;
    _stepCount = v;
  }

  void _listenEvents() {
    _sub ??= _androidEventsChannel
        .receiveBroadcastStream()
        .listen((dynamic v) {
          if (v is int) _stepCount = v;
          if (v is num) _stepCount = v.toInt();
        });
  }

  /// iOS startService
  /// HealthKit에서 오늘 걸음 수를 가져오되,
  /// 실패할 경우 캐시된 오늘 걸음 수를 반환하는 함수
  Future<int> _getHelthKitStepsAndUseCachedAsFallback() async {
    final cached = await HealthKitSteps.getCachedTodaySteps();
    int newBaseline = cached;

    try {
      final fresh = await HealthKitSteps.getTodaySteps();
      if (fresh > 0) newBaseline = fresh;
    } catch (_) {}

    return newBaseline;
  }

  /// iOS에서, 앱이 백그라운드에서 포어그라운드로 전환되었을 때 실행되는 함수
  /// Proper Ref Count: 1
  /// - init 페이지에서, 앱 라이프사이클 변경 시
  void onStateChangedBG2FGiOS() async {
    if (!Platform.isIOS) return;
    if (!_isiOSServiceRunning) return;

    final (ymd, baseline) = await PrefsService.instance.getiOSBaseline();

    if (ymd == null || baseline == null) {
      /// 날짜 혹은 baseline이 null인 경우
      /// 1. 앱 실행 후, startService가 완전히 끝나기 전에 백그라운드 -> 포어그라운드 전환된 경우
      /// 2. 앱 실행 후, 임의로 내부 저장소를 비운 경우
      /// 이므로, 최초 실행 시와 동일한 로직을 적용
      _stepCount = 0;
      _iOSBaseline = await _getHelthKitStepsAndUseCachedAsFallback();
      PrefsService.instance.setiOSBaseline(DateTime.now(), _iOSBaseline);
    } else if (ymd.day != DateTime.now().day) {
      /// 저장된 날짜가 다른 경우
      /// 1. 자정이 지난 경우
      /// 이므로, 오늘 걸음 수를 다시 측정해야 함.
      /// 기본적으로 최초 실행 시의 동작과 동일하지만, 앱을 설치한 이후, 정상적으로 사용한 이후 날짜가 지난 것이므로
      /// 현재 걸음 수를 HealthKit의 값으로 그대로 사용한다.
      _iOSBaseline = await _getHelthKitStepsAndUseCachedAsFallback();
      PrefsService.instance.setiOSBaseline(DateTime.now(), _iOSBaseline);
      _stepCount = _iOSBaseline;
    } else {
      /// 위 경우 모두 아닌 경우
      /// 1. 앱을 정상적으로 사용하던 중, 날짜가 변경되기 전 백그라운드 -> 포어그라운드 전환된 경우
      /// 이므로, HealthKit에서 걸음 수를 다시 전달받고
      /// 이전에 저장된 baseline과 비교,
      /// UI Isolate에서 측정한 증분보다 증가값이 크다면
      /// (앱이 포어그라운드에 있을 때 측정한 걸음 수보다 더 많이 걸은 경우)
      /// _iOSIncrement를 갱신해 백그라운드에서 증가한 걸음 수 만큼 보정해준다.
      final int newBaseline = await _getHelthKitStepsAndUseCachedAsFallback();

      if ((newBaseline - baseline) > stepCount) {
        _stepCount = newBaseline - baseline;
      }
    }

    _startPedometerStreamiOS();
  }

  /// iOS에서 앱이 포어그라운드에서 백그라운드로 전환되었을 때 실행되는 함수
  /// Pedometer 패키지의 걸음 수 스트림을 중지
  /// 여기에서는 _iOSStepsAfterBoot만 초기화하고 나머지는 초기화하지 않는데,
  /// 이는 나머지 두 변수들이 백그라운드 -> 포어그라운드 전환 시 로직을 처리하기 위해 필요하기 때문이다.
  /// 나머지 두 변수는 [onStateChangedBG2FGiOS]에서 처리된다.
  /// /// Proper Ref Count: 1
  /// - init 페이지에서, 앱 라이프사이클 변경 시
  void onStateChangedFG2BGiOS() async {
    if (!Platform.isIOS) return;
    if (!_isiOSServiceRunning) return;
    _iOSStepsAfterBoot = null;
    _iOSStepCountStream = null;
  }

  /// iOS Only 걸음 수 스트림 구독
  /// Proper Ref Count: 2
  /// - 앱 실행 시, startService에서
  /// - 백그라운드 -> 포어그라운드 전환 시, onStateChangedBG2FGiOS에서
  void _startPedometerStreamiOS() {
    if (!Platform.isIOS) return;
    _iOSStepCountStream = Pedometer.stepCountStream;
    _iOSStepCountStream!.listen(_oniOSStepCount).onError((_) {});
  }

  /// iOS Only 걸음 수 이벤트 핸들러
  void _oniOSStepCount(StepCount event) {
    if (_iOSStepsAfterBoot == null) {
      _iOSStepsAfterBoot = event.steps;
      return;
    }

    final int increment = event.steps - _iOSStepsAfterBoot!;
    _iOSStepsAfterBoot = event.steps;
    _stepCount = increment < 0 ? stepCount : stepCount + increment;
  }

  Future<void> stopService() async {
    if (Platform.isAndroid) {
      await _androidMethodChannel.invokeMethod("stopService");
      await _sub?.cancel();
      _sub = null;
    } else if (Platform.isIOS) {
      _iOSStepsAfterBoot = null;
      _iOSStepCountStream = null;
      _isiOSServiceRunning = false;
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
