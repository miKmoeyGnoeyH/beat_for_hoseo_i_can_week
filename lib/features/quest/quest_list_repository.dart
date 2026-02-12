import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:beat/entities/quest/index.dart';
import 'package:beat/shared/index.dart';

class QuestListRepository {
  QuestListRepository();

  Future<List<QuestModel>> fetchQuestList(String authorization) async {
    try {
      final response = await _apiService.get(
        endpoint: DotEnvService.instance.fetchQuestList,
        header: {"authorization": authorization},
      );

      // log(response.body);

      switch (response.statusCode) {
        case 200:
          final List<QuestModel> questList = [];
          final String decoded = utf8.decode(response.bodyBytes);
          final List<dynamic> responseBody = jsonDecode(decoded);

          for (var quest in responseBody) {
            questList.add(QuestModel.fromJson(quest));
          }

          return questList;
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
      log("QuestListRepository : fetchQuestList() : ${e.toString()}");
      rethrow;
    }
  }

  final APIService _apiService = APIService();
}