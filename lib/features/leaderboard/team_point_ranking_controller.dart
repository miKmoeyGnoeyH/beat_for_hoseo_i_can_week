import 'dart:developer';

import 'package:beat/entities/leaderboard/leaderboard_model.dart';
import 'package:beat/entities/quest/index.dart';
import 'package:beat/features/leaderboard/index.dart';
import 'package:beat/features/quest/index.dart';
import 'package:get/get.dart';

import 'leaderboard_repository.dart';

class TeamPointRankingListController extends GetxController with StateMixin {
  static TeamPointRankingListController get to => Get.find<TeamPointRankingListController>();

  TeamPointRankingListController() {
    change(null, status: RxStatus.empty());
  }

  Future<void> pointRankingTeam(String authorization) async {
    change(state, status: RxStatus.loading());

    try {
      final List<TeamRankingInfoDto> pointRankingTeamList = await leaderboardRepository
          .pointRankingTeam(authorization);
      change(pointRankingTeamList, status: RxStatus.success());
    } catch (e) {
      log("point_ranking_team_controller.dart: pointRankingTeam() : ${e.toString()}");
      _didInitialFetch = false;
      change(state, status: RxStatus.error(e.toString()));
      rethrow;
    }
  }

  Future<void> fetchPointRankingTeamOnce(String authorization) async {
    if (_didInitialFetch) return;
    _didInitialFetch = true;
    await pointRankingTeam(authorization);
  }

  final LeaderboardRepository leaderboardRepository = LeaderboardRepository();
  bool _didInitialFetch = false;
}
