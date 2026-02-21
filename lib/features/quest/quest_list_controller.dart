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

  final QuestListRepository questListRepository = QuestListRepository();
  bool _didInitialFetch = false;
}
