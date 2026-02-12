import 'package:beat/shared/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BeatStatusGood extends StatelessWidget {
  const BeatStatusGood({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.statusCompleteBackground,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsetsGeometry.all(5.w),
      child: Center(
        child: Text(text ?? "", style: AppTextTheme.caption1.statusComplete),
      ),
    );
  }

  final String? text;
}
