import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketentry/core/utils/snackbar_helper.dart';
import 'package:pocketentry/domain/entities/entities.dart';
import 'package:pocketentry/domain/usecases/usecases.dart';
import 'package:pocketentry/presentation/widgets/person_form_sheet.dart';
import 'package:pocketentry/routes/app_routes.dart';

class AllPersonsController extends GetxController {
  final PersonUseCases _personUseCases = Get.find();
  final CategoryUseCases _categoryUseCases = Get.find();

  final isLoading = true.obs;
  final persons = <PersonEntity>[].obs;
  final categories = <CategoryEntity>[].obs;
  final searchQuery = ''.obs;
  final selectedCategoryId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      categories.value = await _categoryUseCases.getAll();
      await loadPersons();
    } catch (e) {
      SnackbarHelper.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPersons() async {
    try {
      isLoading.value = true;
      persons.value = await _personUseCases.getAll(
        categoryId: selectedCategoryId.value,
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

  void onCategoryFilterChanged(int? categoryId) {
    selectedCategoryId.value = categoryId;
    loadPersons();
  }

  Future<void> showAddPersonForm() async {
    final result = await PersonFormSheet.show();
    if (result != null) await loadPersons();
  }

  Future<void> showEditPersonForm(PersonEntity person) async {
    final result = await PersonFormSheet.show(person: person);
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
