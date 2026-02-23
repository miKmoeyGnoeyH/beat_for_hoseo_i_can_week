part of 'oss_licenses.dart';

class OssLicenseDetail extends StatelessWidget {
  const OssLicenseDetail({super.key, required this.item});

  final _PkgLicense item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.package, style: AppTextTheme.subtitle2),
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.commonWhite,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: SvgPicture.asset(
            BEATAssets.svg.backArrow,
            width: 24.w,
            height: 24.w,
          ),
        ),
        shape: Border(
          bottom: BorderSide(width: 0.5, color: AppColors.disabledColorLight),
        ),
      ),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BEATShadowContainer(
              contentPadding: EdgeInsetsGeometry.all(10.w),
              shadowBlurRadius: 30.w,
              shadowSpreadRadius: -20.w,
              child: Text(
                item.text,
                style: AppTextTheme.body1,
                // style: const TextStyle(
                //   fontFamily: 'monospace', // 라이선스는 모노스페이스가 가독성 좋음
                //   height: 1.35,
                // ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PkgLicense {
  _PkgLicense({required this.package, required this.text});

  final String package;
  final String text;
}
