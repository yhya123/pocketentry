/// أنواع العمليات المالية:
/// [debit] عليه — يزيد ما على الحساب (مدين)
/// [credit] له — يقلل المديونية أو يزيد ما للحساب (دائن)
enum TransactionType {
  debit,
  credit;

  String get labelAr {
    switch (this) {
      case TransactionType.debit:
        return 'عليه';
      case TransactionType.credit:
        return 'له';
    }
  }

  String get dbValue => name;

  static TransactionType fromDb(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionType.debit,
    );
  }
}

/// العملات المدعومة
enum AppCurrency {
  yer,
  sar,
  usd;

  String get labelAr {
    switch (this) {
      case AppCurrency.yer:
        return 'ريال يمني';
      case AppCurrency.sar:
        return 'ريال سعودي';
      case AppCurrency.usd:
        return 'دولار';
    }
  }

  String get symbol {
    switch (this) {
      case AppCurrency.yer:
        return 'ر.ي';
      case AppCurrency.sar:
        return 'ر.س';
      case AppCurrency.usd:
        return '\$';
    }
  }

  String get dbValue => name;

  static AppCurrency fromDb(String value) {
    return AppCurrency.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppCurrency.yer,
    );
  }
}

/// أنواع التقارير
enum ReportType {
  totalSummary,
  detailSummary,
  monthlySummary,
  categorySummary,
  accountMovement,
}

/// مصدر النسخ الاحتياطي (جاهز للتوسعة — Google Drive لاحقًا)
enum BackupSource { local, googleDrive }
