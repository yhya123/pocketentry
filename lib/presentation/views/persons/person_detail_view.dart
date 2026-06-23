import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketentry/core/constants/app_colors.dart';
import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:pocketentry/core/utils/formatters.dart';
import 'package:pocketentry/core/widgets/common_widgets.dart';
import 'package:pocketentry/domain/entities/entities.dart';
import 'package:pocketentry/presentation/controllers/person_detail_controller.dart';
import 'package:pocketentry/presentation/widgets/balance_chip.dart';

class PersonDetailView extends GetView<PersonDetailController> {
  const PersonDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(controller.person.value?.name ?? 'تفاصيل الحساب'),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final person = controller.person.value;
        if (person == null) {
          return const EmptyStateWidget(
            icon: Icons.error_outline,
            title: 'الحساب غير موجود',
          );
        }
        return Column(
          children: [
            _PersonHeader(person: person),
            Expanded(
              child: controller.transactions.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.receipt_long_outlined,
                      title: 'لا توجد عمليات',
                      subtitle: 'اضغط الزر أدناه لإضافة عملية',
                    )
                  : RefreshIndicator(
                      onRefresh: controller.loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.transactions.length,
                        itemBuilder: (context, index) {
                          final tx = controller.transactions[index];
                          return _TransactionTile(
                            transaction: tx,
                            onEdit: () => controller.openEditTransaction(tx),
                            onDelete: () => controller.deleteTransaction(tx),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.openAddTransaction,
        icon: const Icon(Icons.add),
        label: const Text('عملية جديدة'),
      ),
    );
  }
}

class _PersonHeader extends StatelessWidget {
  const _PersonHeader({required this.person});
  final PersonEntity person;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: const Color(AppColors.primary).withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (person.categoryName != null)
            Text(
              person.categoryName!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          Text(
            person.phone,
            textDirection: TextDirection.ltr,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (person.address != null) Text(person.address!),
          if (person.notes != null) ...[
            const SizedBox(height: 4),
            Text(person.notes!, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 12),
          if (person.balances.isEmpty)
            const Text('لا يوجد رصيد')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: person.balances.entries
                  .map((e) => BalanceChip(balance: e.value, currency: e.key))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  final TransactionEntity transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDebit = transaction.type == TransactionType.debit;
    final color = isDebit ? AppColors.debit : AppColors.credit;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(color).withValues(alpha: 0.15),
          child: Icon(
            isDebit ? Icons.arrow_downward : Icons.arrow_upward,
            color: Color(color),
          ),
        ),
        title: Text(
          '${transaction.type.labelAr} — ${CurrencyFormatter.format(transaction.amount, transaction.currency)}',
          style: TextStyle(color: Color(color), fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormatter.formatDate(transaction.transactionDate)),
            if (transaction.details != null) Text(transaction.details!),
            if (transaction.imagePath != null)
              TextButton.icon(
                onPressed: () => _showImage(context, transaction.imagePath!),
                icon: const Icon(Icons.image, size: 18),
                label: const Text('عرض السند'),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('تعديل')),
            const PopupMenuItem(value: 'delete', child: Text('حذف')),
          ],
        ),
      ),
    );
  }

  void _showImage(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.file(File(path), fit: BoxFit.contain),
        ),
      ),
    );
  }
}
