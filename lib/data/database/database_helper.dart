import 'package:pocketentry/core/constants/db_constants.dart';
import 'package:pocketentry/core/constants/app_constants.dart';
import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DbConstants.tableCategories} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colName} TEXT NOT NULL UNIQUE,
        ${DbConstants.colIsDefault} INTEGER NOT NULL DEFAULT 0,
        ${DbConstants.colCreatedAt} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tablePersons} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colCategoryId} INTEGER NOT NULL,
        ${DbConstants.colName} TEXT NOT NULL,
        ${DbConstants.colPhone} TEXT NOT NULL,
        ${DbConstants.colAddress} TEXT,
        ${DbConstants.colNotes} TEXT,
        ${DbConstants.colCreatedAt} TEXT NOT NULL,
        FOREIGN KEY (${DbConstants.colCategoryId})
          REFERENCES ${DbConstants.tableCategories}(${DbConstants.colId})
          ON DELETE RESTRICT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableTransactions} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colPersonId} INTEGER NOT NULL,
        ${DbConstants.colType} TEXT NOT NULL,
        ${DbConstants.colAmount} REAL NOT NULL,
        ${DbConstants.colCurrency} TEXT NOT NULL,
        ${DbConstants.colDetails} TEXT,
        ${DbConstants.colTransactionDate} TEXT NOT NULL,
        ${DbConstants.colImagePath} TEXT,
        ${DbConstants.colCreatedAt} TEXT NOT NULL,
        FOREIGN KEY (${DbConstants.colPersonId})
          REFERENCES ${DbConstants.tablePersons}(${DbConstants.colId})
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableSettings} (
        ${DbConstants.colKey} TEXT PRIMARY KEY,
        ${DbConstants.colValue} TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_persons_category ON ${DbConstants.tablePersons}(${DbConstants.colCategoryId})
    ''');
    await db.execute('''
      CREATE INDEX idx_transactions_person ON ${DbConstants.tableTransactions}(${DbConstants.colPersonId})
    ''');
    await db.execute('''
      CREATE INDEX idx_transactions_date ON ${DbConstants.tableTransactions}(${DbConstants.colTransactionDate})
    ''');

    // التصنيف الافتراضي
    await db.insert(DbConstants.tableCategories, {
      DbConstants.colName: AppConstants.defaultCategoryName,
      DbConstants.colIsDefault: 1,
      DbConstants.colCreatedAt: DateTime.now().toIso8601String(),
    });

    // الإعدادات الافتراضية
    await db.insert(DbConstants.tableSettings, {
      DbConstants.colKey: AppConstants.keyDefaultCurrency,
      DbConstants.colValue: AppCurrency.yer.dbValue,
    });
    await db.insert(DbConstants.tableSettings, {
      DbConstants.colKey: AppConstants.keyBusinessName,
      DbConstants.colValue: '',
    });
    await db.insert(DbConstants.tableSettings, {
      DbConstants.colKey: AppConstants.keySupportEmail,
      DbConstants.colValue: AppConstants.supportEmail,
    });
    await db.insert(DbConstants.tableSettings, {
      DbConstants.colKey: AppConstants.keySupportPhone,
      DbConstants.colValue: AppConstants.supportPhone,
    });
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<void> resetDatabase() async {
    await close();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    await deleteDatabase(path);
    _database = await _initDatabase();
  }
}
