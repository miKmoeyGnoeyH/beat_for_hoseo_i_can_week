import 'package:package_info_plus/package_info_plus.dart';

class PackageInfoService {
  static final PackageInfoService instance = PackageInfoService._internal();

  PackageInfoService._internal();

  Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  String get appName => _packageInfo.appName;
  String get packageName => _packageInfo.packageName;
  String get version => _packageInfo.version;
  String get buildNumber => _packageInfo.buildNumber;

  late final PackageInfo _packageInfo;
}