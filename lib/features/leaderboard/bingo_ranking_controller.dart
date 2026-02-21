import 'dart:developer';

import 'package:beat/entities/leaderboard/leaderboard_model.dart';
import 'package:beat/entities/quest/index.dart';
import 'package:beat/features/leaderboard/index.dart';
import 'package:beat/features/quest/index.dart';
import 'package:get/get.dart';

import 'leaderboard_repository.dart';

class BingoRankingListController extends GetxController with StateMixin {
  static BingoRankingListController get to => Get.find<BingoRankingListController>();

  BingoRankingListController() {
    change(null, status: RxStatus.empty());
  }

  Future<void> bingoRankingAsan(String authorization, String campus) async {
    change(state, status: RxStatus.loading());

    try {
      final List<BingoRankingInfoDto> bingoRankingList = await leaderboardRepository
          .bingoRanking(authorization, campus);
      change(bingoRankingList, status: RxStatus.success());
    } catch (e) {
      log("bingo_ranking_list_controller.dart: bingoRankingAsan() : ${e.toString()}");
      _didInitialFetch = false;
      change(state, status: RxStatus.error(e.toString()));
      rethrow;
    }
  }

  Future<void> fetchBingoRankingOnce(String authorization, String campus) async {
    if (_didInitialFetch) return;
    _didInitialFetch = true;
    await bingoRankingAsan(authorization, campus);
  }

  final LeaderboardRepository leaderboardRepository = LeaderboardRepository();
  bool _didInitialFetch = false;
}
