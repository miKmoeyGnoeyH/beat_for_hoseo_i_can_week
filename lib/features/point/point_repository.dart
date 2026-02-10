import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:beat/shared/services/index.dart';

class PointRepository {
  Future<int> fetchPointBalance(String authorization) async {
    try {
      final response = await _apiService.get(
        endpoint: DotEnvService.instance.fetchPointBalance,
        header: {"authorization": authorization},
      );

      switch (response.statusCode) {
        case 200:
          final String decoded = utf8.decode(response.bodyBytes);
          final Map<String, dynamic> responseBody = jsonDecode(decoded);
          final int pointBalance = responseBody["point"];
          return pointBalance;
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
      log("AuthenticationRepository : signIn() : ${e.toString()}");
      rethrow;
    }
  }

  final APIService _apiService = APIService();
}
