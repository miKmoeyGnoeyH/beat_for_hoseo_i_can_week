import 'package:get/get.dart';

import '../../features/notice/index.dart';

class NoticeListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NoticeController());
  }
}