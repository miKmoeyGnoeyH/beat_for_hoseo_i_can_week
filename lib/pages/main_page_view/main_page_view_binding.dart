import 'package:beat/features/point/index.dart';
import 'package:beat/features/profile/index.dart';
import 'package:beat/features/quest/index.dart';
import 'package:beat/shared/controller/index.dart';
import 'package:get/get.dart';

class MainPageViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PageViewController());
    Get.put(PointController());
    Get.put(QuestListController());
    Get.put(ProfileController());
  }
}