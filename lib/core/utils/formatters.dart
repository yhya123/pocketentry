import 'package:intl/intl.dart';
import 'package:pocketentry/core/enums/app_enums.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount, AppCurrency currency) {
    final formatter = NumberFormat('#,##0.##', 'ar');
    return '${formatter.format(amount)} ${currency.symbol}';
  }

  static String formatSigned(double amount, AppCurrency currency) {
    final prefix = amount >= 0 ? '+' : '';
    return '$prefix${format(amount, currency)}';
  }
}

class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd', 'ar').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy/MM/dd HH:mm', 'ar').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'ar').format(date);
  }
}

class BalanceHelper {
  BalanceHelper._();

  /// الرصيد = مجموع (عليه) − مجموع (له)
  static double calculateBalance(
    List<({TransactionType type, double amount})> transactions,
  ) {
    double balance = 0;
    for (final tx in transactions) {
      if (tx.type == TransactionType.debit) {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
    }
    return balance;
  }

  static String balanceLabel(double balance) {
    if (balance > 0) return 'عليه';
    if (balance < 0) return 'له';
    return 'متعادل';
  }
}
