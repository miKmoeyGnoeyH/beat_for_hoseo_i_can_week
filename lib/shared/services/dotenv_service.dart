import 'package:flutter_dotenv/flutter_dotenv.dart';

class DotEnvService {
  static final DotEnvService instance = DotEnvService._internal();

  DotEnvService._internal();

  Future<void> init() async {
    const currentEnv = String.fromEnvironment(
      'ENV',
      defaultValue: 'development',
    );
    const envFile = currentEnv == 'production'
        ? 'assets/config/.env.production'
        : currentEnv == 'test'
        ? 'assets/config/.env.test'
        : 'assets/config/.env.development';

    await dotenv.load(fileName: envFile);
  }

  String get baseURL => dotenv.env['BASE_URL'] ?? "";

  String get appstoreID => dotenv.env['APPSTORE_ID'] ?? "";

  String get googleplayID => dotenv.env['GOOGLEPLAY_ID'] ?? "";

  String get validateNickname => dotenv.env['VALIDATE_NICKNAME'] ?? "";

  String get requestEmail => dotenv.env['REQUEST_EMAIL'] ?? "";

  String get verifyEmail => dotenv.env['VERIFY_EMAIL'] ?? "";

  String get checkAuthcode => dotenv.env['CHECK_AUTHCODE'] ?? "";

  String get signUp => dotenv.env['SIGN_UP'] ?? "";

  String get signIn => dotenv.env['SIGN_IN'] ?? "";

  String get reissueToken => dotenv.env['REISSUE_TOKEN'] ?? "";

  String get fetchPointBalance => dotenv.env['POINT'] ?? "";

  String get fetchPointHistory => dotenv.env['POINT_HISTORY'] ?? "";

  String get fetchNoticeList => dotenv.env['NOTICE_LIST'] ?? "";

  String get fetchQuestList => dotenv.env['QUEST_LIST'] ?? "";

  String get walkCheck => dotenv.env['WALK_CHECK'] ?? "";

  String get bingoCheck => dotenv.env['BINGO_CHECK'] ?? "";

  String get fetchQuestDetail => dotenv.env['QUEST_DETAIL'] ?? "";

  String get fetchQuestDetailImage => dotenv.env['QUEST_DETAIL_IMAGE'] ?? "";

  String get profile => dotenv.env['PROFILE'] ?? "";

  String get resetPassword => dotenv.env['RESET_PASSWORD'] ?? "";

  String get teamBingoStatus => dotenv.env['TEAM_BINGO_STATUS'] ?? "";

  String get withdrawal => dotenv.env['WITHDRAWAL'] ?? "";

  String get walkRanking => dotenv.env['RANKING_WALK'] ?? "";

  String get pointRanking => dotenv.env['RANKING_POINT'] ?? "";

  String get bingoRanking => dotenv.env['RANKING_BINGO'] ?? "";

  String get registerFCMToken => dotenv.env['REGISTER_FCM_TOKEN'] ?? "";

  String get privacyPolicy => dotenv.env['PRIVACY_POLICY'] ?? "";
}
