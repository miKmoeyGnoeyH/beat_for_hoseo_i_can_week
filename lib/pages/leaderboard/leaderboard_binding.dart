import 'package:beat/features/leaderboard/index.dart';
import 'package:get/get.dart';

class LeaderboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(TeamPointRankingListController());
    Get.put(MemberPointRankingListController());
    Get.put(TeamWalkRankingListController());
    Get.put(MemberWalkRankingListController());
    Get.put(BingoRankingListController());
  }
}