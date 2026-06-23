import 'package:pocketentry/core/constants/db_constants.dart';
import 'package:pocketentry/core/errors/failures.dart';
import 'package:pocketentry/data/database/database_helper.dart';
import 'package:pocketentry/data/models/models.dart';
import 'package:sqflite/sqflite.dart';

class CategoryLocalDataSource {
  CategoryLocalDataSource(this._dbHelper);
  final DatabaseHelper _dbHelper;

  Future<List<CategoryModel>> getAll() async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT c.*, COUNT(p.${DbConstants.colId}) as person_count
      FROM ${DbConstants.tableCategories} c
      LEFT JOIN ${DbConstants.tablePersons} p
        ON p.${DbConstants.colCategoryId} = c.${DbConstants.colId}
      GROUP BY c.${DbConstants.colId}
      ORDER BY c.${DbConstants.colIsDefault} DESC, c.${DbConstants.colName} ASC
    ''');
    return results.map(CategoryModel.fromMap).toList();
  }

  Future<CategoryModel?> getById(int id) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      DbConstants.tableCategories,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return CategoryModel.fromMap(results.first);
  }

  Future<int> insert(CategoryModel model) async {
    final db = await _dbHelper.database;
    return db.insert(DbConstants.tableCategories, model.toMap());
  }

  Future<void> update(CategoryModel model) async {
    final db = await _dbHelper.database;
    await db.update(
      DbConstants.tableCategories,
      model.toMap(),
      where: '${DbConstants.colId} = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _dbHelper.database;
    final category = await getById(id);
    if (category == null) throw NotFoundFailure('التصنيف غير موجود');
    if (category.isDefault) {
      throw ValidationFailure('لا يمكن حذف التصنيف الافتراضي');
    }
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        '''
      SELECT COUNT(*) FROM ${DbConstants.tablePersons}
      WHERE ${DbConstants.colCategoryId} = ?
    ''',
        [id],
      ),
    );
    if ((count ?? 0) > 0) {
      throw ValidationFailure('لا يمكن حذف تصنيف يحتوي على حسابات');
    }
    await db.delete(
      DbConstants.tableCategories,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }
}
