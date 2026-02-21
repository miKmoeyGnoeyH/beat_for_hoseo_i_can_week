import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:beat/shared/index.dart';

import '../../entities/leaderboard/leaderboard_model.dart';

class LeaderboardRepository {
  LeaderboardRepository();

  Future<List<TeamRankingInfoDto>> walkRankingTeam(String authorization) async {
    try {
      final response = await _apiService.get(
        endpoint: "${DotEnvService.instance.walkRanking}/TEAM",
        header: {"Content-Type": "application/json", "authorization": authorization},
      );

      switch (response.statusCode) {
        case 200:
          final List<TeamRankingInfoDto> walkRankingList = [];
          final String decoded = utf8.decode(response.bodyBytes);
          final Map<String, dynamic> responseBody = jsonDecode(decoded);
          final List<dynamic> teamRankingInfoDtoList = responseBody["teamRankingInfoDtoList"];

          for (var teamRanking in teamRankingInfoDtoList) {
            walkRankingList.add(TeamRankingInfoDto.fromJson(teamRanking));
          }

          return walkRankingList;
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
      log("LeaderboardRepository : walkRankingTeam() : ${e.toString()}");
      rethrow;
    }
  }

  Future<List<MemberRankingInfoDto>> walkRankingMember(String authorization) async {
    try {
      final response = await _apiService.get(
        endpoint: "${DotEnvService.instance.walkRanking}/MEMBER",
        header: {"Content-Type": "application/json", "authorization": authorization},
      );

      switch (response.statusCode) {
        case 200:
          final List<MemberRankingInfoDto> walkRankingList = [];
          final String decoded = utf8.decode(response.bodyBytes);
          final Map<String, dynamic> responseBody = jsonDecode(decoded);
          final List<dynamic> memberRankingInfoDtoList = responseBody["memberRankingInfoDtoList"];

          for (var memberRanking in memberRankingInfoDtoList) {
            walkRankingList.add(MemberRankingInfoDto.fromJson(memberRanking));
          }

          return walkRankingList;
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
      log("LeaderboardRepository : walkRankingMember() : ${e.toString()}");
      rethrow;
    }
  }

  Future<List<TeamRankingInfoDto>> pointRankingTeam(String authorization) async {
    try {
      final response = await _apiService.get(
        endpoint: "${DotEnvService.instance.pointRanking}/team",
        header: {"Content-Type": "application/json", "authorization": authorization},
      );

      switch (response.statusCode) {
        case 200:
          final List<TeamRankingInfoDto> pointRankingList = [];
          final String decoded = utf8.decode(response.bodyBytes);
          final Map<String, dynamic> responseBody = jsonDecode(decoded);
          final List<dynamic> teamRankingInfoDtoList = responseBody["teamRankingInfoDtoList"];

          for (var teamRanking in teamRankingInfoDtoList) {
            pointRankingList.add(TeamRankingInfoDto.fromJson(teamRanking));
          }

          return pointRankingList;
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
      log("LeaderboardRepository : pointRankingTeam() : ${e.toString()}");
      rethrow;
    }
  }

  Future<List<MemberRankingInfoDto>> pointRankingMember(String authorization) async {
    try {
      final response = await _apiService.get(
        endpoint: "${DotEnvService.instance.pointRanking}/MEMBER",
        header: {"Content-Type": "application/json", "authorization": authorization},
      );

      switch (response.statusCode) {
        case 200:
          final List<MemberRankingInfoDto> pointRankingList = [];
          final String decoded = utf8.decode(response.bodyBytes);
          final Map<String, dynamic> responseBody = jsonDecode(decoded);
          final List<dynamic> memberRankingInfoDtoList = responseBody["memberRankingInfoDtoList"];

          for (var memberRanking in memberRankingInfoDtoList) {
            pointRankingList.add(MemberRankingInfoDto.fromJson(memberRanking));
          }

          return pointRankingList;
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
      log("LeaderboardRepository : pointRankingMember() : ${e.toString()}");
      rethrow;
    }
  }

  Future<List<BingoRankingInfoDto>> bingoRanking(String authorization, String campus) async {
    try {
      final response = await _apiService.get(
        endpoint: "${DotEnvService.instance.bingoRanking}/$campus",
        header: {"Content-Type": "application/json", "authorization": authorization},
      );

      switch (response.statusCode) {
        case 200:
          final List<BingoRankingInfoDto> bingoRankingList = [];
          final String decoded = utf8.decode(response.bodyBytes);
          final Map<String, dynamic> responseBody = jsonDecode(decoded);
          final List<dynamic> asanRankingInfoDtoList = responseBody["teamRankingInfoDtoList"];

          for (var asanRanking in asanRankingInfoDtoList) {
            bingoRankingList.add(BingoRankingInfoDto.fromJson(asanRanking));
          }

          return bingoRankingList;
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
      log("LeaderboardRepository : bingoRankingAsan() : ${e.toString()}");
      rethrow;
    }
  }

  Future<List<BingoRankingInfoDto>> bingoRankingCheonan(String authorization) async {
    try {
      final response = await _apiService.get(
        endpoint: "${DotEnvService.instance.pointRanking}/CHEONAN",
        header: {"Content-Type": "application/json", "authorization": authorization},
      );

      switch (response.statusCode) {
        case 200:
          final List<BingoRankingInfoDto> bingoRankingList = [];
          final String decoded = utf8.decode(response.bodyBytes);
          final Map<String, dynamic> responseBody = jsonDecode(decoded);
          final List<dynamic> cheonanRankingInfoDtoList = responseBody["teamRankingInfoDtoList"];

          for (var cheonanRanking in cheonanRankingInfoDtoList) {
            bingoRankingList.add(BingoRankingInfoDto.fromJson(cheonanRanking));
          }

          return bingoRankingList;
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
      log("LeaderboardRepository : bingoRankingCheonan() : ${e.toString()}");
      rethrow;
    }
  }

  final APIService _apiService = APIService();
}