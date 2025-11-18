import 'dart:developer';

import 'package:beat/entities/authentication/authentication_model.dart';
import 'package:beat/shared/index.dart';
import 'package:beat/shared/services/exception_service.dart';

class AuthenticationRepository {
  AuthenticationRepository();

  Future<AuthenticationModel> signIn({
    required String id,
    required String nickname,
  }) async {
    try {
      final response = await _apiService.post(
        endpoint: DotEnvService.instance.signIn,
        body: {"studentId": id, "nickname": nickname},
      );

      switch (response.statusCode) {
        case 200:
          return AuthenticationModel(
            id: id,
            nickname: nickname,
            authorization: response.headers['authorization']!,
          );
        case 400:
          throw BEATException(
            title: LocalizationService.instance.signInSignInFailed,
            message: LocalizationService.instance.signInErrorWrongIDOrPassword,
          );
        default:
          throw BEATException(title: LocalizationService.instance.errorsUnknownError);
      }
    } catch (e) {
      log("AuthenticationRepository : signIn() : ${e.toString()}");
      rethrow;
    }
  }

  final APIService _apiService = APIService();
}
