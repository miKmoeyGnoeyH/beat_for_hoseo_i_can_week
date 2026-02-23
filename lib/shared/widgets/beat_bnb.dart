import 'package:beat/shared/controller/index.dart';
import 'package:beat/shared/services/index.dart';
import 'package:beat/shared/theme/index.dart';
import 'package:beat/shared/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

/// 추상 팩토리 패턴입니다.
abstract class BNBItemPartsFactory {
  String get svgPictureAssetPath;

  String get labelText;
}

final class QRPartsFactory extends BNBItemPartsFactory {
  @override
  String get svgPictureAssetPath => BEATAssets.svg.qr;

  @override
  String get labelText => LocalizationService.instance.homeQR;
}

final class HomePartsFactory extends BNBItemPartsFactory {
  @override
  String get svgPictureAssetPath => BEATAssets.svg.home;

  @override
  String get labelText => LocalizationService.instance.homeHome;
}

final class ProfilePartsFactory extends BNBItemPartsFactory {
  @override
  String get svgPictureAssetPath => BEATAssets.svg.profile;

  @override
  String get labelText => LocalizationService.instance.homeProfile;
}

class BNBItem extends StatelessWidget {
  const BNBItem({
    super.key,
    required this.svgPictureAssetPath,
    required this.labelText,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                svgPictureAssetPath,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              SizedBox(height: 5.w),
              Text(labelText, style: AppTextTheme.caption1.apply(color: color)),
            ],
          ),
        ),
      ),
    );
  }

  final String svgPictureAssetPath;
  final String labelText;
  final Color color;
  final void Function() onTap;
}

// TODO: 현재 선택된 페이지 상태를 어떻게 관리할 것인지?
// home page controller를 구현, 홈 화면 pageview와 bnb에서 연동
class BEATBNB extends StatelessWidget {
  BEATBNB({super.key});

  final PageViewController pageViewController = PageViewController.to;
  final List<BNBItemPartsFactory> factories = [
    QRPartsFactory(),
    HomePartsFactory(),
    ProfilePartsFactory(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.commonWhite,
          border: Border(
            top: BorderSide(width: 0.5, color: AppColors.disabledColorLight),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: 12.w,
            bottom: 16.w,
            left: 16.w,
            right: 16.w,
          ),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (int i = 0; i < factories.length; i++)
                  BNBItem(
                    svgPictureAssetPath: factories[i].svgPictureAssetPath,
                    labelText: factories[i].labelText,
                    color: pageViewController.currentPage == i
                        ? AppColors.primary
                        : AppColors.designBlack,
                    onTap: () {
                      pageViewController.jumpToPage(i);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
