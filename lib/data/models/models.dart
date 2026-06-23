import 'package:pocketentry/core/constants/db_constants.dart';
import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:pocketentry/domain/entities/entities.dart';

class CategoryModel {
  CategoryModel({
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

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map[DbConstants.colId] as int?,
      name: map[DbConstants.colName] as String,
      isDefault: (map[DbConstants.colIsDefault] as int? ?? 0) == 1,
      createdAt: map[DbConstants.colCreatedAt] != null
          ? DateTime.parse(map[DbConstants.colCreatedAt] as String)
          : null,
      personCount: map['person_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.colId: id,
      DbConstants.colName: name,
      DbConstants.colIsDefault: isDefault ? 1 : 0,
      DbConstants.colCreatedAt: (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  CategoryEntity toEntity() => CategoryEntity(
    id: id,
    name: name,
    isDefault: isDefault,
    createdAt: createdAt,
    personCount: personCount,
  );

  static CategoryModel fromEntity(CategoryEntity entity) => CategoryModel(
    id: entity.id,
    name: entity.name,
    isDefault: entity.isDefault,
    createdAt: entity.createdAt,
    personCount: entity.personCount,
  );
}

class PersonModel {
  PersonModel({
    this.id,
    required this.categoryId,
    required this.name,
    required this.phone,
    this.address,
    this.notes,
    this.createdAt,
    this.categoryName,
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
  final DateTime? lastTransactionDate;

  factory PersonModel.fromMap(Map<String, dynamic> map) {
    return PersonModel(
      id: map[DbConstants.colId] as int?,
      categoryId: map[DbConstants.colCategoryId] as int,
      name: map[DbConstants.colName] as String,
      phone: map[DbConstants.colPhone] as String,
      address: map[DbConstants.colAddress] as String?,
      notes: map[DbConstants.colNotes] as String?,
      createdAt: map[DbConstants.colCreatedAt] != null
          ? DateTime.parse(map[DbConstants.colCreatedAt] as String)
          : null,
      categoryName: map['category_name'] as String?,
      lastTransactionDate: map['last_transaction_date'] != null
          ? DateTime.parse(map['last_transaction_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.colId: id,
      DbConstants.colCategoryId: categoryId,
      DbConstants.colName: name,
      DbConstants.colPhone: phone,
      DbConstants.colAddress: address,
      DbConstants.colNotes: notes,
      DbConstants.colCreatedAt: (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  PersonEntity toEntity({Map<AppCurrency, double> balances = const {}}) =>
      PersonEntity(
        id: id,
        categoryId: categoryId,
        name: name,
        phone: phone,
        address: address,
        notes: notes,
        createdAt: createdAt,
        categoryName: categoryName,
        balances: balances,
        lastTransactionDate: lastTransactionDate,
      );

  static PersonModel fromEntity(PersonEntity entity) => PersonModel(
    id: entity.id,
    categoryId: entity.categoryId,
    name: entity.name,
    phone: entity.phone,
    address: entity.address,
    notes: entity.notes,
    createdAt: entity.createdAt,
    categoryName: entity.categoryName,
  );
}

class TransactionModel {
  TransactionModel({
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

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map[DbConstants.colId] as int?,
      personId: map[DbConstants.colPersonId] as int,
      type: TransactionType.fromDb(map[DbConstants.colType] as String),
      amount: (map[DbConstants.colAmount] as num).toDouble(),
      currency: AppCurrency.fromDb(map[DbConstants.colCurrency] as String),
      details: map[DbConstants.colDetails] as String?,
      transactionDate: DateTime.parse(
        map[DbConstants.colTransactionDate] as String,
      ),
      imagePath: map[DbConstants.colImagePath] as String?,
      createdAt: map[DbConstants.colCreatedAt] != null
          ? DateTime.parse(map[DbConstants.colCreatedAt] as String)
          : null,
      personName: map['person_name'] as String?,
      categoryName: map['category_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) DbConstants.colId: id,
      DbConstants.colPersonId: personId,
      DbConstants.colType: type.dbValue,
      DbConstants.colAmount: amount,
      DbConstants.colCurrency: currency.dbValue,
      DbConstants.colDetails: details,
      DbConstants.colTransactionDate: transactionDate.toIso8601String(),
      DbConstants.colImagePath: imagePath,
      DbConstants.colCreatedAt: (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  TransactionEntity toEntity() => TransactionEntity(
    id: id,
    personId: personId,
    type: type,
    amount: amount,
    currency: currency,
    details: details,
    transactionDate: transactionDate,
    imagePath: imagePath,
    createdAt: createdAt,
    personName: personName,
    categoryName: categoryName,
  );

  static TransactionModel fromEntity(TransactionEntity entity) =>
      TransactionModel(
        id: entity.id,
        personId: entity.personId,
        type: entity.type,
        amount: entity.amount,
        currency: entity.currency,
        details: entity.details,
        transactionDate: entity.transactionDate,
        imagePath: entity.imagePath,
        createdAt: entity.createdAt,
        personName: entity.personName,
        categoryName: entity.categoryName,
      );
}
