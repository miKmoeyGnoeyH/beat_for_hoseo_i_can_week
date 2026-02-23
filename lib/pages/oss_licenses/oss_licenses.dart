import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../shared/index.dart';

part 'oss_license_detail.dart';

class OssLicenses extends StatefulWidget {
  const OssLicenses({super.key, this.title = 'Open Source Licenses'});

  final String title;

  @override
  State<OssLicenses> createState() => _OssLicensesPageState();
}

class _OssLicensesPageState extends State<OssLicenses> {
  late final Future<List<_PkgLicense>> _future;
  final String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _loadLicenses();
  }

  void onOssLicenseTap(_PkgLicense item) {
    Get.to(() => OssLicenseDetail(item: item));
  }

  Future<List<_PkgLicense>> _loadLicenses() async {
    // packageName -> StringBuffer(licenses)
    final Map<String, StringBuffer> byPkg = {};

    await for (final LicenseEntry entry in LicenseRegistry.licenses) {
      final String licenseText = _formatEntry(entry);

      for (final String pkg in entry.packages) {
        final buf = byPkg.putIfAbsent(pkg, () => StringBuffer());
        // 같은 패키지에 여러 라이선스 엔트리가 붙는 경우가 있어 append
        if (buf.isNotEmpty) buf.writeln('\n\n');
        buf.write(licenseText);
      }
    }

    final list =
        byPkg.entries
            .map((e) => _PkgLicense(package: e.key, text: e.value.toString()))
            .toList()
          ..sort(
            (a, b) =>
                a.package.toLowerCase().compareTo(b.package.toLowerCase()),
          );

    return list;
  }

  String _formatEntry(LicenseEntry entry) {
    // paragraphs는 단락 단위로 오고, 각 단락은 indent를 포함할 수 있음
    final sb = StringBuffer();

    for (final p in entry.paragraphs) {
      final indent = ' ' * (p.indent * 2); // 보기 좋게 2칸 단위
      final line = p.text.trimRight();
      if (line.isEmpty) {
        sb.writeln();
      } else {
        sb.writeln('$indent$line');
      }
    }
    return sb.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            LocalizationService.instance.ossOSSLicenses,
            style: AppTextTheme.subtitle2,
          ),
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
        body: SafeArea(
          child: FutureBuilder<List<_PkgLicense>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Text(
                    'Failed to load licenses:\n${snap.error}',
                    style: AppTextTheme.subtitle1.common300,
                  ),
                );
              }
          
              final data = snap.data ?? const <_PkgLicense>[];
              final q = _query.trim().toLowerCase();
              final filtered = q.isEmpty
                  ? data
                  : data
                        .where((e) => e.package.toLowerCase().contains(q))
                        .toList();
          
              return Column(
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  //   child: TextField(
                  //     decoration: const InputDecoration(
                  //       prefixIcon: Icon(Icons.search),
                  //       hintText: 'Search packages…',
                  //       border: OutlineInputBorder(),
                  //       isDense: true,
                  //     ),
                  //     onChanged: (v) => setState(() => _query = v),
                  //   ),
                  // ),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsetsGeometry.all(16.w),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10.w),
                      itemBuilder: (context, i) {
                        final item = filtered[i];
                        return GestureDetector(
                          onTap: () => onOssLicenseTap(item),
                          child: BEATShadowContainer(
                            shadowBlurRadius: 15.w,
                            shadowSpreadRadius: -13.w,
                            contentPadding: EdgeInsetsGeometry.all(16.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.package,
                                      style: AppTextTheme.subtitle2,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 10.w),
                                    Text(
                                      '${_approxLines(item.text)} lines',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                SizedBox(width: 10.w),
                                SvgPicture.asset(
                                  BEATAssets.svg.rightArrow,
                                  width: 12.w,
                                  colorFilter: ColorFilter.mode(
                                    AppColors.common300,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  int _approxLines(String s) => '\n'.allMatches(s).length + 1;
}
