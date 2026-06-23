import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketentry/core/utils/formatters.dart';
import 'package:pocketentry/core/widgets/common_widgets.dart';
import 'package:pocketentry/presentation/controllers/all_persons_controller.dart';
import 'package:pocketentry/presentation/widgets/balance_chip.dart';

class AllPersonsView extends GetView<AllPersonsController> {
  const AllPersonsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الحسابات')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: AppSearchField(
              hint: 'بحث بالاسم أو رقم الهاتف...',
              onChanged: controller.onSearchChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() {
              return DropdownButtonFormField<int?>(
                value: controller.selectedCategoryId.value,
                decoration: const InputDecoration(
                  labelText: 'فلترة حسب التصنيف',
                  prefixIcon: Icon(Icons.filter_list),
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('جميع التصنيفات'),
                  ),
                  ...controller.categories.map(
                    (c) => DropdownMenuItem<int?>(
                      value: c.id,
                      child: Text(c.name),
                    ),
                  ),
                ],
                onChanged: controller.onCategoryFilterChanged,
              );
            }),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.persons.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.people_outline,
                  title: 'لا يوجد حسابات',
                  subtitle:
                      controller.searchQuery.value.isNotEmpty ||
                          controller.selectedCategoryId.value != null
                      ? 'جرّب تغيير معايير البحث أو الفلترة'
                      : 'أضف أول حساب للبدء',
                  actionLabel: 'إضافة حساب',
                  onAction: controller.showAddPersonForm,
                );
              }
              return RefreshIndicator(
                onRefresh: controller.loadPersons,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.persons.length,
                  itemBuilder: (context, index) {
                    final person = controller.persons[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(person.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${person.categoryName ?? ''} • ${person.phone}',
                              textDirection: TextDirection.ltr,
                            ),
                            if (person.lastTransactionDate != null)
                              Text(
                                'آخر حركة: ${DateFormatter.formatDate(person.lastTransactionDate!)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            if (person.balances.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Wrap(
                                  spacing: 4,
                                  children: person.balances.entries
                                      .where((e) => e.value != 0)
                                      .map(
                                        (e) => BalanceChip(
                                          balance: e.value,
                                          currency: e.key,
                                          compact: true,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              controller.showEditPersonForm(person);
                            } else if (value == 'delete') {
                              controller.deletePerson(person);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('تعديل')),
                            PopupMenuItem(value: 'delete', child: Text('حذف')),
                          ],
                        ),
                        onTap: () => controller.openPersonDetail(person),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.showAddPersonForm,
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة حساب'),
      ),
    );
  }
}
