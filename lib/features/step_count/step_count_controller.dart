import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

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

  set _stepCount(int v) => _stepCount.value = v;

  final Rx<bool> _isInCampus = false.obs;

  bool get isInCampus => _isInCampus.value;

  set _isInCampus(bool v) => _isInCampus.value = v;

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
  static const MethodChannel _campusChannel = MethodChannel(
    "beat/campus_location",
  );

  bool _isiOSServiceRunning = false;

  /// 2026.02.21 Memo
  /// iOS의 걸음 수 측정 흐름
  /// - 앱 실행 시 HealthKit으로부터 오늘 걸음 수를 받아옴(healthKitSteps)
  /// - 앱이 백그라운드에서 포어그라운드로 전환 시 HealthKit으로부터 오늘 걸음 수 갱신(newHealthKitSteps)
  /// - 새로운 HealthKit 걸음 수와 기존 HealthKit 걸음 수의 차를 걸음 수에 더해 백그라운드에서 측정된 걸음 수를 보정(steps += newHealthKitSteps - healthKitSteps)
  /// - healKitSteps = newHealthKitSteps
  ///
  /// 유효 걸음 수 측정 범위 이탈 시?
  /// - 앱 실행 시 HealthKit으로부터 오늘 걸음 수를 받아옴(healthKitSteps)
  /// - UI Isolate에서 측정범위 이탈 감지 시, 해당 시점의 HealthKit 걸음 수를 저장(outSnapshot)
  /// - UI Isolate에서 측정범위 진입 감지 시, 해당 시점의 HealthKit 걸음 수를 저장(inSnapshot)
  /// - 이탈 시 걸음 수와 진입 시 걸음 수의 차이를 계산(inSnapshot - outSnapshot = excludedSteps)
  /// - 백그라운드 걸음 수 보정 시 HealthKit으로부터 걸음 수 갱신, steps = newHealthKitSteps - (healthKitSteps + excludedSteps)
  ///
  /// - newHealthKitSteps = steps + healthKitSteps + excludedSteps이고, healthKitSteps = newHealthKitSteps, excludesSteps는 변동 없을 때
  ///   기존 excludedSteps를 excludesSteps1, 새로 측정된 excludedSteps를 excludedSteps2,
  ///   오늘 유효 범위 바깥에서 측정된 걸음 수 excludedSteps1 + excludedSteps2 = excludedSteps'이라고 하면
  ///   이후 백그라운드 걸음 수 보정에서
  ///   steps2 = newHealthKitSteps2 - (healthKitSteps2 + excludedSteps')
  ///   steps2 = newHealthKitSteps2 - ((steps1 + healthKitSteps1 + excludedSteps1) + (excludedSteps1 + excludedSteps2))이므로
  ///   excludedSteps1을 중복으로 계산하게 된다. 따라서
  ///   (1) 백그라운드 걸음 수 보정 시 healthKitSteps를 newHealthKitSteps로 갱신하고, excludedSteps를 0으로 초기화한다
  ///   (2) 백그라운드 걸음 수 보정 시 healthKitSteps를 newHealthKitSteps로 갱신하지 않고, excludedSteps도 갱신하지 않는다
  ///   둘 중 하나를 택해 적용해야 함.
  ///
  /// 추가로 고려해야 할 시나리오
  /// 1. 앱 실행 -> 유효 범위 이탈 -> 걸음 수 변경 -> 유효 범위 진입 -> 걸음 수 변경 -> 유효 범위 이탈
  /// - 앱 실행 시 HealthKit으로부터 오늘 걸음 수를 받아옴(healthKitSteps)
  /// - 측정범위 이탈 시, 해당 시점의 HealthKit 걸음 수, 시간을 저장(outSnapshot, outSnapshotYmd)
  /// - 측정범위 진입 시, 해당 시점의 HealthKit 걸음 수, 시간을 저장(inSnapshot, inSnapshotYmd)
  /// - 이탈 시 걸음 수와 진입 시 걸음 수의 차이를 계산(inSnapshot - outSnapshot = excludedSteps)
  /// - 측정범위 이탈 시, 해당 시점의 HealthKit 걸음 수, 시간을 저장(outSnapshot, outSnapshotYmd)
  /// - 측정범위 진입 시, 해당 시점의 HealthKit 걸음 수, 시간을 저장(inSnapshot, inSnapshotYmd)
  /// - 이탈 시 걸음 수와 진입 시 걸음 수의 차이를 계산, 이전 excludedSteps에 추가(excludedSteps += inSnapshot - outSnapshot)
  /// - 백그라운드 걸음 수 보정 시 HealthKit으로부터 걸음 수 갱신, steps = newHealthKitSteps - (healthKitSteps + excludedSteps)
  /// - excludedSteps에는 유효 범위 바깥에서 측정된 걸음 수만이 누적되어 있으므로, 문제가 생기지 않음
  ///
  /// 2. 앱 실행 -> 유효 범위 이탈 -> 걸음 수 변경 -> 날짜 변경 -> 유효 범위 진입
  /// - 앱 실행 시 HealthKit으로부터 오늘 걸음 수를 받아옴(healthKitSteps)
  /// - 측정범위 이탈 시, 해당 시점의 HealthKit 걸음 수, 시간을 저장(outSnapshot, outSnapshotYmd)
  /// - 날짜가 변경되어 HealthKit 걸음 수가 초기화됨
  /// - 측정범위 진입 시, 해당 시점의 HealthKit 걸음 수, 시간을 저장(inSnapshot, inSnapshotYmd)
  /// - excludedSteps += inSnapshot - outSnapshot인데, 이 경우 두 가지 문제가 발생함
  ///   1. inSnapshot이 outSnapshot보다 작은 경우
  ///   - inSnapshot - outSnapshot < 0이 되어 excludedSteps가 감소, 부정확한 값이 저장됨
  ///   - 하지만 이 경우 inSnapshot은 모두 유효 범위 바깥에서 기록된 값이므로,
  ///     inSnapshotYmd와 outSnapshotYmd를 비교, 날짜가 다른 경우 excludedSteps = inSnapshot으로 초기화
  ///   - 이후 흐름은 이전과 같음
  ///
  ///   2. inSnapshot이 outSnapshot보다 큰 경우
  ///   - 이 경우에는 inSnapshot - outSnapshot > 0이지만, 이틀치 excludedSteps가 누적되어 이후 걸음 수 보정이 부정확해짐
  ///   - 이 경우에도 마찬가지로 날짜를 비교, 날짜가 다를 경우 excludedSteps = inSnapshot으로 초기화
  ///   - 이후 흐름은 이전과 같음
  ///
  /// 앱 흐름(중간정리)
  /// - 1, 2에 의해, iOS 걸음 수 측정 흐름은 다음과 같이 정리할 수 있음
  /// - healthKitSteps = 0, excludedSteps = 0, outSnapshot = null, outSanpshotYmd = null
  /// - 앱 실행 시 HealthKit으로부터 오늘 걸음 수를 저장(healthKitSteps)
  /// - 측정범위 이탈 시, 해당 시점의 HealthKit 걸음 수와 시간을 저장(outSnapshot, outSnapshotYmd)
  /// - 측정범위 진입 시, 해당 시점의 HealthKit 걸음 수와 시간을 읽어옴(inSnapshot, inSnapshotYmd)
  /// - if (outSnapshotYmd != inSnapshotYmd) excludedSteps = inSnapshot, healthKitSteps = 0, steps = 0, outSnapshot = null, outSnapshotYmd = null
  /// - else excludedSteps += inSnapshot - outSnapshot
  /// - 백그라운드 걸음 수 보정 시, steps += newHealthKitSteps - healthKitSteps - excludedSteps,
  ///   healthKitSteps = newHealthKitSteps, excludedSteps = 0
  ///
  /// 문제점
  /// - 앱 오류로 인해 측정범위 이탈/진입 이벤트를 중복으로 수신할 수 있음
  /// - 따라서 isInCampus 플래그를 함께 저장
  /// - 측정범위 이탈/진입 이벤트 수신 시, isInCampus가 이미 false/true인 경우 해당 이벤트를 무시함
  ///
  /// 최종 앱 흐름
  /// - healthKitSteps = 0, excludedSteps = 0, outSnapshot = null, outSanpshotYmd = null, isInCampus = 네이티브로부터 수신한 값
  /// - 앱 실행 시 HealthKit으로부터 오늘 걸음 수를 저장(healthKitSteps)
  /// - 측정범위 이탈 시, 해당 시점의 HealthKit 걸음 수와 시간을 저장(outSnapshot, outSnapshotYmd), isInCampus = false
  ///   이미 isInCampus가 false인 경우, 이벤트를 무시
  /// - 측정범위 진입 시, 해당 시점의 HealthKit 걸음 수와 시간을 읽어옴(inSnapshot, inSnapshotYmd), isInCampus = true
  ///   이미 isInCampus가 true인 경우, 이벤트를 무시
  /// - if (outSnapshotYmd != inSnapshotYmd) excludedSteps = inSnapshot, healthKitSteps = 0, steps = 0
  /// - else excludedSteps += inSnapshot - outSnapshot
  /// - 백그라운드 걸음 수 보정 시, steps += newHealthKitSteps - healthKitSteps - excludedSteps,
  ///   healthKitSteps = newHealthKitSteps, excludedSteps = 0
  ///
  /// 2026.02.21 Memo +
  /// 1. 유효 범위 재진입 후, 앱이 즉시 백그라운드에서 포어그라운드로 전환되지 않기 때문에,
  ///   유효 범위 재진입 -> pedometer 재시작 -> steps에 증분 누적 -> BG2FG -> 백그라운드 걸음 수 보정 시
  ///   보정 걸음 수에 pedometer로 측정된 증분이 포함되어 증분이 중복됨.
  ///   따라서 백그라운드 걸음 수 보정 로직은 steps += newHealthKitSteps - healthKitSteps - excludedSteps가 아닌
  ///   steps = max(0, newHealthKitSteps - excludedSteps)로 계산해야함
  /// 2. BG2FG에서 excludedSteps를 초기화하면
  ///   유효 범위 바깥에서 BG2FG가 여러 번 호출 -> BG2FG에서 excludedSteps가 초기화 -> 유효 범위 재진입 -> 백그라운드 걸음 수 보정 시
  ///   excludedSteps가 반영되기 전에 초기화되어 값이 부정확해짐, 보정이 부정확해짐
  ///   따라서 excludedSteps 초기화는 날짜 변경 시에만 수행되어야 함
  /// 3. outSnapshot 값을 사용한 뒤에는 반드시 null로 폐기할 것
  /// 4. 유효 범위 진입/이탈 이벤트 수행 시 flag값을 사용해 원자적으로 처리할 것

  int _healthKitSteps = 0;
  int _excludedSteps = 0;
  int? _iOSStepsAfterBoot;

  // int _iOSIncrement = 0;
  StreamSubscription<StepCount>? _iOSStepCountStreamSub;

  bool _isCampusHandlerRegistered = false;

  Future<void> startService() async {
    if (Platform.isAndroid) {
      await _androidMethodChannel.invokeMethod("startService");
      await _refreshOnce();

      _registerCampusHandler();

      try {
        final isInsideCampus = await _campusChannel.invokeMethod(
          "getLastInsideCached",
        );
        if (isInsideCampus != null) _isInCampus = isInsideCampus;
      } on PlatformException catch (e) {
        log(
          "step_count_controller: startService: Failed to get initial campus location: ${e.message}",
        );
        _isInCampus = false;
      } finally {
        log("step_count_controller: startService: isInCampus: $_isInCampus");
        PrefsService.instance.setIsInCampus(isInCampus);
      }

      _listenEvents();
    } else if (Platform.isIOS) {
      if (_isiOSServiceRunning) return;
      _isiOSServiceRunning = true;

      await HealthKitSteps.requestAuth();
      await HealthKitSteps.startBGDelivery();

      /// 내부 저장소에 저장된 healthKitSteps와 날짜를 읽어옴
      // final (ymd, healthKitSteps) = await PrefsService.instance.getHealthKitSteps();

      /// 날짜가 없거나, healthKitSteps가 없는 경우
      /// 데이터가 손상되었거나 최초 실행임
      /// 따라서 값을 새로 저장해줌
      // if (ymd == null || healthKitSteps == null) {
      //   _healthKitSteps = await _getHelthKitStepsAndUseCachedAsFallback();
      //   PrefsService.instance.setHealthKitSteps(DateTime.now(), _healthKitSteps);
      /// 둘 다 있는 경우
      /// 앱을 종료했다 다시 실행했거나, 로그아웃했다 다시 로그인
      /// 앱이 종료되어있는 동안 추가된 걸음 수를 반영해줘야 함
      /// 로직 수정 필요:
      /// 유효 범위 이탈 전 앱 종료 -> 유효 범위 바깥에서 걸음 수 누적 -> 유효 범위 재진입 -> 앱 재실행
      /// 이 경우 유효 범위 바깥에서 누적된 걸음 수가 제외되지 않음.
      /// 위에서 세운 최종 앱 흐름에 따라 변경할 것
      /// 앱이 종료되어있는 동안 누적된 걸음 수는 무시하는 것이 맞다.
      /// healthKitSteps 갱신만 할 것
      // } else {
      //   _healthKitSteps = await _getHelthKitStepsAndUseCachedAsFallback();
      //   PrefsService.instance.setHealthKitSteps(DateTime.now(), _healthKitSteps);
      //   // if ((newHealthKitSteps - healthKitSteps) > stepCount) {
      //   //   _stepCount = newHealthKitSteps - healthKitSteps;
      //   // }
      // }

      /// 위치 채널 핸들러 등록
      _registerCampusHandler();

      /// 위치 스트림 시작
      await _campusChannel.invokeMethod("start");

      /// 캠퍼스 내에 있는지 여부 최초 1회 초기화
      try {
        final isInsideCampus = await _campusChannel.invokeMethod(
          "isInsideCampus",
        );
        if (isInsideCampus != null) _isInCampus = isInsideCampus;
      } on PlatformException catch (e) {
        log(
          "step_count_controller: startService: Failed to get initial campus location: ${e.message}",
        );
        _isInCampus = false;
      } finally {
        log("step_count_controller: startService: isInCampus: $_isInCampus");
        PrefsService.instance.setIsInCampus(isInCampus);
      }

      /// healthKitSteps 초기화
      /// 서비스가 실행되고 있지 않는 동안 누적된 걸음수는 무시할 것이므로 그냥 HealthKit 데이터로 갱신한다.
      _healthKitSteps = await _getHelthKitStepsAndUseCachedAsFallback();
      PrefsService.instance.setHealthKitSteps(_healthKitSteps, DateTime.now());

      /// 오늘 걸음 수 초기화
      /// 날짜, 걸음 수 둘 중 하나라도 null이거나 날짜가 다르면 앱 최초 실행이거나 데이터 손상됨 혹은 날짜 변경이다.
      /// 0으로 초기화해준다.
      final (steps, ymd) = await PrefsService.instance.getSteps();
      if (ymd == null || steps == null || ymd.day != DateTime.now().day) {
        _stepCount = 0;
        PrefsService.instance.setSteps(0, DateTime.now());
      } else {
        _stepCount = steps;
      }

      /// 유효 범위 내라면 UI용 걸음 수 스트림을 시작
      if (isInCampus) {
        _startPedometerStreamiOS();
      } else {
        await _stopPedometerStreamiOS();
      }
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
    _sub ??= _androidEventsChannel.receiveBroadcastStream().listen((dynamic v) {
      if (v is int) _stepCount = v;
      if (v is num) _stepCount = v.toInt();
    });
  }

  /// iOS startService
  bool _handlingCampusEvent = false;

  Future<void> onCampusExit() async {
    if (!Platform.isIOS) return;
    if (_handlingCampusEvent) return;
    if (!isInCampus) return;

    _handlingCampusEvent = true;
    try {
      _isInCampus = false;
      PrefsService.instance.setIsInCampus(isInCampus);

      _stopPedometerStreamiOS();

      final int outSnapshot = await _getHelthKitStepsAndUseCachedAsFallback();
      final DateTime outSnapshotYmd = DateTime.now();
      PrefsService.instance.setOutSnapshot(outSnapshot, outSnapshotYmd);
    } finally {
      _handlingCampusEvent = false;
    }
  }

  Future<void> onCampusEnter() async {
    if (!Platform.isIOS) return;
    if (_handlingCampusEvent) return;
    if (isInCampus) return;

    _handlingCampusEvent = true;
    try {
      _isInCampus = true;
      PrefsService.instance.setIsInCampus(isInCampus);

      final int inSnapshot = await _getHelthKitStepsAndUseCachedAsFallback();
      final DateTime inSnapshotYmd = DateTime.now();

      await _calcExcludedStepsAndSave(inSnapshot, inSnapshotYmd);
      _startPedometerStreamiOS();
    } finally {
      _handlingCampusEvent = false;
    }
  }

  /// - if (outSnapshotYmd != inSnapshotYmd) excludedSteps = inSnapshot, healthKitSteps = 0, steps = 0
  /// - else excludedSteps += inSnapshot - outSnapshot
  /// 하지만 이 함수에서는 steps는 초기화하지 않는다. UI Steps를 백그라운드/포어그라운드 구분 없이 빈번히 접근하는 것이 버그/꼬임을 일으킬 수 있다고 생각함.
  /// UI Steps는 최대한 UI 갱신이 꼭 필요한 곳에서만 갱신하도록 한다.
  Future<void> _calcExcludedStepsAndSave(
    int inSnapshot,
    DateTime inSnapshotYmd,
  ) async {
    final (outSnapshot, outSnapshotYmd) = await PrefsService.instance
        .getOutSnapshot();

    /// outSnapshot, outSnapshotYmd 둘 중 하나라도 null인 경우
    /// 데이터가 손상됐거나 유효범위 바깥에서 앱을 설치한 후 유효범위 진입함
    if (outSnapshot == null ||
        outSnapshotYmd == null ||
        outSnapshotYmd.day != inSnapshotYmd.day) {
      _excludedSteps = inSnapshot;
      PrefsService.instance.setExcludedSteps(_excludedSteps);

      _healthKitSteps = 0;
      PrefsService.instance.setHealthKitSteps(_healthKitSteps, DateTime.now());
    } else {
      /// 그 외 경우
      /// inSnapshot이 outSnapshot보다 작은 경우는 날짜가 변경됐을 때 뿐이다.
      /// 날짜 변경은 위 분기에서 처리했으므로
      /// 이 분기에서 inSnapshot - outSnapshot은 반드시 양수이다.
      _excludedSteps += inSnapshot - outSnapshot;
      PrefsService.instance.setExcludedSteps(_excludedSteps);
    }

    /// outSnapshot을 사용한 뒤에는 반드시 폐기
    PrefsService.instance.setOutSnapshot(null, null);
  }

  void _registerCampusHandler() {
    if (_isCampusHandlerRegistered) return;
    _isCampusHandlerRegistered = true;

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

  Future<void> onStateChangedBG2FG() async {
    if (Platform.isAndroid) {
      await onStateChangedBG2FGAndroid();
    } else if (Platform.isIOS) {
      await onStateChangedBG2FGiOS();
    } else {
      return;
    }
  }

  Future<void> onStateChangedBG2FGAndroid() async {
    await _refreshOnce();

    try {
      final isInsideCampus = await _campusChannel.invokeMethod(
        "getLastInsideCached",
      );
      if (isInsideCampus != null) _isInCampus = isInsideCampus;
    } on PlatformException catch (e) {
      log(
        "step_count_controller: startService: Failed to get initial campus location: ${e.message}",
      );
      _isInCampus = false;
    } finally {
      log("step_count_controller: startService: isInCampus: $_isInCampus");
      PrefsService.instance.setIsInCampus(isInCampus);
    }
  }

  /// iOS에서, 앱이 백그라운드에서 포어그라운드로 전환되었을 때 실행되는 함수
  /// Proper Ref Count: 1
  /// - init 페이지에서, 앱 라이프사이클 변경 시
  ///
  /// 2026.02.22 Memo
  /// - 백그라운드 걸음 수 보정 시, steps += newHealthKitSteps - healthKitSteps - excludedSteps,
  ///   healthKitSteps = newHealthKitSteps, excludedSteps = 0
  ///
  /// 2026.02.21 Memo +
  /// 1. 유효 범위 재진입 후, 앱이 즉시 백그라운드에서 포어그라운드로 전환되지 않기 때문에,
  ///   유효 범위 재진입 -> pedometer 재시작 -> steps에 증분 누적 -> BG2FG -> 백그라운드 걸음 수 보정 시
  ///   보정 걸음 수에 pedometer로 측정된 증분이 포함되어 증분이 중복됨.
  ///   따라서 백그라운드 걸음 수 보정 로직은 steps += newHealthKitSteps - healthKitSteps - excludedSteps가 아닌
  ///   steps = max(0, newHealthKitSteps - excludedSteps)로 계산해야함
  /// 2. BG2FG에서 excludedSteps를 초기화하면
  ///   유효 범위 바깥에서 BG2FG가 여러 번 호출 -> BG2FG에서 excludedSteps가 초기화 -> 유효 범위 재진입 -> 백그라운드 걸음 수 보정 시
  ///   excludedSteps가 반영되기 전에 초기화되어 값이 부정확해짐, 보정이 부정확해짐
  ///   따라서 excludedSteps 초기화는 날짜 변경 시에만 수행되어야 함
  /// 3. outSnapshot 값을 사용한 뒤에는 반드시 null로 폐기할 것
  ///
  /// 앱이 백그라운드에서 포어그라운드로 전환되는 것이므로, 사용자가 걸음 수 UI를 확인할 가능성이 있음.
  /// 이 시점에 UI Steps를 갱신한다.
  /// 불필요한 백그라운드 연산을 줄이고 코드가 꼬이는 것을 방지하기 위함.
  Future<void> onStateChangedBG2FGiOS() async {
    if (!Platform.isIOS) return;
    if (!_isiOSServiceRunning) return;

    final DateTime now = DateTime.now();
    final (steps, stepsYmd) = await PrefsService.instance.getSteps();
    final (healthKitSteps, healthKitStepsYmd) = await PrefsService.instance
        .getHealthKitSteps();
    final excludedSteps = await PrefsService.instance.getExcludedSteps();

    /// steps, stepsYmd, healthKitSteps, healthKitStepsYmd 중 하나라도 null인 경우
    /// 데이터가 손상됐음
    /// 기본값으로 초기화
    if (healthKitSteps == null ||
        healthKitStepsYmd == null ||
        steps == null ||
        stepsYmd == null) {
      _stepCount = 0;
      PrefsService.instance.setSteps(0, now);

      _healthKitSteps = await _getHelthKitStepsAndUseCachedAsFallback();
      PrefsService.instance.setHealthKitSteps(_healthKitSteps, now);
    } else if (stepsYmd.day != now.day || healthKitStepsYmd.day != now.day) {
      /// 현재 날짜와 마지막으로 저장된 healthKitStepsYmd의 날짜가 다른 경우
      /// 날짜가 변경됐음.
      /// 이 경우, isInCampus의 값에 따라 다르게 처리해야 한다.
      /// - isInCampus가 false인 경우, 사용자에게는 걸음 수가 "측정되지 않는 것처럼" 보여야 함.
      ///   마지막으로 저장된 healthKitSteps가 오늘이 아니고, isInCampus가 false라는 것은
      ///   사용자가 유효 범위에서 마지막으로 앱을 사용했고, 유효 범위 이탈/날짜 변경 후 유효 범위 바깥에서 앱을 사용하고 있는 것이므로
      ///   이 시점에서 유효 범위 내에서 측정된 걸음 수는 0이어야 한다.
      ///   Ui steps를 0, healthKitSteps = 0으로 초기화한다.
      ///   - healthKitSteps를 newHealthKitSteps로 갱신할 경우, 이후 excludedSteps 계산에서 중복으로 제외될 가능성이 있다.
      ///     따라서 이 시점에서는 healthKitSteps를 0으로 초기화하고, 이후 onCampusEnter 이벤트 이후 백그라운드 걸음 수 보정에서
      ///     excludedSteps를 한 번에 계산하도록 한다.
      ///   excludedSteps 계산은 onCampusExit/onCampusEnter에 맡긴다.
      _stepCount = 0;
      PrefsService.instance.setSteps(0, now);

      _healthKitSteps = 0;
      PrefsService.instance.setHealthKitSteps(_healthKitSteps, now);
    } else if (excludedSteps == null) {
      /// 저장된 excludedSteps가 없는 경우,
      /// 데이터가 손상됐거나 유효 범위 이탈 후 아직 유효 범위 내에 진입하지 않아
      /// onCampusEnter에서 excludedSteps가 계산되지 않은 경우이다. 이 경우 아무 것도 하지 않는다.
      /// (유효 범위 바깥에서는 걸음 수가 "측정되지 않는 것처럼" 보여야 하므로)
    } else {
      /// 위 경우가 모두 아니라면, 앱이 정상적으로 구동됐고, 유효 범위 이탈 후 날짜가 변경되기 전에 유효 범위 내에 진입했으며,
      /// 앱을 포어그라운드로 전환했다는 뜻이다.
      /// 백그라운드 걸음 수 보정 로직을 수행한다.
      _healthKitSteps = await _getHelthKitStepsAndUseCachedAsFallback();
      PrefsService.instance.setHealthKitSteps(_healthKitSteps, now);

      _stepCount = math.max(0, _healthKitSteps - excludedSteps);
      PrefsService.instance.setSteps(stepCount, now);
    }

    /// 유효 범위 내라면 걸음 수 스트림을 시작한다.
    if (isInCampus) {
      _startPedometerStreamiOS();
    }
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

    await _stopPedometerStreamiOS();
    _iOSStepsAfterBoot = null;
    _iOSStepCountStreamSub = null;
  }

  /// iOS Only 걸음 수 스트림 구독
  /// Proper Ref Count: 2
  /// - 앱 실행 시, startService에서
  /// - 백그라운드 -> 포어그라운드 전환 시, onStateChangedBG2FGiOS에서
  void _startPedometerStreamiOS() {
    if (!Platform.isIOS) return;
    if (_iOSStepCountStreamSub != null) return;

    _iOSStepCountStreamSub = Pedometer.stepCountStream.listen(
      _oniOSStepCount,
      onError: (_) {},
    );
  }

  Future<void> _stopPedometerStreamiOS() async {
    await _iOSStepCountStreamSub?.cancel();
    _iOSStepCountStreamSub = null;
    _iOSStepsAfterBoot = null;
  }

  /// iOS Only 걸음 수 이벤트 핸들러
  Future<void> _oniOSStepCount(StepCount event) async {
    if (!_isiOSServiceRunning) return;
    if (!isInCampus) return;

    final bool isActivityPermissionGranted = await PermissionService.instance
        .isActivityPermissionGranted();
    final bool isLocationPermissionGranted = Platform.isIOS
        ? await PermissionService.instance
              .isLocationWhenInUsePermissionGranted()
        : await PermissionService.instance.isLocationAlwaysPermissionGranted();

    if (!isActivityPermissionGranted || !isLocationPermissionGranted) return;

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
      await _campusChannel.invokeMethod("stop");
      await _stopPedometerStreamiOS();
      _iOSStepsAfterBoot = null;
      _isiOSServiceRunning = false;
    } else {
      throw BEATExceptionPlatformNotSupported();
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    _iOSStepCountStreamSub?.cancel();
    super.onClose();
  }

  Future<void> checkIsServiceRunningAndStartIfNot() async {
    if (Platform.isAndroid) {
      final bool isRunning =
          await _androidMethodChannel.invokeMethod("isServiceRunning") ?? false;

      log(
        "StepCountController: checkIsServiceRunningAndStartIfNot: isRunning: $isRunning",
      );

      if (!isRunning) await startService();
      return;
    } else if (Platform.isIOS) {
      if (!_isiOSServiceRunning) {
        await startService();
      }
    } else {
      throw BEATExceptionPlatformNotSupported();
    }

    onStateChangedBG2FG();
  }
}
