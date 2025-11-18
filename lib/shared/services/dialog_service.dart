import 'dart:ui';

import 'package:beat/shared/index.dart';
import 'package:beat/shared/widgets/beat_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


sealed class DialogEvent {
  DialogEvent({required this.title, this.message, this.onConfirm});

  final String title;
  final String? message;
  final VoidCallback? onConfirm;
}

/// Alert 다이얼로그 이벤트입니다.
/// 버튼이 하나입니다.
final class AlertDialogEvent extends DialogEvent {
  AlertDialogEvent({required super.title, super.message, super.onConfirm});
}

/// Confirm 다이얼로그 이벤트입니다.
/// 버튼이 두 개입니다.
///
/// 2025.11.18 현재
/// ```
/// if (dialogEvent.runtimeType == ConfirmDialogEvent) {
///   Get.dialog(SizedBox.shrink());
/// }
/// ```
/// 로 실제 구현되어있지 않습니다.
final class ConfirmDialogEvent extends DialogEvent {
  ConfirmDialogEvent({required super.title, super.message, super.onConfirm});
}

final class ExceptionDialogEvent extends DialogEvent {
  ExceptionDialogEvent({required super.title, super.message, super.onConfirm});
}

/// 전역 다이얼로그 서비스입니다.
///
/// 앱의 최상단에 위치하며, GetxController를 상속받아 앱의 어디에서나 전역적으로 접근해 다이얼로그를 출력합니다.
/// Observable List로 다이얼로그 큐를 만들고, 이 큐에 변경사항이 생길 때마다 큐를 확인하고, 다이얼로그를 출력합니다.
///
/// 이 방식은 [BuildContext]를 전달받을 필요가 없기 때문에 플러터 프레임워크에서 자체적으로 제공하는 [Dialog] 방식보다 더 유연하지만,
/// 플러터 설계 철학-[BuildContext]를 통한 데이터 전달, 상태 관리, 위젯 트리 탐색-과는 맞지 않습니다.
class DialogService extends GetxController {
  static DialogService get to => Get.find<DialogService>();

  final RxList<DialogEvent> _dialogEvents = <DialogEvent>[].obs;

  DialogService() {
    ever<List<DialogEvent>>(_dialogEvents, (event) {
      while (event.isNotEmpty) {
        final dialogEvent = event.first;

        if (dialogEvent.runtimeType == ConfirmDialogEvent) {
          Get.dialog(SizedBox.shrink());
        } else {
          Get.dialog(
            barrierDismissible: false,
            BEATAlertDialog(
              title: dialogEvent.title,
              message: dialogEvent.message,
              onTap: dialogEvent.onConfirm,
            ),
          );
        }

        event.removeAt(0);
      }
    });
  }

  void addDialogEvent(DialogEvent event) {
    _dialogEvents.add(event);
  }
}
