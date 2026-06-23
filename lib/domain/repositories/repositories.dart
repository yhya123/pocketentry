import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:pocketentry/domain/entities/entities.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getAll();
  Future<CategoryEntity?> getById(int id);
  Future<int> create(CategoryEntity category);
  Future<void> update(CategoryEntity category);
  Future<void> delete(int id);
}

abstract class PersonRepository {
  Future<List<PersonEntity>> getAll({int? categoryId, String? query});
  Future<PersonEntity?> getById(int id);
  Future<List<PersonEntity>> getByIds(List<int> ids);
  Future<int> create(PersonEntity person);
  Future<void> update(PersonEntity person);
  Future<void> delete(int id);
  Future<Map<AppCurrency, double>> getBalances(int personId);
}

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getAll({
    int? personId,
    int? categoryId,
    AppCurrency? currency,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<TransactionEntity?> getById(int id);
  Future<int> create(TransactionEntity transaction);
  Future<void> update(TransactionEntity transaction);
  Future<void> delete(int id);
  Future<int> countAll();
}

abstract class SettingsRepository {
  Future<AppSettingsEntity> getSettings();
  Future<void> saveSettings(AppSettingsEntity settings);
  Future<String?> getValue(String key);
  Future<void> setValue(String key, String value);
}

abstract class ReportRepository {
  Future<List<TotalSummaryItem>> getTotalSummary(ReportFilter filter);
  Future<List<MonthlySummaryItem>> getMonthlySummary(ReportFilter filter);
  Future<List<CategorySummaryItem>> getCategorySummary(ReportFilter filter);
  Future<List<AccountMovementItem>> getAccountMovement(ReportFilter filter);
  Future<DashboardStats> getDashboardStats();
}
