import 'package:flutter_test/flutter_test.dart';
import 'package:pocketentry/core/utils/formatters.dart';
import 'package:pocketentry/core/enums/app_enums.dart';

void main() {
  test('BalanceHelper calculates correctly', () {
    final balance = BalanceHelper.calculateBalance([
      (type: TransactionType.debit, amount: 100),
      (type: TransactionType.credit, amount: 30),
      (type: TransactionType.debit, amount: 50),
    ]);
    expect(balance, 120);
  });
}
