import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:pocketentry/data/datasources/local/category_local_datasource.dart';
import 'package:pocketentry/data/datasources/local/person_local_datasource.dart';
import 'package:pocketentry/data/datasources/local/report_local_datasource.dart';
import 'package:pocketentry/data/datasources/local/settings_local_datasource.dart';
import 'package:pocketentry/data/datasources/local/transaction_local_datasource.dart';
import 'package:pocketentry/data/models/models.dart';
import 'package:pocketentry/domain/entities/entities.dart';
import 'package:pocketentry/domain/repositories/repositories.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._dataSource);
  final CategoryLocalDataSource _dataSource;

  @override
  Future<List<CategoryEntity>> getAll() async {
    final models = await _dataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<CategoryEntity?> getById(int id) async {
    final model = await _dataSource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<int> create(CategoryEntity category) {
    return _dataSource.insert(CategoryModel.fromEntity(category));
  }

  @override
  Future<void> update(CategoryEntity category) {
    return _dataSource.update(CategoryModel.fromEntity(category));
  }

  @override
  Future<void> delete(int id) => _dataSource.delete(id);
}

class PersonRepositoryImpl implements PersonRepository {
  PersonRepositoryImpl(this._dataSource);
  final PersonLocalDataSource _dataSource;

  @override
  Future<List<PersonEntity>> getAll({int? categoryId, String? query}) async {
    final models = await _dataSource.getAll(
      categoryId: categoryId,
      query: query,
    );
    final persons = <PersonEntity>[];
    for (final model in models) {
      final balances = model.id != null
          ? await _dataSource.getBalances(model.id!)
          : <AppCurrency, double>{};
      persons.add(model.toEntity(balances: balances));
    }
    return persons;
  }

  @override
  Future<PersonEntity?> getById(int id) async {
    final model = await _dataSource.getById(id);
    if (model == null) return null;
    final balances = await _dataSource.getBalances(id);
    return model.toEntity(balances: balances);
  }

  @override
  Future<List<PersonEntity>> getByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final persons = <PersonEntity>[];
    for (final id in ids) {
      final person = await getById(id);
      if (person != null) persons.add(person);
    }
    return persons;
  }

  @override
  Future<int> create(PersonEntity person) {
    return _dataSource.insert(PersonModel.fromEntity(person));
  }

  @override
  Future<void> update(PersonEntity person) {
    return _dataSource.update(PersonModel.fromEntity(person));
  }

  @override
  Future<void> delete(int id) => _dataSource.delete(id);

  @override
  Future<Map<AppCurrency, double>> getBalances(int personId) {
    return _dataSource.getBalances(personId);
  }
}

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._dataSource);
  final TransactionLocalDataSource _dataSource;

  @override
  Future<List<TransactionEntity>> getAll({
    int? personId,
    int? categoryId,
    AppCurrency? currency,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final models = await _dataSource.getAll(
      personId: personId,
      categoryId: categoryId,
      currency: currency,
      startDate: startDate,
      endDate: endDate,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<TransactionEntity?> getById(int id) async {
    final model = await _dataSource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<int> create(TransactionEntity transaction) {
    return _dataSource.insert(TransactionModel.fromEntity(transaction));
  }

  @override
  Future<void> update(TransactionEntity transaction) {
    return _dataSource.update(TransactionModel.fromEntity(transaction));
  }

  @override
  Future<void> delete(int id) => _dataSource.delete(id);

  @override
  Future<int> countAll() => _dataSource.countAll();
}

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._dataSource);
  final SettingsLocalDataSource _dataSource;

  @override
  Future<AppSettingsEntity> getSettings() => _dataSource.getSettings();

  @override
  Future<void> saveSettings(AppSettingsEntity settings) =>
      _dataSource.saveSettings(settings);

  @override
  Future<String?> getValue(String key) => _dataSource.getValue(key);

  @override
  Future<void> setValue(String key, String value) =>
      _dataSource.setValue(key, value);
}

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl(this._dataSource);
  final ReportLocalDataSource _dataSource;

  @override
  Future<List<TotalSummaryItem>> getTotalSummary(ReportFilter filter) =>
      _dataSource.getTotalSummary(filter);

  @override
  Future<List<MonthlySummaryItem>> getMonthlySummary(ReportFilter filter) =>
      _dataSource.getMonthlySummary(filter);

  @override
  Future<List<CategorySummaryItem>> getCategorySummary(ReportFilter filter) =>
      _dataSource.getCategorySummary(filter);

  @override
  Future<List<AccountMovementItem>> getAccountMovement(ReportFilter filter) =>
      _dataSource.getAccountMovement(filter);

  @override
  Future<DashboardStats> getDashboardStats() => _dataSource.getDashboardStats();
}
