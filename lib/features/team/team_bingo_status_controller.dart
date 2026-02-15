import 'dart:developer';

import 'package:beat/entities/team/index.dart';
import 'package:beat/features/team/team_bingo_status_repository.dart';
import 'package:beat/features/team/team_bingo_status_repository.dart';
import 'package:get/get.dart';

class TeamBingoStatusController extends GetxController with StateMixin {
  static TeamBingoStatusController get to => Get.find<TeamBingoStatusController>();

  TeamBingoStatusController() {
    change(null, status: RxStatus.empty());
  }

  Future<void> fetchTeamBingoStatus(String authorization) async {
    change(state, status: RxStatus.loading());

    try {
      final List<TeamBingoStatusModel> teamBingoStatusList = await noticeRepository.fetchTeamBingoStatus(authorization, teamId!);
      change(teamBingoStatusList, status: RxStatus.success());
    } catch (e) {
      log("team_bingo_status_controller.dart: fetchTeamBingoStatus() : ${e.toString()}");
      change(state, status: RxStatus.error(e.toString()));
      rethrow;
    }
  }

  final TeamBingoStatusRepository noticeRepository = TeamBingoStatusRepository();
  int? teamId;
}