import 'dart:developer';

import 'package:beat/shared/index.dart';
import 'package:get/get.dart';

/// [ExceptionService]와 [DialogService]를 분리.
/// 예외 발생 시, 우선적으로 [ExceptionService]에서 예외 처리.
/// 이후 [DialogService]로 전달하여 다이얼로그 표출.
class BEATException implements Exception {
  BEATException({required this.title, this.message});

  final String title;
  final String? message;
}

class ExceptionService extends GetxController {
  final RxList<BEATException> _exceptions = <BEATException>[].obs;

  ExceptionService() {
    ever<List<BEATException>>(_exceptions, (exceptions) {
      log("ExceptionService: exceptions length: ${exceptions.length}");
      while (exceptions.isNotEmpty) {
        final exception = exceptions.first;

        Get.find<DialogService>().addDialogEvent(
          ExceptionDialogEvent(
            title: exception.title,
            message: exception.message,
          ),
        );

        exceptions.removeAt(0);
      }
    });
  }

  void addException(BEATException exceptions) {
    _exceptions.add(exceptions);
  }
}
