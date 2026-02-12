import 'dart:developer';

import 'package:beat/entities/notice/index.dart';
import 'package:beat/features/notice/notice_repository.dart';
import 'package:get/get.dart';

class NoticeController extends GetxController with StateMixin {
  static NoticeController get to => Get.find<NoticeController>();

  NoticeController() {
    change(null, status: RxStatus.empty());
  }

  Future<void> fetchNoticeList(String authorization) async {
    change(state, status: RxStatus.loading());

    try {
      final List<NoticeModel> noticeList = await noticeRepository.fetchNoticeList(authorization);
      change(noticeList, status: RxStatus.success());
    } catch (e) {
      log("notice_controller.dart: fetchNoticeList() : ${e.toString()}");
      change(state, status: RxStatus.error(e.toString()));
      rethrow;
    }
  }

  final NoticeRepository noticeRepository = NoticeRepository();
  NoticeModel? selectedNotice;
}