import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:pocketentry/core/utils/snackbar_helper.dart';
import 'package:pocketentry/domain/entities/entities.dart';
import 'package:pocketentry/domain/usecases/usecases.dart';
import 'package:pocketentry/routes/app_routes.dart';
import 'package:pocketentry/services/image_service.dart';

class PersonDetailController extends GetxController {
  final PersonUseCases _personUseCases = Get.find();
  final TransactionUseCases _transactionUseCases = Get.find();
  final ImageService _imageService = Get.find();

  final isLoading = true.obs;
  final person = Rxn<PersonEntity>();
  final transactions = <TransactionEntity>[].obs;
  final selectedCurrency = Rxn<AppCurrency>();

  late int personId;

  @override
  void onInit() {
    super.onInit();
    personId = (Get.arguments as Map)['personId'] as int;
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      final p = await _personUseCases.getById(personId);
      person.value = p;
      if (p != null && p.balances.isNotEmpty) {
        selectedCurrency.value ??= p.balances.keys.first;
      }
      transactions.value = await _transactionUseCases.getAll(
        personId: personId,
      );
    } catch (e) {
      SnackbarHelper.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void openAddTransaction() {
    Get.toNamed(
      AppRoutes.transactionForm,
      arguments: {'personId': personId},
    )?.then((_) => loadData());
  }

  void openEditTransaction(TransactionEntity transaction) {
    Get.toNamed(
      AppRoutes.transactionForm,
      arguments: {'personId': personId, 'transactionId': transaction.id},
    )?.then((_) => loadData());
  }

  Future<void> deleteTransaction(TransactionEntity transaction) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('حذف العملية'),
        content: const Text('هل تريد حذف هذه العملية؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _imageService.deleteImage(transaction.imagePath);
      await _transactionUseCases.delete(transaction.id!);
      SnackbarHelper.success('تم حذف العملية');
      await loadData();
    } catch (e) {
      SnackbarHelper.error(e.toString());
    }
  }
}
