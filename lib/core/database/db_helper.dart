import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dbHelperProvider = Provider<DbHelper>((ref) => DbHelper());

class DbHelper {
  static const String _dbName = 'companion_app.db';
  static const int _dbVersion = 1;

  static const String tableCampaigns = 'campaigns';

  static const String colId = 'id';
  static const String colName = 'name';
  static const String colSystem = 'system';
  static const String colNextSession = 'next_session';
  static const String colNotes = 'notes';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableCampaigns (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colName TEXT NOT NULL,
        $colSystem TEXT NOT NULL,
        $colNextSession TEXT NOT NULL,
        $colNotes TEXT
      )
    ''');
  }
}
