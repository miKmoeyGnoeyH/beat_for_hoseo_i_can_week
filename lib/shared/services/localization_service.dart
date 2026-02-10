import 'package:easy_localization/easy_localization.dart';

/// [easy_localization] 패키지를 더 간편히 사용하기 위한 클래스.
/// 텍스트가 너무 많아, 추상 클래스에 정적 메소드 방식은 메모리 낭비가 심할 것이라 판단.
/// 싱글톤 + getter 방식으로 구현.
class LocalizationService {
  static final LocalizationService instance = LocalizationService._internal();

  LocalizationService._internal();

  Future<void> init() async {
    await EasyLocalization.ensureInitialized();
  }

  // general
  String get generalConfirm => "general".tr(gender: "confirm");
  String get generalUpdateAvailable => "general".tr(gender: "update_available");
  String get generalUpdateAvailableContent => "general".tr(gender: "update_available_content");

  // sign in
  String get signInHoseoUnivEmailID => "sign_in_page".tr(gender: "hoseo_univ_email_id");
  String get signInHoseoUnivEmailIDHint => "sign_in_page".tr(gender: "hoseo_univ_email_id_hint");
  String get signInPassword => "sign_in_page".tr(gender: "password");
  String get signInPasswordHint => "sign_in_page".tr(gender: "password_hint");
  String get signInSignIn => "sign_in_page".tr(gender: "sign_in");
  String get signInRegister => "sign_in_page".tr(gender: "register");
  String get signInForgotPassword => "sign_in_page".tr(gender: "forgot_password");

  // home
  String get homePointsBalance => "home".tr(gender: "points_balance");
  String get homeTapToCheckYourHistory => "home".tr(gender: "tap_to_check_your_history");
  String get homeTodaysWalkCount => "home".tr(gender: "todays_walk_count");
  String homeMonthlyWalkCount(String count) => "home".tr(gender: "monthly_walk_count", args: [count]);
  String homeQuestNo(int count) => "home".tr(gender: "quest_no", args: [count.toString()]);
  String get homeQR => "home".tr(gender: "qr");
  String get homeHome => "home".tr(gender: "home");
  String get homeProfile => "home".tr(gender: "profile");

  // errors
  String get errorSignInFailed => "errors".tr(gender: "error_sign_in_failed");
  String get errorTimeout => "errors".tr(gender: "error_timeout");
  String get errorConnectivity => "errors".tr(gender: "error_connectivity");
  String get errorWrongIDOrPassword => "errors".tr(gender: "error_wrong_id_or_password");
  String get errorEmptyField => "errors".tr(gender: "error_empty_field");
  String get errorPleaseEnterIDAndPassword => "errors".tr(gender: "error_please_enter_id_and_password");
  String get errorUnknown => "errors".tr(gender: "error_unknown");
  String get errorPlatformNotSupported => "errors".tr(gender: "error_platform_not_supported");
}
