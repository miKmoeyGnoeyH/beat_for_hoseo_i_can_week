
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainPageViewAppbarIconButton extends StatelessWidget {
  const MainPageViewAppbarIconButton({super.key, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: CircleBorder(),
      child: Ink(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
        ),
        child: Padding(
          padding: EdgeInsets.all(5.w),
          child: Center(
            child: icon,
          ),
        ),
      ),
    );
  }

  final VoidCallback? onTap;
  final Widget icon;
}
