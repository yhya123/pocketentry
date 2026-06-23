import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:pocketentry/core/utils/formatters.dart';
import 'package:pocketentry/core/widgets/common_widgets.dart';
import 'package:pocketentry/presentation/controllers/reports_controller.dart';
import 'package:pocketentry/presentation/widgets/balance_chip.dart';
import 'package:pocketentry/presentation/widgets/report_filter_panel.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'طباعة PDF',
            onPressed: controller.exportPdf,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'مشاركة PDF',
            onPressed: controller.sharePdf,
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: ReportType.values.map((type) {
                  final selected = controller.selectedReportType.value == type;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(_reportLabel(type)),
                      selected: selected,
                      onSelected: (_) {
                        controller.selectedReportType.value = type;
                        controller.generateReport();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          ReportFilterPanel(
            filter: controller.filter.value,
            categories: controller.categories,
            persons: controller.persons,
            onChanged: controller.updateFilter,
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildReportContent();
            }),
          ),
        ],
      ),
    );
  }

  String _reportLabel(ReportType type) {
    switch (type) {
      case ReportType.totalSummary:
        return 'إجمالي';
      case ReportType.detailSummary:
        return 'تفاصيل';
      case ReportType.monthlySummary:
        return 'شهري';
      case ReportType.categorySummary:
        return 'تصنيفات';
      case ReportType.accountMovement:
        return 'حركة';
    }
  }

  Widget _buildReportContent() {
    switch (controller.selectedReportType.value) {
      case ReportType.totalSummary:
        if (controller.totalItems.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.bar_chart,
            title: 'لا توجد بيانات',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.totalItems.length,
          itemBuilder: (_, i) {
            final item = controller.totalItems[i];
            return Card(
              child: ListTile(
                title: Text(item.currency.labelAr),
                subtitle: Text(
                  'عليه: ${CurrencyFormatter.format(item.totalDebit, item.currency)}\n'
                  'له: ${CurrencyFormatter.format(item.totalCredit, item.currency)}',
                ),
                trailing: BalanceChip(
                  balance: item.netBalance,
                  currency: item.currency,
                ),
              ),
            );
          },
        );
      case ReportType.detailSummary:
        if (controller.transactions.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.list_alt,
            title: 'لا توجد عمليات',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.transactions.length,
          itemBuilder: (_, i) {
            final tx = controller.transactions[i];
            return Card(
              child: ListTile(
                title: Text('${tx.personName} — ${tx.type.labelAr}'),
                subtitle: Text(
                  '${DateFormatter.formatDate(tx.transactionDate)}\n'
                  '${tx.categoryName ?? ''} — ${tx.details ?? ''}',
                ),
                trailing: Text(
                  CurrencyFormatter.format(tx.amount, tx.currency),
                  style: TextStyle(
                    color: tx.type == TransactionType.debit
                        ? Colors.red
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      case ReportType.monthlySummary:
        if (controller.monthlyItems.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.calendar_month,
            title: 'لا توجد بيانات',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.monthlyItems.length,
          itemBuilder: (_, i) {
            final item = controller.monthlyItems[i];
            return Card(
              child: ListTile(
                title: Text(DateFormatter.formatMonthYear(item.month)),
                subtitle: Text(item.currency.labelAr),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'عليه: ${CurrencyFormatter.format(item.totalDebit, item.currency)}',
                    ),
                    Text(
                      'له: ${CurrencyFormatter.format(item.totalCredit, item.currency)}',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      case ReportType.categorySummary:
        if (controller.categoryItems.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.category,
            title: 'لا توجد بيانات',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.categoryItems.length,
          itemBuilder: (_, i) {
            final item = controller.categoryItems[i];
            return Card(
              child: ListTile(
                title: Text(item.categoryName),
                subtitle: Text(item.currency.labelAr),
                trailing: BalanceChip(
                  balance: item.netBalance,
                  currency: item.currency,
                ),
              ),
            );
          },
        );
      case ReportType.accountMovement:
        if (controller.movementItems.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.swap_horiz,
            title: 'لا توجد حركات',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.movementItems.length,
          itemBuilder: (_, i) {
            final item = controller.movementItems[i];
            return Card(
              child: ListTile(
                title: Text(item.personName),
                subtitle: Text(item.categoryName),
                trailing: BalanceChip(
                  balance: item.balance,
                  currency: item.currency,
                ),
              ),
            );
          },
        );
    }
  }
}
