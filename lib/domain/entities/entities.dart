import 'package:pocketentry/core/enums/app_enums.dart';

class CategoryEntity {
  const CategoryEntity({
    this.id,
    required this.name,
    this.isDefault = false,
    this.createdAt,
    this.personCount = 0,
  });

  final int? id;
  final String name;
  final bool isDefault;
  final DateTime? createdAt;
  final int personCount;

  CategoryEntity copyWith({
    int? id,
    String? name,
    bool? isDefault,
    DateTime? createdAt,
    int? personCount,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      personCount: personCount ?? this.personCount,
    );
  }
}

class PersonEntity {
  const PersonEntity({
    this.id,
    required this.categoryId,
    required this.name,
    required this.phone,
    this.address,
    this.notes,
    this.createdAt,
    this.categoryName,
    this.balances = const {},
    this.lastTransactionDate,
  });

  final int? id;
  final int categoryId;
  final String name;
  final String phone;
  final String? address;
  final String? notes;
  final DateTime? createdAt;
  final String? categoryName;
  final Map<AppCurrency, double> balances;
  final DateTime? lastTransactionDate;

  PersonEntity copyWith({
    int? id,
    int? categoryId,
    String? name,
    String? phone,
    String? address,
    String? notes,
    DateTime? createdAt,
    String? categoryName,
    Map<AppCurrency, double>? balances,
    DateTime? lastTransactionDate,
  }) {
    return PersonEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      categoryName: categoryName ?? this.categoryName,
      balances: balances ?? this.balances,
      lastTransactionDate: lastTransactionDate ?? this.lastTransactionDate,
    );
  }
}

class TransactionEntity {
  const TransactionEntity({
    this.id,
    required this.personId,
    required this.type,
    required this.amount,
    required this.currency,
    this.details,
    required this.transactionDate,
    this.imagePath,
    this.createdAt,
    this.personName,
    this.categoryName,
  });

  final int? id;
  final int personId;
  final TransactionType type;
  final double amount;
  final AppCurrency currency;
  final String? details;
  final DateTime transactionDate;
  final String? imagePath;
  final DateTime? createdAt;
  final String? personName;
  final String? categoryName;

  TransactionEntity copyWith({
    int? id,
    int? personId,
    TransactionType? type,
    double? amount,
    AppCurrency? currency,
    String? details,
    DateTime? transactionDate,
    String? imagePath,
    DateTime? createdAt,
    String? personName,
    String? categoryName,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      details: details ?? this.details,
      transactionDate: transactionDate ?? this.transactionDate,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      personName: personName ?? this.personName,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}

class AppSettingsEntity {
  const AppSettingsEntity({
    this.defaultCurrency = AppCurrency.yer,
    this.businessName = '',
    this.supportEmail = '',
    this.supportPhone = '',
  });

  final AppCurrency defaultCurrency;
  final String businessName;
  final String supportEmail;
  final String supportPhone;

  AppSettingsEntity copyWith({
    AppCurrency? defaultCurrency,
    String? businessName,
    String? supportEmail,
    String? supportPhone,
  }) {
    return AppSettingsEntity(
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      businessName: businessName ?? this.businessName,
      supportEmail: supportEmail ?? this.supportEmail,
      supportPhone: supportPhone ?? this.supportPhone,
    );
  }
}

class ReportFilter {
  const ReportFilter({
    this.startDate,
    this.endDate,
    this.categoryId,
    this.personId,
    this.currency,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final int? categoryId;
  final int? personId;
  final AppCurrency? currency;

  ReportFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    int? personId,
    AppCurrency? currency,
    bool clearCategory = false,
    bool clearPerson = false,
    bool clearCurrency = false,
  }) {
    return ReportFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      personId: clearPerson ? null : (personId ?? this.personId),
      currency: clearCurrency ? null : (currency ?? this.currency),
    );
  }
}

class TotalSummaryItem {
  const TotalSummaryItem({
    required this.currency,
    required this.totalDebit,
    required this.totalCredit,
    required this.netBalance,
  });

  final AppCurrency currency;
  final double totalDebit;
  final double totalCredit;
  final double netBalance;
}

class MonthlySummaryItem {
  const MonthlySummaryItem({
    required this.month,
    required this.currency,
    required this.totalDebit,
    required this.totalCredit,
  });

  final DateTime month;
  final AppCurrency currency;
  final double totalDebit;
  final double totalCredit;
}

class CategorySummaryItem {
  const CategorySummaryItem({
    required this.categoryId,
    required this.categoryName,
    required this.currency,
    required this.totalDebit,
    required this.totalCredit,
    required this.netBalance,
  });

  final int categoryId;
  final String categoryName;
  final AppCurrency currency;
  final double totalDebit;
  final double totalCredit;
  final double netBalance;
}

class AccountMovementItem {
  const AccountMovementItem({
    required this.personId,
    required this.personName,
    required this.categoryName,
    required this.currency,
    required this.balance,
  });

  final int personId;
  final String personName;
  final String categoryName;
  final AppCurrency currency;
  final double balance;
}

class DashboardStats {
  const DashboardStats({
    this.totalCategories = 0,
    this.totalPersons = 0,
    this.totalTransactions = 0,
    this.summaryItems = const [],
  });

  final int totalCategories;
  final int totalPersons;
  final int totalTransactions;
  final List<TotalSummaryItem> summaryItems;
}
