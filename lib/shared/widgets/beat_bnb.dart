import 'package:beat/shared/services/index.dart';
import 'package:beat/shared/theme/index.dart';
import 'package:beat/shared/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

// TODO: 현재 선택된 페이지 상태를 어떻게 관리할 것인지?
// home page controller를 구현, 홈 화면 pageview와 bnb에서 연동
class BEATBNB extends StatelessWidget {
  const BEATBNB({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.commonWhite,
        border: Border(
          top: BorderSide(width: 0.5, color: AppColors.disabledColorLight),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 12.w, bottom: 16.w, left: 16.w, right: 16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
