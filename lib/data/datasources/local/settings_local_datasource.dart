import 'package:pocketentry/core/constants/app_constants.dart';
import 'package:pocketentry/core/constants/db_constants.dart';
import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:pocketentry/data/database/database_helper.dart';
import 'package:pocketentry/domain/entities/entities.dart';
import 'package:sqflite/sqflite.dart';

class SettingsLocalDataSource {
  SettingsLocalDataSource(this._dbHelper);
  final DatabaseHelper _dbHelper;

  Future<String?> getValue(String key) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      DbConstants.tableSettings,
      where: '${DbConstants.colKey} = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return results.first[DbConstants.colValue] as String?;
  }

  Future<void> setValue(String key, String value) async {
    final db = await _dbHelper.database;
    await db.insert(DbConstants.tableSettings, {
      DbConstants.colKey: key,
      DbConstants.colValue: value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<AppSettingsEntity> getSettings() async {
    final currencyValue =
        await getValue(AppConstants.keyDefaultCurrency) ??
        AppCurrency.yer.dbValue;
    final businessName = await getValue(AppConstants.keyBusinessName) ?? '';
    final supportEmail =
        await getValue(AppConstants.keySupportEmail) ??
        AppConstants.supportEmail;
    final supportPhone =
        await getValue(AppConstants.keySupportPhone) ??
        AppConstants.supportPhone;

    return AppSettingsEntity(
      defaultCurrency: AppCurrency.fromDb(currencyValue),
      businessName: businessName,
      supportEmail: supportEmail,
      supportPhone: supportPhone,
    );
  }

  Future<void> saveSettings(AppSettingsEntity settings) async {
    await setValue(
      AppConstants.keyDefaultCurrency,
      settings.defaultCurrency.dbValue,
    );
    await setValue(AppConstants.keyBusinessName, settings.businessName);
    await setValue(AppConstants.keySupportEmail, settings.supportEmail);
    await setValue(AppConstants.keySupportPhone, settings.supportPhone);
  }
}
