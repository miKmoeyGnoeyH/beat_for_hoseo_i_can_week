import 'dart:developer';

import 'package:beat/entities/leaderboard/leaderboard_model.dart';
import 'package:beat/entities/quest/index.dart';
import 'package:beat/features/quest/index.dart';
import 'package:get/get.dart';

import 'leaderboard_repository.dart';

class MemberWalkRankingListController extends GetxController with StateMixin {
  static MemberWalkRankingListController get to => Get.find<MemberWalkRankingListController>();

  MemberWalkRankingListController() {
    change(null, status: RxStatus.empty());
  }

  Future<void> walkRankingMember(String authorization) async {
    change(state, status: RxStatus.loading());

    try {
      final List<MemberRankingInfoDto> walkRankingMemberList = await leaderboardRepository
          .walkRankingMember(authorization);
      change(walkRankingMemberList, status: RxStatus.success());
    } catch (e) {
      log("member_walk_ranking_list_controller.dart: walkRankingMember() : ${e.toString()}");
      _didInitialFetch = false;
      change(state, status: RxStatus.error(e.toString()));
      rethrow;
    }
  }

  Future<void> fetchWalkRankingMemberOnce(String authorization) async {
    if (_didInitialFetch) return;
    _didInitialFetch = true;
    await walkRankingMember(authorization);
  }

  final LeaderboardRepository leaderboardRepository = LeaderboardRepository();
  bool _didInitialFetch = false;
}
