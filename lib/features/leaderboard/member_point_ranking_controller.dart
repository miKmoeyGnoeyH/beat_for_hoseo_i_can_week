import 'dart:developer';

import 'package:beat/entities/leaderboard/leaderboard_model.dart';
import 'package:beat/entities/quest/index.dart';
import 'package:beat/features/leaderboard/index.dart';
import 'package:beat/features/quest/index.dart';
import 'package:get/get.dart';

import 'leaderboard_repository.dart';

class MemberPointRankingListController extends GetxController with StateMixin {
  static MemberPointRankingListController get to => Get.find<MemberPointRankingListController>();

  MemberPointRankingListController() {
    change(null, status: RxStatus.empty());
  }

  Future<void> pointRankingMember(String authorization) async {
    change(state, status: RxStatus.loading());

    try {
      final List<MemberRankingInfoDto> memberPointRankingList = await leaderboardRepository
          .pointRankingMember(authorization);
      change(memberPointRankingList, status: RxStatus.success());
    } catch (e) {
      log("quest_list_controller.dart: pointRankingMember() : ${e.toString()}");
      _didInitialFetch = false;
      change(state, status: RxStatus.error(e.toString()));
      rethrow;
    }
  }

  Future<void> fetchPointRankingMemberOnce(String authorization) async {
    if (_didInitialFetch) return;
    _didInitialFetch = true;
    await pointRankingMember(authorization);
  }

  final LeaderboardRepository leaderboardRepository = LeaderboardRepository();
  bool _didInitialFetch = false;
}
