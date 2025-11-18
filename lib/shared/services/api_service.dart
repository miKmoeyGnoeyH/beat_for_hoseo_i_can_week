import 'dart:developer';
import 'package:http/http.dart' as http;

/// * 해당 설계와 구현은 아무 의미가 없음. 사용하지 말 것 *
///
/// [APIService]는 API 요청을 처리하는 서비스 클래스입니다.
/// GetX 패턴에서 상태 관리에는 Controller, Repository, Provider 세 개의 클래스가 관여합니다.
/// [APIService]는 API 통신을 간소화하고 추상화합니다.
/// 본 구현에서는 [APIService]가 모든 API 요청을 담당하며 Provider의 역할을 수행합니다.
/// 따로 Provider 클래스를 만들지 않습니다.
///
/// [APIService]에서는 API요청 후 어떤 가공도 거치지 않은 [https.Response] 객체를 반환합니다.
class APIService {
  APIService() {}

  Future<http.Response> get({
    required String endpoint,
    Map<String, String>? header,
  }) async {
    try {
      final Uri url = Uri.parse(endpoint);
      return await http
          .get(url, headers: header)
          .timeout(Duration(seconds: _timeoutDuration));
    } catch (e) {
      log("APIService : get() : ${e.toString()}");
      rethrow;
    }
  }

  Future<http.Response> post({
    required String endpoint,
    Map<String, String>? header,
    Object? body,
  }) async {
    try {
      final Uri url = Uri.parse(endpoint);
      return await http
          .post(url, headers: header, body: body)
          .timeout(Duration(seconds: _timeoutDuration));
    } catch (e) {
      log("APIService : post() : ${e.toString()}");
      rethrow;
    }
  }

  // late final String _baseURL;
  final int _timeoutDuration = 5;
}
