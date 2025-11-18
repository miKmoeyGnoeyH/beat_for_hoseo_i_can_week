import 'package:beat/shared/extensions/index.dart';
import 'package:beat/shared/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BEATInterestCard extends StatelessWidget {
  const BEATInterestCard({
    super.key,
    this.onTap,
    this.highlightColor,
    this.splashColor,
    this.label = "",
    this.content = "",
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: highlightColor,
      splashColor: splashColor,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    label.isEmpty
                        ? SizedBox.shrink()
                        : Text(
                            label,
                            style: AppTextTheme.subtitle1.commonWhite,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    SizedBox(height: 4.w),
                    content.isEmpty
                        ? SizedBox.shrink()
                        : Text(
                            content,
                            style: AppTextTheme.headline1.commonWhite,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ],
                ),
              ),
              icon ?? SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  final VoidCallback? onTap;
  final Color? highlightColor;
  final Color? splashColor;
  final String label;
  final String content;
  final Widget? icon;
}
