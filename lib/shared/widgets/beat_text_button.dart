import 'package:beat/shared/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BEATTextButton extends StatelessWidget {
  const BEATTextButton({
    super.key,
    this.enabled = true,
    this.onTap,
    this.highlightColor,
    this.splashColor,
    this.buttonColor = AppColors.primary,
    this.borderColor = Colors.transparent,
    this.contentPadding,
    this.text = "",
    this.textColor = AppColors.designWhite,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        highlightColor: enabled ? highlightColor : Colors.transparent,
        splashColor: enabled ? splashColor : Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: enabled ? buttonColor : AppColors.common200,
            border: Border.all(color: borderColor, width: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: contentPadding ?? EdgeInsets.all(16.w),
            child: Center(
              child: Text(
                text,
                style: AppTextTheme.subtitle1.apply(color: enabled ? textColor : AppColors.common300),
              ),
            ),
          ),
        ),
      ),
    );
  }

  final bool enabled;
  final VoidCallback? onTap;
  final Color? highlightColor;
  final Color? splashColor;
  final Color buttonColor;
  final Color borderColor;
  final EdgeInsetsGeometry? contentPadding;
  final String text;
  final Color textColor;
}
