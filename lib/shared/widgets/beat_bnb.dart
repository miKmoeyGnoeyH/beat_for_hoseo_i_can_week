import 'package:beat/shared/services/index.dart';
import 'package:beat/shared/theme/index.dart';
import 'package:beat/shared/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BEATBNB extends StatelessWidget {
  const BEATBNB({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 0.5, color: AppColors.disabledColorLight),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 5.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(BEATAssets.svg.qr),
                SizedBox(height: 5.w),
                Text(
                  LocalizationService.instance.homeQR,
                  style: AppTextTheme.caption1,
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(BEATAssets.svg.home),
                SizedBox(height: 5.w),
                Text(
                  LocalizationService.instance.homeHome,
                  style: AppTextTheme.caption1,
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(BEATAssets.svg.profile),
                SizedBox(height: 5.w),
                Text(
                  LocalizationService.instance.homeProfile,
                  style: AppTextTheme.caption1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
