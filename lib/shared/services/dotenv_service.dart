import 'package:flutter_dotenv/flutter_dotenv.dart';

class DotEnvService {
  static final DotEnvService instance = DotEnvService._internal();

  DotEnvService._internal();

  Future<void> init() async {
    const currentEnv =
    String.fromEnvironment('ENV', defaultValue: 'development');
    const envFile = currentEnv == 'production'
        ? 'assets/config/.env.production'
        : 'assets/config/.env.development';

    await dotenv.load(fileName: envFile);
  }

  String get baseURL => dotenv.env['BASE_URL'] ?? "";
  String get appstoreID => dotenv.env['APPSTORE_ID'] ?? "";
  String get googleplayID => dotenv.env['GOOGLEPLAY_ID'] ?? "";
  String get signIn => dotenv.env['SIGN_IN'] ?? "";
}