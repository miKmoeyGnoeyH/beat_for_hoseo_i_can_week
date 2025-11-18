import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// [SharedPreferences] 엔트리 포인트인 싱글톤 클래스입니다.
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
  Future<bool> saveUser(String id, String password, String authorization) async {
    final userMap = {
      'id': id,
      'password': password,
      'authorization': authorization,
    };

    return await _prefs.setString(_userKey, jsonEncode(userMap));
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


  PrefsService._internal();
}
