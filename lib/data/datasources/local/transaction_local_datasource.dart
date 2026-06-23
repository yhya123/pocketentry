import 'package:pocketentry/core/constants/db_constants.dart';
import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:pocketentry/data/database/database_helper.dart';
import 'package:pocketentry/data/models/models.dart';

class TransactionLocalDataSource {
  TransactionLocalDataSource(this._dbHelper);
  final DatabaseHelper _dbHelper;

  Future<List<TransactionModel>> getAll({
    int? personId,
    int? categoryId,
    AppCurrency? currency,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _dbHelper.database;
    final whereClauses = <String>[];
    final whereArgs = <Object?>[];

    if (personId != null) {
      whereClauses.add('t.${DbConstants.colPersonId} = ?');
      whereArgs.add(personId);
    }
    if (categoryId != null) {
      whereClauses.add('p.${DbConstants.colCategoryId} = ?');
      whereArgs.add(categoryId);
    }
    if (currency != null) {
      whereClauses.add('t.${DbConstants.colCurrency} = ?');
      whereArgs.add(currency.dbValue);
    }
    if (startDate != null) {
      whereClauses.add('t.${DbConstants.colTransactionDate} >= ?');
      whereArgs.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      final end = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
      );
      whereClauses.add('t.${DbConstants.colTransactionDate} <= ?');
      whereArgs.add(end.toIso8601String());
    }

    final where = whereClauses.isEmpty
        ? ''
        : 'WHERE ${whereClauses.join(' AND ')}';

    final results = await db.rawQuery('''
      SELECT t.*, p.${DbConstants.colName} as person_name,
             c.${DbConstants.colName} as category_name
      FROM ${DbConstants.tableTransactions} t
      INNER JOIN ${DbConstants.tablePersons} p
        ON p.${DbConstants.colId} = t.${DbConstants.colPersonId}
      INNER JOIN ${DbConstants.tableCategories} c
        ON c.${DbConstants.colId} = p.${DbConstants.colCategoryId}
      $where
      ORDER BY t.${DbConstants.colTransactionDate} DESC,
               t.${DbConstants.colCreatedAt} DESC
    ''', whereArgs);

    return results.map(TransactionModel.fromMap).toList();
  }

  Future<TransactionModel?> getById(int id) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(
      '''
      SELECT t.*, p.${DbConstants.colName} as person_name,
             c.${DbConstants.colName} as category_name
      FROM ${DbConstants.tableTransactions} t
      INNER JOIN ${DbConstants.tablePersons} p
        ON p.${DbConstants.colId} = t.${DbConstants.colPersonId}
      INNER JOIN ${DbConstants.tableCategories} c
        ON c.${DbConstants.colId} = p.${DbConstants.colCategoryId}
      WHERE t.${DbConstants.colId} = ?
      LIMIT 1
    ''',
      [id],
    );
    if (results.isEmpty) return null;
    return TransactionModel.fromMap(results.first);
  }

  Future<int> insert(TransactionModel model) async {
    final db = await _dbHelper.database;
    return db.insert(DbConstants.tableTransactions, model.toMap());
  }

  Future<void> update(TransactionModel model) async {
    final db = await _dbHelper.database;
    await db.update(
      DbConstants.tableTransactions,
      model.toMap(),
      where: '${DbConstants.colId} = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      DbConstants.tableTransactions,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<int> countAll() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DbConstants.tableTransactions}',
    );
    return (result.first['count'] as int?) ?? 0;
  }
}
