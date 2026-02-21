import 'dart:developer';

import 'package:beat/entities/leaderboard/leaderboard_model.dart';
import 'package:beat/entities/quest/index.dart';
import 'package:beat/features/quest/index.dart';
import 'package:get/get.dart';

import 'leaderboard_repository.dart';

class TeamWalkRankingListController extends GetxController with StateMixin {
  static TeamWalkRankingListController get to => Get.find<TeamWalkRankingListController>();

  TeamWalkRankingListController() {
    change(null, status: RxStatus.empty());
  }

  Future<void> walkRankingTeam(String authorization) async {
    change(state, status: RxStatus.loading());

    try {
      final List<TeamRankingInfoDto> teamWalkRankingList = await leaderboardRepository
          .walkRankingTeam(authorization);
      change(teamWalkRankingList, status: RxStatus.success());
    } catch (e) {
      log("team_walk_ranking_controller.dart: walkRankingTeam() : ${e.toString()}");
      _didInitialFetch = false;
      change(state, status: RxStatus.error(e.toString()));
      rethrow;
    }
  }

  Future<void> fetchWalkRankingTeamOnce(String authorization) async {
    if (_didInitialFetch) return;
    _didInitialFetch = true;
    await walkRankingTeam(authorization);
  }

  final LeaderboardRepository leaderboardRepository = LeaderboardRepository();
  bool _didInitialFetch = false;
}
