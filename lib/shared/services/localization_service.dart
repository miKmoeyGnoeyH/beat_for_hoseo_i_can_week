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

  /// general
  String get generalConfirm => "general".tr(gender: "confirm");

  String get generalCancel => "general".tr(gender: "cancel");

  String get generalUpdateAvailable => "general".tr(gender: "update_available");

  String get generalUpdateAvailableContent =>
      "general".tr(gender: "update_available_content");

  /// sign in
  String get signInHoseoUnivEmailID =>
      "sign_in_page".tr(gender: "hoseo_univ_email_id");

  String get signInHoseoUnivEmailIDHint =>
      "sign_in_page".tr(gender: "hoseo_univ_email_id_hint");

  String get signInPassword => "sign_in_page".tr(gender: "password");

  String get signInPasswordHint => "sign_in_page".tr(gender: "password_hint");

  String get signInSignIn => "sign_in_page".tr(gender: "sign_in");

  String get signInSignUp => "sign_in_page".tr(gender: "sign_up");

  String get signInForgotPassword =>
      "sign_in_page".tr(gender: "forgot_password");

  /// Sign Up
  String get signUpSignUp => "sign_up_page".tr(gender: "sign_up");

  String get signUpRole => "sign_up_page".tr(gender: "role");

  String get signUpRoles => "sign_up_page".tr(gender: "roles");

  String get signUpCampus => "sign_up_page".tr(gender: "campus");

  String get signUpCampuses => "sign_up_page".tr(gender: "campuses");

  String get signUpRequestCampuses =>
      "sign_up_page".tr(gender: "request_campuses");

  String get signUpCollege => "sign_up_page".tr(gender: "college");

  String get signUpColleges => "sign_up_page".tr(gender: "colleges");

  String get signUpRequestColleges =>
      "sign_up_page".tr(gender: "request_colleges");

  String get signUpDepartment => "sign_up_page".tr(gender: "department");

  String signUpDepartments(String college) => "departments".tr(gender: college);

  String signUpRequestDepartments(String college) =>
      "request_departments".tr(gender: college);

  /// 회원가입 정보기입화면
  String get signUpFillInform => "sign_up_page".tr(gender: "fill_inform");

  /// 이름
  String get signUpName => "sign_up_page".tr(gender: "name");

  String get signUpNameHint => "sign_up_page".tr(gender: "name_hint");

  /// 닉네임
  String get signUpNickname => "sign_up_page".tr(gender: "nickname");

  String get signUpNicknameHint => "sign_up_page".tr(gender: "nickname_hint");

  String get signUpValidateNickname =>
      "sign_up_page".tr(gender: "validate_nickname");

  /// 닉네임 중복확인 완료
  String get signUpValidateNicknameSuccessTitle =>
      "sign_up_page".tr(gender: "validate_nickname_success_title");

  /// 닉네임 중복확인 완료 내용
  String get signUpValidateNicknameSuccessContent =>
      "sign_up_page".tr(gender: "validate_nickname_success_content");

  /// 닉네임 중복 확인 완료(버튼 텍스트)
  String get signUpNicknameValidated =>
      "sign_up_page".tr(gender: "nickname_validated");

  /// 학번
  String get signUpStudentId => "sign_up_page".tr(gender: "student_id");

  String get signUpStudentIdHint =>
      "sign_up_page".tr(gender: "student_id_hint");

  /// 메일인증
  String get signUpValidateMail => "sign_up_page".tr(gender: "verify_mail");

  /// 이메일 전송 완료
  String get signUpEmailSentTitle =>
      "sign_up_page".tr(gender: "email_sent_title");

  String signUpEmailSentMessage(String email) =>
      "sign_up_page".tr(gender: "email_sent_message", args: [email]);

  String get signUpAuthcodeHint => "sign_up_page".tr(gender: "authcode_hint");

  String get signUpEmailSent => "sign_up_page".tr(gender: "email_sent");

  /// 이메일 인증 완료
  String get signUpVerifyEmailSuccessTitle =>
      "sign_up_page".tr(gender: "verify_email_success_title");

  String get signUpVerifyEmailSuccessContent =>
      "sign_up_page".tr(gender: "verify_email_success_content");

  String get signUpEmailVerified => "sign_up_page".tr(gender: "email_verified");

  /// 비밀번호
  String get signUpPassword => "sign_up_page".tr(gender: "password");

  String get signUpPasswordHint => "sign_up_page".tr(gender: "password_hint");

  String get signUpValidatePassword =>
      "sign_up_page".tr(gender: "validate_password");

  String get signUpValidatePasswordHint =>
      "sign_up_page".tr(gender: "validate_password_hint");

  String get signUpSignInfo => "sign_up_page".tr(gender: "sign_info");

  String get signUpSignInfoContent =>
      "sign_up_page".tr(gender: "sign_info_content");

  String get signUpSign => "sign_up_page".tr(gender: "sign");

  String get signUpTapSignButton =>
      "sign_up_page".tr(gender: "tap_sign_button_to_sign");

  String get signUpTermsOfAgreement =>
      "sign_up_page".tr(gender: "terms_of_agreement");

  String get signUpToaPurpose => "sign_up_page".tr(gender: "toa_purpose");

  String get signUpToaPurposeContent =>
      "sign_up_page".tr(gender: "toa_purpose_content");

  String get signUpToaItems => "sign_up_page".tr(gender: "toa_items");

  String get signUpToaItemsContent =>
      "sign_up_page".tr(gender: "toa_items_content");

  String get signUpToaRetention => "sign_up_page".tr(gender: "toa_retention");

  String get signUpToaRetentionContent =>
      "sign_up_page".tr(gender: "toa_retention_content");

  String get signUpToaRightToRefusal =>
      "sign_up_page".tr(gender: "toa_right_to_refusal");

  String get signUpToaRightToRefusalContent =>
      "sign_up_page".tr(gender: "toa_right_to_refusal_content");

  String get signUpDoYouAgree => "sign_up_page".tr(gender: "do_you_agree");

  String get signUpIAgree => "sign_up_page".tr(gender: "i_agree");

  String signUpContinueWith(String value) =>
      "sign_up_page".tr(gender: "continue_with", args: [value]);

  String get signUpComplete => "sign_up_page".tr(gender: "sign_up_complete");

  String get signUpCompleteContent =>
      "sign_up_page".tr(gender: "sign_up_complete_content");


  /// QR
  String get qrPreparingCamera =>
      "qr_page".tr(gender: "preparing_camera");

  String get qrScanSuccessTitle =>
      "qr_page".tr(gender: "scan_success_title");

  String get qrScanSuccessQuestCompleteContent =>
      "qr_page".tr(gender: "scan_success_quest_complete_content");

  String qrScanSuccessPointEarnContent(String value) =>
      "qr_page".tr(
        gender: "scan_success_point_earn_content",
        args: [value],
      );

  String qrScanSuccessPointSpentContent(String value) =>
      "qr_page".tr(
        gender: "scan_success_point_spent_content",
        args: [value],
      );


  /// home
  String get homePointsBalance => "home_page".tr(gender: "points_balance");

  String get homeTapToCheckYourHistory =>
      "home_page".tr(gender: "tap_to_check_your_history");

  String get homeTodaysWalkCount => "home_page".tr(gender: "todays_walk_count");

  String homeMonthlyWalkCount(String count) =>
      "home_page".tr(gender: "monthly_walk_count", args: [count]);

  String homeQuestNo(int count) =>
      "home_page".tr(gender: "quest_no", args: [count.toString()]);

  String homeBingoCompleteNthStep(String step) =>
      "home_page".tr(gender: "bingo_complete_nth_step", args: [step]);

  String homeLineNumber(String number) =>
      "home_page".tr(gender: "line_number", args: [number]);

  String get homeReward => "home_page".tr(gender: "reward");

  String get homeClaimReward => "home_page".tr(gender: "claim_reward");

  String get homeArchivementRate => "home_page".tr(gender: "archivement_rate");

  String homeNumber(String value) =>
      "home_page".tr(gender: "number", args: [value]);

  String get homeTotalPoints => "home_page".tr(gender: "total_points");

  String homePoints(String value) =>
      "home_page".tr(gender: "points", args: [value]);

  String get homeBingoSquareLeft => "home_page".tr(gender: "bingo_square_left");

  String homeSquareLeft(String value) =>
      "home_page".tr(gender: "square_left", args: [value]);

  String get homeQR => "home_page".tr(gender: "qr");

  String get homeHome => "home_page".tr(gender: "home");

  String get homeProfile => "home_page".tr(gender: "profile");

  /// Quest Detail
  String get questDetailQuestName =>
      "quest_detail_page".tr(gender: "quest_name");

  String get questDetailQuestDescription =>
      "quest_detail_page".tr(gender: "quest_description");

  String get questDetailQuestInfo =>
      "quest_detail_page".tr(gender: "quest_info");

  String get questDetailTotalReward =>
      "quest_detail_page".tr(gender: "total_reward");

  String get questDetailQuestType =>
      "quest_detail_page".tr(gender: "quest_type");

  String get questDetailStartDate =>
      "quest_detail_page".tr(gender: "start_date");

  String get questDetailEndDate => "quest_detail_page".tr(gender: "end_date");

  String get questDetailQRInfo => "quest_detail_page".tr(gender: "qr_info");

  String get questDetailQuestCompleted => "quest_detail_page".tr(gender: "quest_completed");

  String get questDetailLocation => "quest_detail_page".tr(gender: "location");

  String get questDetailRewardPoints =>
      "quest_detail_page".tr(gender: "reward_points");

  String get questDetailWalkRequirement =>
      "quest_detail_page".tr(gender: "walk_requirement");

  String get questDetailCompletedAt =>
      "quest_detail_page".tr(gender: "completed_at");

  /// Quest Type
  String questType(String questType) => "quest_type".tr(gender: questType);

  /// Profile
  String get profileName => "profile_page".tr(gender: "name");

  String get profileStudentId => "profile_page".tr(gender: "studentId");

  String get profileEmail => "profile_page".tr(gender: "email");

  String get profileDepartment => "profile_page".tr(gender: "department");

  String get profileNickname => "profile_page".tr(gender: "nickname");

  String get profileCampus => "profile_page".tr(gender: "campus");

  String get profileStudentType => "profile_page".tr(gender: "studentType");

  String get profileTeamName => "profile_page".tr(gender: "teamName");

  String get profileTeamManagement =>
      "profile_page".tr(gender: "team_management");

  /// errors
  String get errorSignInFailed => "errors".tr(gender: "error_sign_in_failed");

  String get errorTimeout => "errors".tr(gender: "error_timeout");

  String get errorConnectivity => "errors".tr(gender: "error_connectivity");

  String get errorWrongIDOrPassword =>
      "errors".tr(gender: "error_wrong_id_or_password");

  String get errorEmptyField => "errors".tr(gender: "error_empty_field");

  String get errorPleaseEnterIDAndPassword =>
      "errors".tr(gender: "error_please_enter_id_and_password");

  String get errorUnknown => "errors".tr(gender: "error_unknown");

  String get errorPlatformNotSupported =>
      "errors".tr(gender: "error_platform_not_supported");

  /// 부적절한 이름(단어)
  String get errorInavailableNameMessage =>
      "errors".tr(gender: "error_inavailable_name_message");

  /// 부적절한 이름(문자)
  String get errorInavailableNameMessage2 =>
      "errors".tr(gender: "error_inavailable_name_message2");

  /// 이름에 초성 포함
  String get errorNameHasInitialConsonant =>
      "errors".tr(gender: "error_name_has_initial_consonant");

  /// 이름 미입력
  String get errorNameIsEmpty => "errors".tr(gender: "error_name_is_empty");

  String get errorNameHasWhitespace =>
      "errors".tr(gender: "error_name_has_whitespace");

  /// 닉네임 중복확인 실패
  String get errorValidateNicknameFailedTitle =>
      "errors".tr(gender: "error_validate_nickname_failed_title");

  /// 닉네임 미입력(사실상 쓸 일 없음)
  String get errorNicknameIsEmpty =>
      "errors".tr(gender: "error_nickname_is_empty");

  /// 닉네임 초성 포함
  String get errorNicknameHasInitialConsonant =>
      "errors".tr(gender: "error_nickname_has_initial_consonant");

  /// 부적절한 닉네임(단어)
  String get errorNicknameInavailableMessage =>
      "errors".tr(gender: "error_nickname_inavailable_message");

  /// 부적절한 닉네임(문자)
  String get errorNicknameInavailableMessage2 =>
      "errors".tr(gender: "error_nickname_inavailable_message2");

  String get errorNicknameHasWhitespace =>
      "errors".tr(gender: "error_nickname_has_whitespace");

  /// 닉네임 중복
  String get errorNicknameDuplicated =>
      "errors".tr(gender: "error_nickname_duplicated");

  /// 학번 짧음
  String get errorSidTooShort => "errors".tr(gender: "error_sid_too_short");

  /// 학번 미입력
  String get errorSidIsEmpty => "errors".tr(gender: "error_sid_is_empty");

  /// 학번 형식 오류
  String get errorInvalidSid => "errors".tr(gender: "error_invalid_sid");

  /// 이메일 전송 실패
  String get errorEmailSendingFailedTitle =>
      "errors".tr(gender: "error_email_sending_failed_title");

  /// 메일 인증 미완료
  String get errorEmailNotVerifiedTitle =>
      "errors".tr(gender: "error_email_not_verified_title");

  String get errorEmailNotVerifiedContent =>
      "errors".tr(gender: "error_email_not_verified_content");

  /// 이메일 인증 실패
  String get errorVerifyEmailFailedTitle =>
      "errors".tr(gender: "error_verify_email_failed_title");

  String get errorVerifyEmailFailedContent =>
      "errors".tr(gender: "error_verify_email_failed_content");

  String get errorPasswordIsEmpty =>
      "errors".tr(gender: "error_password_is_empty");

  String get errorPasswordFormatUnmatch =>
      "errors".tr(gender: "error_password_format_unmatch");

  String get errorValidatePasswordIsEmpty =>
      "errors".tr(gender: "error_validate_password_is_empty");

  String get errorPasswordNotMatched =>
      "errors".tr(gender: "error_password_not_matched");

  String get errorSignUpFailedTitle =>
      "errors".tr(gender: "error_sign_up_failed_title");

  String get errorSignUpEmptyField =>
      "errors".tr(gender: "error_sign_up_empty_field");

  String get errorSignUpFailedContent =>
      "errors".tr(gender: "error_sign_up_failed_content");

  String get errorQRScanFailed =>
      "errors".tr(gender: "error_scan_failed");

  String get errorQRScanFailedDefaultContent =>
      "errors".tr(gender: "error_scan_failed_default_content");

  String get errorInvalidQR =>
      "errors".tr(gender: "error_invalid_qr_code");
}
