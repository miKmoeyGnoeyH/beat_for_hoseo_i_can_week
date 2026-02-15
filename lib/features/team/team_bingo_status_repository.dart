import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:beat/shared/services/index.dart';

import '../../entities/team/index.dart';

class TeamBingoStatusRepository {
  Future<List<TeamBingoStatusModel>> fetchTeamBingoStatus(String authorization, int teamId) async {
    try {
      final response = await _apiService.get(
        endpoint:
        "${DotEnvService.instance.teamBingoStatus}?teamId=$teamId",
        header: {"authorization": authorization},
      );

      log("TeamBingoStatusRepository : fetchTeamBingoStatus() : ${response.body}");

      switch (response.statusCode) {
        case 200:
          final String decoded = utf8.decode(response.bodyBytes);
          final List<TeamBingoStatusModel> teamBingoStatusList = (jsonDecode(decoded) as List)
              .map((item) => TeamBingoStatusModel.fromJson(item))
              .toList();

          return teamBingoStatusList;

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
      log("TeamBingoStatusRepository : fetchTeamBingoStatus() : ${e.toString()}");
      rethrow;
    }
  }

  final APIService _apiService = APIService();
}
