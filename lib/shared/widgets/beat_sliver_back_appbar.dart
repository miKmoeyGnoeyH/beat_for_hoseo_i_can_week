import 'package:beat/shared/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class BEATSliverBackAppBar extends StatelessWidget {
  const BEATSliverBackAppBar({super.key, this.pinned = false, this.title = ""});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      centerTitle: true,
      pinned: pinned,
      backgroundColor: AppColors.commonWhite,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: SvgPicture.asset(
          BEATAssets.svg.backArrow,
          width: 24.w,
          height: 24.w,
        ),
      ),
      title: Text(title, style: AppTextTheme.subtitle2),
    );
  }

  final bool pinned;
  final String title;
}
