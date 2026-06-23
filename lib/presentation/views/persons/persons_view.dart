import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketentry/core/widgets/common_widgets.dart';
import 'package:pocketentry/presentation/controllers/persons_controller.dart';
import 'package:pocketentry/presentation/widgets/balance_chip.dart';

class PersonsView extends GetView<PersonsController> {
  const PersonsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(controller.categoryName)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppSearchField(
              hint: 'بحث بالاسم أو الهاتف...',
              onChanged: controller.onSearchChanged,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.persons.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.person_outline,
                  title: 'لا يوجد حسابات',
                  subtitle: 'أضف حساباً في هذا التصنيف',
                  actionLabel: 'إضافة حساب',
                  onAction: () => controller.showPersonForm(),
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
                              person.phone,
                              textDirection: TextDirection.ltr,
                            ),
                            if (person.balances.isNotEmpty)
                              Wrap(
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
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              controller.showPersonForm(person: person);
                            } else if (value == 'delete') {
                              controller.deletePerson(person);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('تعديل'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('حذف'),
                            ),
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
        onPressed: () => controller.showPersonForm(),
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة حساب'),
      ),
    );
  }
}
