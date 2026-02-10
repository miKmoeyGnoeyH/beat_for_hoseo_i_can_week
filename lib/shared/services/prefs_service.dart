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

  PrefsService._internal();
}
