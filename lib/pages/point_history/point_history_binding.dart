import 'package:beat/features/point/index.dart';
import 'package:get/get.dart';

class PointHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PointHistoryController());
  }
}