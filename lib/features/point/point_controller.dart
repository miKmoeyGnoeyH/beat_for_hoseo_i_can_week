import 'dart:developer';

import 'package:beat/features/authentication/authentication_controller.dart';
import 'package:beat/features/point/point_repository.dart';
import 'package:beat/shared/index.dart';
import 'package:get/get.dart';

class PointController extends GetxController with StateMixin<int> {
  static PointController get to => Get.find<PointController>();

  PointController() {
    change(null, status: RxStatus.empty());
  }

  Future<void> fetchPointBalance(String authorization) async {
    change(state, status: RxStatus.loading());

    try {
      final int pointBalance = await pointRepository.fetchPointBalance(
        authorization,
      );
      change(pointBalance, status: RxStatus.success());
    } catch (e) {
      log("point_controller.dart: fetchPointBalance() : ${e.toString()}");
      _didInitialFetch = false;
      change(state, status: RxStatus.error(e.toString()));
      rethrow;
    }
  }

  Future<void> fetchPointBalanceOnce(String authorization) async {
    if (_didInitialFetch) return;
    _didInitialFetch = true;
    await fetchPointBalance(authorization);
  }

  final PointRepository pointRepository = PointRepository();
  bool _didInitialFetch = false;
}
