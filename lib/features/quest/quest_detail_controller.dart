import 'dart:developer';

import 'package:beat/entities/quest/index.dart';
import 'package:get/get.dart';

import 'quest_detail_repository.dart';

class QuestDetailController extends GetxController with StateMixin {
  QuestDetailController() {
    change(null, status: RxStatus.empty());
  }

  static QuestDetailController get to => Get.find<QuestDetailController>();
  QuestInfoView? questInfoView;

  Future<void> fetchQuestDetail(String authorization) async {
    change(state, status: RxStatus.loading());

    try {
      final QuestDetailModel questDetailModel = await questDetailRepository
          .fetchQuestDetail(
            authorization,
            questInfoView!.questType,
            questInfoView!.questId!,
          );
      change(questDetailModel, status: RxStatus.success());
    } catch (e) {
      log("quest_list_controller.dart: fetchQuestList() : ${e.toString()}");
      change(state, status: RxStatus.error(e.toString()));
      rethrow;
    }
  }

  Future<void> clearQuestDetail() async {
    change(null, status: RxStatus.empty());
  }

  final QuestDetailRepository questDetailRepository = QuestDetailRepository();
}
