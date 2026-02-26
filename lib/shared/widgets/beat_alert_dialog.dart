import 'package:auto_size_text/auto_size_text.dart';
import 'package:beat/shared/services/localization_service.dart';
import 'package:beat/shared/theme/index.dart';
import 'package:beat/shared/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 앱에서 사용되는 커스텀 AlertDialog입니다.
///
/// [final String? title]: 다이얼로그의 제목입니다. 제목이 필요 없는 경우도 있지 않을까? 싶어서 nullable로 선언했습니다.
///
/// [final String? message]: 다이얼로그의 메시지입니다. 메시지가 필요 없는 경우도 있지 않을까? 싶어서 nullable로 선언했습니다.
///
/// [final String? buttonText]: 다이얼로그의 버튼 텍스트입니다. 지정된 값이 있다면 그 값을 사용하고, 아니라면 기본값으로 "확인" 텍스트를 사용합니다.
///
/// [final VoidCallback? onTap]: 다이얼로그의 버튼이 눌렸을 때 실행될 콜백 함수입니다. 필요 없는 경우도 있을 수 있어서 nullable로 선언했습니다.
/// 콜백 함수가 없더라도 기본적으로 Get.back()을 호출해 다이얼로그를 닫습니다. 콜백 함수가 있다면, 그 함수를 호출하고 다이얼로그를 닫습니다.
class BEATAlertDialog extends StatelessWidget {
  const BEATAlertDialog({
    super.key,
    this.title,
    this.message,
    this.buttonText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                if (title != null && title!.isNotEmpty)
                  Text(title!, style: AppTextTheme.subtitle1),
                SizedBox(height: 12.w),
                if (message != null && message!.isNotEmpty)
                  Text(
                    message!,
                    style: AppTextTheme.body2,
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
            SizedBox(height: 24.w),
            BEATTextButton(
              text: buttonText ?? LocalizationService.instance.generalConfirm,
              buttonColor: AppColors.primary,
              onTap: () {
                onTap?.call();
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  final String? title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onTap;
}
