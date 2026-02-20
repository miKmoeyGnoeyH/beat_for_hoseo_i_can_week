import 'package:beat/shared/services/localization_service.dart';
import 'package:beat/shared/theme/index.dart';
import 'package:beat/shared/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BEATConfirmDialog extends StatelessWidget {
  const BEATConfirmDialog({
    super.key,
    this.title,
    this.message,
    this.cancelText,
    this.confirmText,
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
            Row(
              children: [
                Flexible(
                  child: BEATTextButton(
                    text: cancelText ?? LocalizationService.instance.generalCancel,
                    textColor: AppColors.common400,
                    buttonColor: AppColors.common200,
                    onTap: () {
                      Get.back();
                    },
                  ),
                ),
                SizedBox(width: 10.w),
                Flexible(
                  child: BEATTextButton(
                    text: confirmText ?? LocalizationService.instance.generalConfirm,
                    buttonColor: AppColors.primary,
                    onTap: () {
                      onTap?.call();
                      Get.back();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  final String? title;
  final String? message;
  final String? cancelText;
  final String? confirmText;
  final VoidCallback? onTap;
}
