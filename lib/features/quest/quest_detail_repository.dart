import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:beat/entities/quest/index.dart';

import '../../shared/index.dart';

class QuestDetailRepository {
  Future<QuestDetailModel> fetchQuestDetail(
    String authorization,
    QuestType questType,
    int questId,
  ) async {
    try {
      final response = await _apiService.get(
        endpoint:
            "${DotEnvService.instance.fetchQuestDetail}${questType.value}/detail/${questId.toString()}",
        header: {"authorization": authorization},
      );

      log(response.body);

      switch (response.statusCode) {
        case 200:
          final String decoded = utf8.decode(response.bodyBytes);
          final responseBody = jsonDecode(decoded);
          return QuestDetailModel.fromJson(responseBody);
        case 400:
          throw BEATException(title: LocalizationService.instance.errorUnknown);
        case 401:
          throw BEATTokenExpired();
        default:
          throw BEATException(title: LocalizationService.instance.errorUnknown);
      }
    } on TimeoutException {
      throw BEATException(
        title: LocalizationService.instance.errorTimeout,
        message: LocalizationService.instance.errorConnectivity,
      );
    } catch (e) {
      log("QuestDetailRepository : fetchQuestDetail() : ${e.toString()}");
      rethrow;
    }
  }

  final APIService _apiService = APIService();
}
