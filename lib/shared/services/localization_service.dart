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
  String get signInSignInFailed => "sign_in_page".tr(gender: "sign_in_failed");
  String get signInErrorConnectivity => "sign_in_page".tr(gender: "error_connectivity");
  String get signInErrorWrongIDOrPassword => "sign_in_page".tr(gender: "error_wrong_id_or_password");

  // register fill inform
  String get rfiAppbarTitle =>
      "register_fill_inform_page".tr(gender: "appbar_title");

  String get rfiName => "register_fill_inform_page".tr(gender: "name");

  String get rfiNameHint => "register_fill_inform_page".tr(gender: "name_hint");

  String get rfiStudentId =>
      "register_fill_inform_page".tr(gender: "student_id");

  String get rfiStudentIdHint =>
      "register_fill_inform_page".tr(gender: "student_id_hint");

  String get rfiId => "register_fill_inform_page".tr(gender: "id");

  String get rfiIdHint => "register_fill_inform_page".tr(gender: "id_hint");

  String get rfiValidateMail =>
      "register_fill_inform_page".tr(gender: "validate_mail");

  String get rfiValidateId =>
      "register_fill_inform_page".tr(gender: "validate_id");

  String get rfiEmailSentTitle =>
      "register_fill_inform_page".tr(gender: "email_sent_title");

  String get rfiEmailSentMessage =>
      "register_fill_inform_page".tr(gender: "email_sent_message");

  String get rfiEmailSentErrorTitle =>
      "register_fill_inform_page".tr(gender: "email_sent_error_title");

  String get rfiEmailSentErrorMessage =>
      "register_fill_inform_page".tr(gender: "email_sent_error_message");

  String get rfiIdCheckTitle =>
      "register_fill_inform_page".tr(gender: "id_check_title");

  String get rfiIdCheckMessage =>
      "register_fill_inform_page".tr(gender: "id_check_message");

  String get rfiIdCheckErrorTitle =>
      "register_fill_inform_page".tr(gender: "id_check_error_title");

  String get rfiIdCheckErrorMessage =>
      "register_fill_inform_page".tr(gender: "id_check_error_message");

  String get rfiNickname => "register_fill_inform_page".tr(gender: "nickname");

  String get rfiValidateNickname =>
      "register_fill_inform_page".tr(gender: "validate_nickname");

  String get rfiNicknameCheckedTitle =>
      "register_fill_inform_page".tr(gender: "nickname_checked_title");

  String get rfiNicknameCheckedMessage =>
      "register_fill_inform_page".tr(gender: "nickname_checked_message");

  String get rfiNicknameUncheckedTitle =>
      "register_fill_inform_page".tr(gender: "nickname_unchecked_title");

  String get rfiNicknameUncheckedMessage =>
      "register_fill_inform_page".tr(gender: "nickname_unchecked_message");

  String get rfiNicknameCheckErrorTitle =>
      "register_fill_inform_page".tr(gender: "nickname_check_error_title");

  String get rfiNicknameCheckErrorMessage =>
      "register_fill_inform_page".tr(gender: "nickname_check_error_message");

  String get rfiInappropriateNickname =>
      "register_fill_inform_page".tr(gender: "inapropriate_nickname");

  String get rfiNicknameHasInitialConsonant =>
      "register_fill_inform_page".tr(gender: "nickname_has_initial_consonant");

  String get rfiInappropriateNicknameMessage =>
      "register_fill_inform_page".tr(gender: "inapropriate_nickname_message");

  String get rfiNicknameHint =>
      "register_fill_inform_page".tr(gender: "nickname_hint");

  String get rfiWhyDoINeedToSign =>
      "register_fill_inform_page".tr(gender: "why_do_i_need_to_sign");

  String get rfiWdintsContent =>
      "register_fill_inform_page".tr(gender: "wdints_content");

  String get rfiSign => "register_fill_inform_page".tr(gender: "sign");

  String get rfiSignContent =>
      "register_fill_inform_page".tr(gender: "sign_content");

  String get rfiTermsOfAgreement =>
      "register_fill_inform_page".tr(gender: "terms_of_agreement");

  String get rfiToaItems => "register_fill_inform_page".tr(gender: "toa_items");

  String get rfiToaItemsContent =>
      "register_fill_inform_page".tr(gender: "toa_items_content");

  String get rfiToaItemsContentStudent =>
      "register_fill_inform_page".tr(gender: "toa_items_content_student");

  String get rfiToaItemsContentOther =>
      "register_fill_inform_page".tr(gender: "toa_items_content_other");

  String get rfiToaPurpose =>
      "register_fill_inform_page".tr(gender: "toa_purpose");

  String get rfiToaPurposeContent =>
      "register_fill_inform_page".tr(gender: "toa_purpose_content");

  String get rfiToaRetention =>
      "register_fill_inform_page".tr(gender: "toa_retention");

  String get rfiToaRetentionContent =>
      "register_fill_inform_page".tr(gender: "toa_retention_content");

  String get rfiToaRightToRefusal =>
      "register_fill_inform_page".tr(gender: "toa_right_to_refusal");

  String get rfiToaRightToRefusalContent =>
      "register_fill_inform_page".tr(gender: "toa_right_to_refusal_content");

  String get rfiDoYouAgree =>
      "register_fill_inform_page".tr(gender: "do_you_agree");

  String get rfiIAgree => "register_fill_inform_page".tr(gender: "i_agree");

  String get rfiSignUp => "register_fill_inform_page".tr(gender: "sign_up");

  String get rfiSignUpSuccess =>
      "register_fill_inform_page".tr(gender: "sign_up_success");

  String get rfiSignUpSuccessMessage =>
      "register_fill_inform_page".tr(gender: "sign_up_success_message");

  String get rfiToSignInScreen =>
      "register_fill_inform_page".tr(gender: "to_sign_in_screen");

  String get rfiSignUpFailed =>
      "register_fill_inform_page".tr(gender: "sign_up_failed");

  String get rfiSignUpFailedMessage =>
      "register_fill_inform_page".tr(gender: "sign_up_failed_message");

  // home
  String get homePointsInHand => "home".tr(gender: "points_in_hand");

  String get homeTapToCheckYourHistory =>
      "home".tr(gender: "tap_to_check_your_history");

  String get homeQuest => "home".tr(gender: "quest");

  String homeQuestNo(String arg) => "home".tr(gender: "quest_no", args: [arg]);

  String get homeQuiz => "home".tr(gender: "quiz");

  String homeQuizNo(String arg) => "home".tr(gender: "quiz_no", args: [arg]);

  String get homeSurvey => "home".tr(gender: "survey");

  String homeSurveyNo(String arg) =>
      "home".tr(gender: "survey_no", args: [arg]);

  String get homeSurveyDesc => "home".tr(gender: "survey_desc");

  String get homeThereIsNoQuizYet => "home".tr(gender: "there_is_no_quiz_yet");

  String get homeStepCount => "home".tr(gender: "step_count");

  String homeSteps(String arg) => "home".tr(gender: "steps", args: [arg]);

  String homeTotalSteps(String arg) =>
      "home".tr(gender: "total_steps", args: [arg]);

  // ranking
  String get rankingRanking => "rank".tr(gender: "ranking");

  String get rankingPoint => "rank".tr(gender: "point");

  String get rankingStepCount => "rank".tr(gender: "step_count");

  String get rankingRankingDescPoint => "rank".tr(gender: "ranking_desc_point");

  String get rankingRankingDescStepCount =>
      "rank".tr(gender: "ranking_desc_step_count");

  // bottom navigation bar
  String get bnbQR => "bottom_navigation_bar".tr(gender: "qr");

  String get bnbHome => "bottom_navigation_bar".tr(gender: "home");

  // errors
  String get errorsUnknownError => "errors".tr(gender: "unknown_error");
}
