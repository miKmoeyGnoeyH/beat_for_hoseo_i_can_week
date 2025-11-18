import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// 모바일 데이터베이스 엔트리포인트 싱글톤 객체입니다.
/// 최근 로그인한 사용자 정보는 [SharedPreferences]에 저장하는 것이 구현도 간단하고, 속도도 빠릅니다.
/// 모바일 DB는 데이터를 더 체계적으로 관리할 수는 있겠으나, 속도가 [SharedPreferences]에 비해 더 느립니다.
/// 어디에 사용할지 고민이 필요합니다.
class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  static const _databaseName = "beat_database.db";
  static const _version = 1;

  Future<void> init() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    _database = await openDatabase(
      path,
      version: _version,
      onCreate: (Database db, int version) async {
        await db.execute('''CREATE TABLE user (
        member_id bigint auto_increment primary key,
        category tinyint null,
        department varchar(255) null,
        email varchar(255) null,
        name varchar(255) null,
        nickname varchar(255) null,
        password varchar(255) null,
        student_id varchar(255) null,
      )''');
      },
    );
  }

  DatabaseService._internal();
}
