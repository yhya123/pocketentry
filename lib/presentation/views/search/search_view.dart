import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketentry/core/widgets/common_widgets.dart';
import 'package:pocketentry/presentation/controllers/search_controller.dart';
import 'package:pocketentry/presentation/widgets/balance_chip.dart';

class SearchView extends GetView<PersonSearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('بحث عن حساب')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppSearchField(
              hint: 'اكتب الاسم أو رقم الهاتف...',
              onChanged: controller.onSearchChanged,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.searchQuery.value.trim().length < 2) {
                return const EmptyStateWidget(
                  icon: Icons.search,
                  title: 'ابدأ بالكتابة للبحث',
                  subtitle: 'أدخل حرفين على الأقل',
                );
              }
              if (controller.persons.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.person_off,
                  title: 'لا توجد نتائج',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.persons.length,
                itemBuilder: (_, i) {
                  final person = controller.persons[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(person.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(person.phone, textDirection: TextDirection.ltr),
                          if (person.categoryName != null)
                            Text(person.categoryName!),
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
                      onTap: () => controller.openPerson(person),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
