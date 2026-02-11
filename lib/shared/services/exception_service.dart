import 'dart:developer';

import 'package:beat/shared/index.dart';
import 'package:get/get.dart';

/// [ExceptionService]와 [DialogService]를 분리.
/// 예외 발생 시, 우선적으로 [ExceptionService]에서 예외 처리.
/// 이후 [DialogService]로 전달하여 다이얼로그 표출.
class BEATException implements Exception {
  BEATException({required this.title, this.message});

  @override
  String toString() {
    return "BEATException: title: $title, message: $message";
  }

  final String title;
  final String? message;
}

class BEATTimeoutException extends BEATException {
  BEATTimeoutException()
      : super(title: LocalizationService.instance.errorTimeout,
      message: LocalizationService.instance.errorConnectivity);
}

class BEATExceptionPlatformNotSupported extends BEATException {
  BEATExceptionPlatformNotSupported()
      : super(title: LocalizationService.instance.errorPlatformNotSupported);
}

class ExceptionService extends GetxController {
  static ExceptionService get to => Get.find<ExceptionService>();

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
