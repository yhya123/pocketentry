import 'package:pocketentry/core/constants/db_constants.dart';
import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:pocketentry/core/utils/formatters.dart';
import 'package:pocketentry/data/database/database_helper.dart';
import 'package:pocketentry/data/models/models.dart';

class PersonLocalDataSource {
  PersonLocalDataSource(this._dbHelper);
  final DatabaseHelper _dbHelper;

  Future<List<PersonModel>> getAll({int? categoryId, String? query}) async {
    final db = await _dbHelper.database;
    final whereClauses = <String>[];
    final whereArgs = <Object?>[];

    if (categoryId != null) {
      whereClauses.add('p.${DbConstants.colCategoryId} = ?');
      whereArgs.add(categoryId);
    }
    if (query != null && query.trim().isNotEmpty) {
      whereClauses.add(
        '(p.${DbConstants.colName} LIKE ? OR p.${DbConstants.colPhone} LIKE ?)',
      );
      final q = '%${query.trim()}%';
      whereArgs.addAll([q, q]);
    }

    final where = whereClauses.isEmpty
        ? ''
        : 'WHERE ${whereClauses.join(' AND ')}';

    final results = await db.rawQuery('''
      SELECT p.*, c.${DbConstants.colName} as category_name,
        (SELECT MAX(t.${DbConstants.colTransactionDate})
         FROM ${DbConstants.tableTransactions} t
         WHERE t.${DbConstants.colPersonId} = p.${DbConstants.colId}
        ) as last_transaction_date
      FROM ${DbConstants.tablePersons} p
      INNER JOIN ${DbConstants.tableCategories} c
        ON c.${DbConstants.colId} = p.${DbConstants.colCategoryId}
      $where
      ORDER BY p.${DbConstants.colName} ASC
    ''', whereArgs);

    return results.map(PersonModel.fromMap).toList();
  }

  Future<PersonModel?> getById(int id) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery(
      '''
      SELECT p.*, c.${DbConstants.colName} as category_name,
        (SELECT MAX(t.${DbConstants.colTransactionDate})
         FROM ${DbConstants.tableTransactions} t
         WHERE t.${DbConstants.colPersonId} = p.${DbConstants.colId}
        ) as last_transaction_date
      FROM ${DbConstants.tablePersons} p
      INNER JOIN ${DbConstants.tableCategories} c
        ON c.${DbConstants.colId} = p.${DbConstants.colCategoryId}
      WHERE p.${DbConstants.colId} = ?
      LIMIT 1
    ''',
      [id],
    );
    if (results.isEmpty) return null;
    return PersonModel.fromMap(results.first);
  }

  Future<int> insert(PersonModel model) async {
    final db = await _dbHelper.database;
    return db.insert(DbConstants.tablePersons, model.toMap());
  }

  Future<void> update(PersonModel model) async {
    final db = await _dbHelper.database;
    await db.update(
      DbConstants.tablePersons,
      model.toMap(),
      where: '${DbConstants.colId} = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      DbConstants.tablePersons,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  Future<Map<AppCurrency, double>> getBalances(int personId) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      DbConstants.tableTransactions,
      columns: [
        DbConstants.colType,
        DbConstants.colAmount,
        DbConstants.colCurrency,
      ],
      where: '${DbConstants.colPersonId} = ?',
      whereArgs: [personId],
    );

    final balances =
        <AppCurrency, List<({TransactionType type, double amount})>>{};
    for (final row in results) {
      final currency = AppCurrency.fromDb(
        row[DbConstants.colCurrency] as String,
      );
      final type = TransactionType.fromDb(row[DbConstants.colType] as String);
      final amount = (row[DbConstants.colAmount] as num).toDouble();
      balances.putIfAbsent(currency, () => []);
      balances[currency]!.add((type: type, amount: amount));
    }

    return {
      for (final entry in balances.entries)
        entry.key: BalanceHelper.calculateBalance(entry.value),
    };
  }
}
