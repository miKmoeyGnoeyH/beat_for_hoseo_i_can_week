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
    change(state, status: RxStatus.loading());

    try {
      final List<QuestModel> questList = await questListRepository
          .fetchQuestList(authorization);

      // throw Exception();

      log(questList.toString());

      change(questList, status: RxStatus.success());
    } catch (e) {
      log("quest_list_controller.dart: fetchQuestList() : ${e.toString()}");
      _didInitialFetch = false;
      change(state, status: RxStatus.error(e.toString()));
      rethrow;
    }
  }

  Future<void> fetchQuestListTest(String authorization) async {
    change(state, status: RxStatus.loading());

    try {
      final List<QuestModel> questList = await questListRepository
          .fetchQuestListTest(authorization);

      for (var quest in questList) {
        log(quest.toJsonString());
      }

      change(questList, status: RxStatus.success());
    } catch (e) {
      log("quest_list_controller.dart: fetchQuestList() : ${e.toString()}");
      _didInitialFetch = false;
      change(state, status: RxStatus.error(e.toString()));
      rethrow;
    }
  }

  Future<void> fetchQuestListOnce(String authorization) async {
    if (_didInitialFetch) return;
    _didInitialFetch = true;
    await fetchQuestList(authorization);
  }

  Future<void> clearQuestList() async {
    change(null, status: RxStatus.empty());
    _didInitialFetch = false;
  }

  final QuestListRepository questListRepository = QuestListRepository();
  bool _didInitialFetch = false;
}
