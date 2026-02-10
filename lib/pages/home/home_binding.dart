import 'package:beat/features/point/index.dart';
import 'package:beat/features/quest/index.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PointController());
    Get.put(QuestListController());
  }
}