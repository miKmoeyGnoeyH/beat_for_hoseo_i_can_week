import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:beat/entities/authentication/user_model.dart';
import 'package:beat/shared/index.dart';

class AuthenticationRepository {
  AuthenticationRepository();

  Future<UserModel> signIn({
    required String id,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        endpoint: DotEnvService.instance.signIn,
        header: {"Content-Type": "application/json"},
        body: jsonEncode({"accountId": id, "accountPw": password}),
      );

      log("AuthenticationRepository: signIn: endpoint: ${DotEnvService.instance.signIn}");
      log("AuthenticationRepository: signIn: response.body: ${response.body}");

      switch (response.statusCode) {
        case 200:
          final String decoded = utf8.decode(response.bodyBytes);
          final Map<String, dynamic> responseBody = jsonDecode(decoded);
          final int memberId = responseBody['memberId'];
          final String name = responseBody['name'];
          final String studentId = responseBody['studentId'];
          final String email = responseBody['email'];
          final String department = responseBody['department'];
          final String nickname = responseBody['nickname'];
          final String campus = responseBody['campus'];
          final String studentType = responseBody['studentType'];
          final String teamName = responseBody['teamName'];
          final String authorization = response.headers['authorization']!;
          final String refreshToken = response.headers['refresh-token']!;

          return UserModel(
            memberId: memberId,
            name: name,
            studentId: studentId,
            email: email,
            department: department,
            nickname: nickname,
            campus: campus,
            studentType: studentType,
            teamName: teamName,
            authorization: authorization,
            refreshToken: refreshToken,
          );
        case 400:
          throw BEATException(
            title: LocalizationService.instance.errorSignInFailed,
            message: LocalizationService.instance.errorWrongIDOrPassword,
          );
        default:
          throw BEATException(title: LocalizationService.instance.errorUnknown);
      }
    } on TimeoutException {
      throw BEATException(
        title: LocalizationService.instance.errorTimeout,
        message: LocalizationService.instance.errorConnectivity,
      );
    } catch (e) {
      log("AuthenticationRepository : signIn() : ${e.toString()}");
      rethrow;
    }
  }

  Future<String> reissueToken(String refreshToken) async {
    try {
      final response = await _apiService.get(
        endpoint: DotEnvService.instance.reissueToken,
        header: {
          "Content-type": "application/json",
          "refresh-token": refreshToken,
        },
      );

      log("${response.statusCode} ${response.body}");

      switch (response.statusCode) {
        case 200:
          final String authorization = response.headers['authorization']!;
          return authorization;
        case 400:
          throw BEATException(title: LocalizationService.instance.errorUnknown);
        default:
          throw BEATException(title: LocalizationService.instance.errorUnknown);
      }
    } on TimeoutException {
      throw BEATException(
        title: LocalizationService.instance.errorTimeout,
        message: LocalizationService.instance.errorConnectivity,
      );
    } catch (e) {
      log("AuthenticationRepository : reissueToken() : ${e.toString()}");
      rethrow;
    }
  }

  Future<bool> registerFCMToken(String authorization, String fcmToken) async {
    try {
      final response = await _apiService.post(
        endpoint: "${DotEnvService.instance.registerFCMToken}?token=$fcmToken",
        header: {
          "Content-type": "application/json",
          "authorization": authorization,
        },
      );

      log("AuthenticationRepository: registerFCMToken: endpoint: ${DotEnvService.instance.registerFCMToken}?token=$fcmToken");
      log("AuthenticationRepository: registerFCMToken: response.body: ${response.body}");

      switch (response.statusCode) {
        case 200:
          return true;
        case 400:
          throw BEATException(title: LocalizationService.instance.errorUnknown);
        /// registerFCMToken은 로그인 성공 직후(authorization 발급 직후)에만 유일하게 호출되므로
        /// 401 에러는 고려할 필요가 없음.
        // case 401:
        //   throw BEATTokenExpired();
        default:
          throw BEATException(title: LocalizationService.instance.errorUnknown);
      }
    } on TimeoutException {
      throw BEATException(
        title: LocalizationService.instance.errorTimeout,
        message: LocalizationService.instance.errorConnectivity,
      );
    } catch (e) {
      log("AuthenticationRepository : registerFCMToken() : ${e.toString()}");
      rethrow;
    }
  }

  final APIService _apiService = APIService();
}
