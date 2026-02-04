import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "motivaid.db";
  static const _databaseVersion = 2;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE profiles (
          id TEXT PRIMARY KEY,
          email TEXT,
          full_name TEXT,
          bio TEXT,
          phone TEXT,
          avatar_url TEXT,
          date_of_birth TEXT,
          role TEXT,
          primary_facility_id TEXT,
          is_active INTEGER, -- 0 or 1
          created_at TEXT,
          updated_at TEXT
        )
      ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Sync Queue Table (for offline changes)
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        operation TEXT NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
        payload TEXT NOT NULL,   -- JSON string
        created_at TEXT NOT NULL,
        synced_at TEXT
      )
    ''');

    // 2. Patients Table (Local cache)
    await db.execute('''
      CREATE TABLE patients (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        age INTEGER,
        gestational_age_weeks INTEGER,
        risk_level TEXT,
        status TEXT,
        midwife_id TEXT NOT NULL,
        facility_id TEXT,
        last_assessment_date TEXT,
        gravida INTEGER,
        parity INTEGER,
        prior_pph_history INTEGER, -- Boolean as 0/1
        history_cesarean_section INTEGER,
        has_antenatal_care INTEGER,
        placental_status TEXT,
        estimated_fetal_weight REAL,
        number_of_fetuses INTEGER,
        baseline_hemoglobin REAL,
        known_coagulopathy INTEGER,
        has_fibroids INTEGER,
        has_polyhydramnios INTEGER,
        labor_induced INTEGER,
        prolonged_labor INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER DEFAULT 1 -- 0 = Pending, 1 = Synced
      )
    ''');

    // 3. Clinical Tables (Placeholder for now, will expand later)
    await db.execute('''
      CREATE TABLE pph_cases (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        midwife_id TEXT NOT NULL,
        status TEXT,
        started_at TEXT,
        created_at TEXT,
        is_synced INTEGER DEFAULT 1
      )
    ''');

    // 4. Profiles Table (Local cache for offline login)
    await db.execute('''
      CREATE TABLE profiles (
        id TEXT PRIMARY KEY,
        email TEXT,
        full_name TEXT,
        bio TEXT,
        phone TEXT,
        avatar_url TEXT,
        date_of_birth TEXT,
        role TEXT,
        primary_facility_id TEXT,
        is_active INTEGER, -- 0 or 1
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  // Generic Helper Methods
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    final db = await instance.database;
    return await db.query(table);
  }

  Future<int> update(String table, Map<String, dynamic> row, String columnId, String id) async {
    final db = await instance.database;
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, String columnId, String id) async {
    final db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
