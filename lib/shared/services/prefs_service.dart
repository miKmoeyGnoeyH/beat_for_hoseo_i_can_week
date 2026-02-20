import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// [SharedPreferences] 엔트리 포인트인 싱글톤 클래스입니다.
/// [SharedPreferences] 객체에 직접 접근하지 않고, 이 클래스의 래퍼 함수를 통해 접근합니다.
/// [SharedPreferences.instance]로 객체를 가져옵니다.
///
/// [init]: [SharedPreferences] 객체를 초기화합니다. 앱 시작 시 `main()`에서 호출합니다.
///
/// [saveUser, getUser]: 최근 로그인한 사용자 정보를 저장하고, 불러옵니다.
/// 사용자 정보는 id, password, authorization을 Map으로 저장합니다.
class PrefsService {
  static final PrefsService instance = PrefsService._internal();
  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// isfirstLaunch
  static const String _isFirstLaunchKey = 'is_first_launch';

  Future<void> setIsFirstLaunch(bool isFirstLaunch) async {
    await _prefs.setBool(_isFirstLaunchKey, isFirstLaunch);
  }

  bool getIsFirstLaunch() {
    return _prefs.getBool(_isFirstLaunchKey) ?? true;
  }

  /// User Management
  /// 최근 로그인한 사용자 정보를 저장하고, 불러옵니다.
  static const String _userKey = 'user';

  /// [Future &lt;bool&gt; saveUser]: 최근 로그인한 사용자 정보를 저장하고, 성공 여부를 boolean으로 반환합니다.
  /// 사용자 정보는 id, password, authorization을 Map으로 저장합니다.
  Future<bool> setUser(Map<String, dynamic> user) async {
    return await _prefs.setString(_userKey, jsonEncode(user));
  }

  /// [Map&lt;String, dynamic&gt;? getUser]: 최근 로그인한 사용자 정보를 Map으로 반환합니다.
  /// null을 반환한다면, 최근 로그인한 사용자 정보가 없다는 뜻입니다.
  Map<String, dynamic>? getUser() {
    final String? userString = _prefs.getString(_userKey);

    if (userString == null) {
      return null;
    }

    return jsonDecode(userString);
  }

  /// Steps Management
  static const String _iOSBaselineYmdKey = "ios_baseline_Ymd";
  static const String _iOSBaselineKey = "ios_baseline";

  Future<bool> setiOSBaseline(DateTime ymd, int baseline) async {
    await _prefs.setString(_iOSBaselineYmdKey, ymd.toIso8601String());
    return await _prefs.setInt(_iOSBaselineKey, baseline);
  }

  Future<(DateTime?, int?)> getiOSBaseline() async {
    final String? ymdString = _prefs.getString(_iOSBaselineYmdKey);
    final int? baseline = _prefs.getInt(_iOSBaselineKey);

    if (ymdString == null || baseline == null) {
      return (null, null);
    } else {
      return (DateTime.parse(ymdString), baseline);
    }
  }

  /// HealthKit snapshot
  static const String _outSnapshotKey = "out_snapshot";

  /// {
  ///   "outStepsSnapshot": int,
  ///   "outSnapshotYmd": String (ISO8601)
  /// }
  Future<bool> setOutSnapshot({
    int? outStepsSnapshot,
    DateTime? outSnapshotYmd,
  }) async {
    return await _prefs.setString(
      _outSnapshotKey,
      jsonEncode({
        "outStepsSnapshot": outStepsSnapshot,
        "outSnapshotYmd": outSnapshotYmd?.toIso8601String(),
      }),
    );
  }

  Future<(int?, DateTime?)> getOutSnapshot() async {
    final String? snapshotString = _prefs.getString(_outSnapshotKey);
    if (snapshotString == null) return (null, null);

    final Map<String, dynamic> m = jsonDecode(snapshotString);
    final steps = m["outStepsSnapshot"];
    final ymd = m["outSnapshotYmd"];

    if (steps == null || ymd == null) return (null, null);

    return (steps as int, DateTime.parse(ymd as String));
  }

  static const String _excludedStepsKey = "excluded_steps";

  Future<bool> setExcludedSteps(int baseline) async {
    return await _prefs.setInt(_excludedStepsKey, baseline);
  }

  Future<int?> getExcludedSteps() async {
    return _prefs.getInt(_excludedStepsKey);
  }

  static const String _isInCampusKey = "is_in_campus";

  Future<bool> setIsInCampus(bool isInCampus) async {
    return await _prefs.setBool(_isInCampusKey, isInCampus);
  }

  Future<bool> getIsInCampus() async {
    return _prefs.getBool(_isInCampusKey) ?? false;
  }

  PrefsService._internal();
}
