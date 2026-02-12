import 'dart:developer';

import 'package:beat/entities/point/index.dart';
import 'package:get/get.dart';

import 'point_history_repository.dart';

class PointHistoryController extends GetxController with StateMixin {
  static PointHistoryController get to => Get.find<PointHistoryController>();

  PointHistoryController() {
    change(null, status: RxStatus.empty());
  }

  Future<void> fetchPointHistory(String authorization, int memberId) async {
    change(state, status: RxStatus.loading());

    try {
      final List<PointHistoryModel> pointHistoryList = await pointHistoryRepository.fetchPointHistory(authorization, memberId);
      change(pointHistoryList, status: RxStatus.success());
    } catch (e) {
      log("point_history_controller.dart: fetchPointHistory() : ${e.toString()}");
      change(state, status: RxStatus.error(e.toString()));
      rethrow;
    }
  }

  final PointHistoryRepository pointHistoryRepository = PointHistoryRepository();
}