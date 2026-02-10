import 'package:beat/shared/extensions/index.dart';
import 'package:beat/shared/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BEATListItem extends StatelessWidget {
  const BEATListItem({
    super.key,
    this.onTap,
    this.highlightColor,
    this.splashColor,
    this.label = "",
    this.title = "",
    this.description = "",
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
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: borderColor(context), width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    label.isEmpty
                        ? SizedBox.shrink()
                        : Text(label, style: AppTextTheme.subtitle2.primary),
                    SizedBox(height: 4.w),
                    title.isEmpty
                        ? SizedBox.shrink()
                        : Text(
                            title,
                            style: AppTextTheme.subtitle1,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                    SizedBox(height: 4.w),
                    description.isEmpty
                        ? SizedBox.shrink()
                        : Text(
                            description,
                            style: descStyle(context),
                            maxLines: 2,
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

  Color borderColor(BuildContext context) => Theme.of(context).brightness == Brightness.light ? Colors.transparent : AppColors.borderDark;
  TextStyle descStyle(BuildContext context) => Theme.of(context).brightness == Brightness.light ? AppTextTheme.caption1.designBlack : AppTextTheme.caption1.designWhite;

  final VoidCallback? onTap;
  final Color? highlightColor;
  final Color? splashColor;
  final String label;
  final String title;
  final String description;
  final Widget? icon;
}
