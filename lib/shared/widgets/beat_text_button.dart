import 'package:beat/shared/extensions/index.dart';
import 'package:beat/shared/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BEATTextButton extends StatelessWidget {
  const BEATTextButton({
    super.key,
    this.onTap,
    this.highlightColor,
    this.splashColor,
    this.buttonColor = AppColors.primary,
    this.borderColor = Colors.transparent,
    this.text = "",
    this.textColor = AppColors.designWhite,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: highlightColor,
      splashColor: splashColor,
      child: Ink(
        decoration: BoxDecoration(
          color: buttonColor,
          border: Border.all(color: borderColor, width: 0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Center(
            child: Text(
              text,
              style: AppTextTheme.subtitle1.apply(color: textColor),
            ),
          ),
        ),
      ),
    );
  }

  final VoidCallback? onTap;
  final Color? highlightColor;
  final Color? splashColor;
  final Color buttonColor;
  final Color borderColor;
  final String text;
  final Color textColor;
}
