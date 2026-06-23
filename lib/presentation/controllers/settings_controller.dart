import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:pocketentry/core/utils/snackbar_helper.dart';
import 'package:pocketentry/domain/entities/entities.dart';
import 'package:pocketentry/domain/usecases/usecases.dart';

class SettingsController extends GetxController {
  final SettingsUseCases _useCases = Get.find();

  final isLoading = true.obs;
  final isSaving = false.obs;
  final settings = const AppSettingsEntity().obs;

  final businessNameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  @override
  void onClose() {
    businessNameController.dispose();
    super.onClose();
  }

  Future<void> loadSettings() async {
    try {
      isLoading.value = true;
      final s = await _useCases.getSettings();
      settings.value = s;
      businessNameController.text = s.businessName;
    } catch (e) {
      SnackbarHelper.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void setDefaultCurrency(AppCurrency currency) {
    settings.value = settings.value.copyWith(defaultCurrency: currency);
  }

  Future<void> save() async {
    try {
      isSaving.value = true;
      final updated = settings.value.copyWith(
        businessName: businessNameController.text.trim(),
      );
      await _useCases.saveSettings(updated);
      settings.value = updated;
      SnackbarHelper.success('تم حفظ الإعدادات');
    } catch (e) {
      SnackbarHelper.error(e.toString());
    } finally {
      isSaving.value = false;
    }
  }
}
