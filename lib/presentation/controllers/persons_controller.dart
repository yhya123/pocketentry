import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketentry/core/utils/snackbar_helper.dart';
import 'package:pocketentry/domain/entities/entities.dart';
import 'package:pocketentry/domain/usecases/usecases.dart';
import 'package:pocketentry/presentation/widgets/person_form_sheet.dart';
import 'package:pocketentry/routes/app_routes.dart';

class PersonsController extends GetxController {
  final PersonUseCases _personUseCases = Get.find();

  final isLoading = true.obs;
  final persons = <PersonEntity>[].obs;
  final searchQuery = ''.obs;

  late int categoryId;
  late String categoryName;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    categoryId = args['categoryId'] as int;
    categoryName = args['categoryName'] as String;
    loadPersons();
  }

  Future<void> loadPersons() async {
    try {
      isLoading.value = true;
      persons.value = await _personUseCases.getAll(
        categoryId: categoryId,
        query: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
    } catch (e) {
      SnackbarHelper.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    loadPersons();
  }

  Future<void> showPersonForm({PersonEntity? person}) async {
    final result = await PersonFormSheet.show(
      person: person,
      defaultCategoryId: categoryId,
    );
    if (result != null) await loadPersons();
  }

  Future<void> deletePerson(PersonEntity person) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('حذف الحساب'),
        content: Text(
          'هل تريد حذف "${person.name}"؟\nسيتم حذف جميع العمليات المرتبطة به.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _personUseCases.delete(person.id!);
      SnackbarHelper.success('تم حذف الحساب');
      await loadPersons();
    } catch (e) {
      SnackbarHelper.error(e.toString());
    }
  }

  void openPersonDetail(PersonEntity person) {
    Get.toNamed(
      AppRoutes.personDetail,
      arguments: {'personId': person.id},
    )?.then((_) => loadPersons());
  }
}
