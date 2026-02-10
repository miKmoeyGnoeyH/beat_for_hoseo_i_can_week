import 'dart:developer';

import 'package:beat/entities/quest/index.dart';
import 'package:beat/features/quest/index.dart';
import 'package:get/get.dart';

class QuestListController extends GetxController with StateMixin {
  static QuestListController get to => Get.find<QuestListController>();

  QuestListController() {
    change(null, status: RxStatus.empty());
  }

  Future<void> fetchQuestList(String authorization) async {
    change(null, status: RxStatus.loading());

    try {
      final List<QuestModel> questList = await questListRepository.fetchQuestList(authorization);
      log("quest_list_controller.dart: fetchQuestList() : ${questList.toString()}");
      change(questList, status: RxStatus.success());
    } catch (e) {
      log("quest_list_controller.dart: fetchQuestList() : ${e.toString()}");
      change(state, status: RxStatus.error(e.toString()));
      rethrow;
    }
  }

  final QuestListRepository questListRepository = QuestListRepository();
}