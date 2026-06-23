import 'package:pocketentry/core/constants/db_constants.dart';
import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:pocketentry/data/database/database_helper.dart';
import 'package:pocketentry/data/datasources/local/transaction_local_datasource.dart';
import 'package:pocketentry/domain/entities/entities.dart';

class ReportLocalDataSource {
  ReportLocalDataSource(this._dbHelper, this._transactionDs);
  final DatabaseHelper _dbHelper;
  final TransactionLocalDataSource _transactionDs;

  String _buildFilterWhere(ReportFilter filter, List<Object?> args) {
    final clauses = <String>[];
    if (filter.personId != null) {
      clauses.add('t.${DbConstants.colPersonId} = ?');
      args.add(filter.personId);
    }
    if (filter.categoryId != null) {
      clauses.add('p.${DbConstants.colCategoryId} = ?');
      args.add(filter.categoryId);
    }
    if (filter.currency != null) {
      clauses.add('t.${DbConstants.colCurrency} = ?');
      args.add(filter.currency!.dbValue);
    }
    if (filter.startDate != null) {
      clauses.add('t.${DbConstants.colTransactionDate} >= ?');
      args.add(filter.startDate!.toIso8601String());
    }
    if (filter.endDate != null) {
      final end = DateTime(
        filter.endDate!.year,
        filter.endDate!.month,
        filter.endDate!.day,
        23,
        59,
        59,
      );
      clauses.add('t.${DbConstants.colTransactionDate} <= ?');
      args.add(end.toIso8601String());
    }
    return clauses.isEmpty ? '' : 'WHERE ${clauses.join(' AND ')}';
  }

  Future<List<TotalSummaryItem>> getTotalSummary(ReportFilter filter) async {
    final db = await _dbHelper.database;
    final args = <Object?>[];
    final where = _buildFilterWhere(filter, args);

    final results = await db.rawQuery('''
      SELECT t.${DbConstants.colCurrency} as currency,
             SUM(CASE WHEN t.${DbConstants.colType} = 'debit'
                 THEN t.${DbConstants.colAmount} ELSE 0 END) as total_debit,
             SUM(CASE WHEN t.${DbConstants.colType} = 'credit'
                 THEN t.${DbConstants.colAmount} ELSE 0 END) as total_credit
      FROM ${DbConstants.tableTransactions} t
      INNER JOIN ${DbConstants.tablePersons} p
        ON p.${DbConstants.colId} = t.${DbConstants.colPersonId}
      $where
      GROUP BY t.${DbConstants.colCurrency}
    ''', args);

    return results.map((row) {
      final debit = (row['total_debit'] as num?)?.toDouble() ?? 0;
      final credit = (row['total_credit'] as num?)?.toDouble() ?? 0;
      return TotalSummaryItem(
        currency: AppCurrency.fromDb(row['currency'] as String),
        totalDebit: debit,
        totalCredit: credit,
        netBalance: debit - credit,
      );
    }).toList();
  }

  Future<List<MonthlySummaryItem>> getMonthlySummary(
    ReportFilter filter,
  ) async {
    final db = await _dbHelper.database;
    final args = <Object?>[];
    final where = _buildFilterWhere(filter, args);

    final results = await db.rawQuery('''
      SELECT strftime('%Y-%m', t.${DbConstants.colTransactionDate}) as month_key,
             t.${DbConstants.colCurrency} as currency,
             SUM(CASE WHEN t.${DbConstants.colType} = 'debit'
                 THEN t.${DbConstants.colAmount} ELSE 0 END) as total_debit,
             SUM(CASE WHEN t.${DbConstants.colType} = 'credit'
                 THEN t.${DbConstants.colAmount} ELSE 0 END) as total_credit
      FROM ${DbConstants.tableTransactions} t
      INNER JOIN ${DbConstants.tablePersons} p
        ON p.${DbConstants.colId} = t.${DbConstants.colPersonId}
      $where
      GROUP BY month_key, t.${DbConstants.colCurrency}
      ORDER BY month_key DESC
    ''', args);

    return results.map((row) {
      final parts = (row['month_key'] as String).split('-');
      final month = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      return MonthlySummaryItem(
        month: month,
        currency: AppCurrency.fromDb(row['currency'] as String),
        totalDebit: (row['total_debit'] as num?)?.toDouble() ?? 0,
        totalCredit: (row['total_credit'] as num?)?.toDouble() ?? 0,
      );
    }).toList();
  }

  Future<List<CategorySummaryItem>> getCategorySummary(
    ReportFilter filter,
  ) async {
    final db = await _dbHelper.database;
    final args = <Object?>[];
    final where = _buildFilterWhere(filter, args);

    final results = await db.rawQuery('''
      SELECT c.${DbConstants.colId} as category_id,
             c.${DbConstants.colName} as category_name,
             t.${DbConstants.colCurrency} as currency,
             SUM(CASE WHEN t.${DbConstants.colType} = 'debit'
                 THEN t.${DbConstants.colAmount} ELSE 0 END) as total_debit,
             SUM(CASE WHEN t.${DbConstants.colType} = 'credit'
                 THEN t.${DbConstants.colAmount} ELSE 0 END) as total_credit
      FROM ${DbConstants.tableTransactions} t
      INNER JOIN ${DbConstants.tablePersons} p
        ON p.${DbConstants.colId} = t.${DbConstants.colPersonId}
      INNER JOIN ${DbConstants.tableCategories} c
        ON c.${DbConstants.colId} = p.${DbConstants.colCategoryId}
      $where
      GROUP BY c.${DbConstants.colId}, t.${DbConstants.colCurrency}
      ORDER BY c.${DbConstants.colName}
    ''', args);

    return results.map((row) {
      final debit = (row['total_debit'] as num?)?.toDouble() ?? 0;
      final credit = (row['total_credit'] as num?)?.toDouble() ?? 0;
      return CategorySummaryItem(
        categoryId: row['category_id'] as int,
        categoryName: row['category_name'] as String,
        currency: AppCurrency.fromDb(row['currency'] as String),
        totalDebit: debit,
        totalCredit: credit,
        netBalance: debit - credit,
      );
    }).toList();
  }

  Future<List<AccountMovementItem>> getAccountMovement(
    ReportFilter filter,
  ) async {
    final db = await _dbHelper.database;
    final args = <Object?>[];
    final where = _buildFilterWhere(filter, args);

    final results = await db.rawQuery('''
      SELECT p.${DbConstants.colId} as person_id,
             p.${DbConstants.colName} as person_name,
             c.${DbConstants.colName} as category_name,
             t.${DbConstants.colCurrency} as currency,
             SUM(CASE WHEN t.${DbConstants.colType} = 'debit'
                 THEN t.${DbConstants.colAmount}
                 ELSE -t.${DbConstants.colAmount} END) as balance
      FROM ${DbConstants.tableTransactions} t
      INNER JOIN ${DbConstants.tablePersons} p
        ON p.${DbConstants.colId} = t.${DbConstants.colPersonId}
      INNER JOIN ${DbConstants.tableCategories} c
        ON c.${DbConstants.colId} = p.${DbConstants.colCategoryId}
      $where
      GROUP BY p.${DbConstants.colId}, t.${DbConstants.colCurrency}
      HAVING balance != 0
      ORDER BY p.${DbConstants.colName}
    ''', args);

    return results.map((row) {
      return AccountMovementItem(
        personId: row['person_id'] as int,
        personName: row['person_name'] as String,
        categoryName: row['category_name'] as String,
        currency: AppCurrency.fromDb(row['currency'] as String),
        balance: (row['balance'] as num?)?.toDouble() ?? 0,
      );
    }).toList();
  }

  Future<DashboardStats> getDashboardStats() async {
    final db = await _dbHelper.database;
    final categories = await db.rawQuery(
      'SELECT COUNT(*) as c FROM ${DbConstants.tableCategories}',
    );
    final persons = await db.rawQuery(
      'SELECT COUNT(*) as c FROM ${DbConstants.tablePersons}',
    );
    final transactions = await _transactionDs.countAll();
    final summary = await getTotalSummary(const ReportFilter());

    return DashboardStats(
      totalCategories: (categories.first['c'] as int?) ?? 0,
      totalPersons: (persons.first['c'] as int?) ?? 0,
      totalTransactions: transactions,
      summaryItems: summary,
    );
  }
}
