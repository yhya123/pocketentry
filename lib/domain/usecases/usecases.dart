import 'package:pocketentry/core/constants/app_constants.dart';
import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:pocketentry/domain/entities/entities.dart';
import 'package:pocketentry/domain/repositories/repositories.dart';

class CategoryUseCases {
  CategoryUseCases(this._repo);
  final CategoryRepository _repo;

  Future<List<CategoryEntity>> getAll() => _repo.getAll();
  Future<CategoryEntity?> getById(int id) => _repo.getById(id);
  Future<int> create(CategoryEntity category) => _repo.create(category);
  Future<void> update(CategoryEntity category) => _repo.update(category);
  Future<void> delete(int id) => _repo.delete(id);
}

class PersonUseCases {
  PersonUseCases(this._repo);
  final PersonRepository _repo;

  Future<List<PersonEntity>> getAll({int? categoryId, String? query}) =>
      _repo.getAll(categoryId: categoryId, query: query);
  Future<PersonEntity?> getById(int id) => _repo.getById(id);
  Future<List<PersonEntity>> getByIds(List<int> ids) => _repo.getByIds(ids);
  Future<int> create(PersonEntity person) => _repo.create(person);
  Future<void> update(PersonEntity person) => _repo.update(person);
  Future<void> delete(int id) => _repo.delete(id);
  Future<Map<AppCurrency, double>> getBalances(int personId) =>
      _repo.getBalances(personId);
}

class TransactionUseCases {
  TransactionUseCases(this._repo);
  final TransactionRepository _repo;

  Future<List<TransactionEntity>> getAll({
    int? personId,
    int? categoryId,
    AppCurrency? currency,
    DateTime? startDate,
    DateTime? endDate,
  }) => _repo.getAll(
    personId: personId,
    categoryId: categoryId,
    currency: currency,
    startDate: startDate,
    endDate: endDate,
  );
  Future<TransactionEntity?> getById(int id) => _repo.getById(id);
  Future<int> create(TransactionEntity transaction) =>
      _repo.create(transaction);
  Future<void> update(TransactionEntity transaction) =>
      _repo.update(transaction);
  Future<void> delete(int id) => _repo.delete(id);
}

class SettingsUseCases {
  SettingsUseCases(this._repo);
  final SettingsRepository _repo;

  Future<AppSettingsEntity> getSettings() => _repo.getSettings();
  Future<void> saveSettings(AppSettingsEntity settings) =>
      _repo.saveSettings(settings);

  Future<AppCurrency> getPreferredCurrency() async {
    final lastUsed = await _repo.getValue(AppConstants.keyLastUsedCurrency);
    if (lastUsed != null) {
      return AppCurrency.fromDb(lastUsed);
    }
    final settings = await getSettings();
    return settings.defaultCurrency;
  }

  Future<void> saveLastUsedCurrency(AppCurrency currency) =>
      _repo.setValue(AppConstants.keyLastUsedCurrency, currency.dbValue);

  Future<List<int>> getRecentPersonIds() async {
    final raw = await _repo.getValue(AppConstants.keyRecentPersonIds);
    if (raw == null || raw.isEmpty) return [];
    return raw
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList();
  }

  Future<void> addRecentPerson(int personId) async {
    final current = await getRecentPersonIds();
    final updated = [
      personId,
      ...current.where((id) => id != personId),
    ].take(AppConstants.maxRecentPersons).toList();
    await _repo.setValue(AppConstants.keyRecentPersonIds, updated.join(','));
  }
}

class ReportUseCases {
  ReportUseCases(this._repo);
  final ReportRepository _repo;

  Future<List<TotalSummaryItem>> getTotalSummary(ReportFilter filter) =>
      _repo.getTotalSummary(filter);
  Future<List<MonthlySummaryItem>> getMonthlySummary(ReportFilter filter) =>
      _repo.getMonthlySummary(filter);
  Future<List<CategorySummaryItem>> getCategorySummary(ReportFilter filter) =>
      _repo.getCategorySummary(filter);
  Future<List<AccountMovementItem>> getAccountMovement(ReportFilter filter) =>
      _repo.getAccountMovement(filter);
  Future<DashboardStats> getDashboardStats() => _repo.getDashboardStats();
}
