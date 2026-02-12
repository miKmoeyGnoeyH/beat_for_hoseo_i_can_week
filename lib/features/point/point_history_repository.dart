import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:beat/entities/point/index.dart';
import 'package:beat/shared/services/index.dart';

class PointHistoryRepository {
  Future<List<PointHistoryModel>> fetchPointHistory(String authorization, int memberId) async {
    try {
      final response = await _apiService.get(
        endpoint:
            "${DotEnvService.instance.fetchPointHistory}?memberId=$memberId",
        header: {"authorization": authorization},
      );

      log("PointHistoryRepository : fetchPointHistory() : ${response.body}");

      switch (response.statusCode) {
        case 200:
          final String decoded = utf8.decode(response.bodyBytes);
          List<PointHistoryModel> pointHistoryList = [];

          for (var item in jsonDecode(decoded)) {
            pointHistoryList.add(PointHistoryModel.fromJson(item));
          }

          return pointHistoryList;

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
