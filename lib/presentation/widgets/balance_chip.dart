import 'package:flutter/material.dart';
import 'package:pocketentry/core/constants/app_colors.dart';
import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:pocketentry/core/utils/formatters.dart';

class BalanceChip extends StatelessWidget {
  const BalanceChip({
    super.key,
    required this.balance,
    required this.currency,
    this.compact = false,
  });

  final double balance;
  final AppCurrency currency;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final label = BalanceHelper.balanceLabel(balance);
    final color = balance > 0
        ? AppColors.debit
        : balance < 0
        ? AppColors.credit
        : AppColors.textSecondary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Color(color).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        compact
            ? '$label ${CurrencyFormatter.format(balance.abs(), currency)}'
            : '$label: ${CurrencyFormatter.format(balance.abs(), currency)}',
        style: TextStyle(
          color: Color(color),
          fontWeight: FontWeight.w600,
          fontSize: compact ? 11 : 13,
        ),
      ),
    );
  }
}
