import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import '../../entities/profile/index.dart';
import '../../shared/index.dart';

class ProfileRepository {
  ProfileRepository();

  Future<ProfileModel> fetchData(String authorization) async {
    try {
      final response = await _apiService.get(
        endpoint: DotEnvService.instance.profile,
        header: {"Content-Type": "application/json", "authorization": authorization},
      );

      switch (response.statusCode) {
        case 200:
          final String decoded = utf8.decode(response.bodyBytes);
          final Map<String, dynamic> responseBody = jsonDecode(decoded);

          return ProfileModel.fromJson(responseBody);
        case 400:
          throw BEATException(
            title: LocalizationService.instance.errorSignInFailed,
            message: LocalizationService.instance.errorWrongIDOrPassword,
          );
        case 401:
          throw BEATTokenExpired();
        default:
          throw BEATExceptionUnknown();
      }
    } on TimeoutException {
      throw BEATTimeoutException();
    } catch (e) {
      log("ProfileRepository : fetchData() : ${e.toString()}");
      rethrow;
    }
  }

  final APIService _apiService = APIService();
}
