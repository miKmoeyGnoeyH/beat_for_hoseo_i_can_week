import 'dart:developer';

import 'package:beat/features/point/point_repository.dart';
import 'package:get/get.dart';

class PointController extends GetxController with StateMixin<int> {
  static PointController get to => Get.find<PointController>();

  PointController() {
    change(null, status: RxStatus.empty());
  }

  Future<void> fetchPointBalance(String authorization) async {
    change(null, status: RxStatus.loading());

    try {
      final int pointBalance =  await pointRepository.fetchPointBalance(authorization);
      change(pointBalance, status: RxStatus.success());
    } catch (e) {
      log("point_controller.dart: fetchPointBalance() : ${e.toString()}");
      change(state, status: RxStatus.error(e.toString()));
      rethrow;
    }
  }

  final PointRepository pointRepository = PointRepository();
}