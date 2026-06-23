import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:pocketentry/core/utils/snackbar_helper.dart';
import 'package:pocketentry/services/backup_service.dart';

class BackupController extends GetxController {
  final BackupService _backupService = Get.find();

  final isLoading = false.obs;
  final backups = <BackupFileInfo>[].obs;
  final selectedSource = BackupSource.local.obs;

  @override
  void onInit() {
    super.onInit();
    loadBackups();
  }

  Future<void> loadBackups() async {
    try {
      isLoading.value = true;
      backups.value = await _backupService.listBackups(selectedSource.value);
    } catch (e) {
      SnackbarHelper.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createBackup() async {
    try {
      isLoading.value = true;
      await _backupService.backup(selectedSource.value);
      SnackbarHelper.success('تم إنشاء النسخة الاحتياطية بنجاح');
      await loadBackups();
    } catch (e) {
      SnackbarHelper.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> restoreBackup(BackupFileInfo backup) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('استرجاع النسخة الاحتياطية'),
        content: const Text(
          'تحذير: سيتم استبدال جميع البيانات الحالية بالنسخة الاحتياطية.\n'
          'هل أنت متأكد من المتابعة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('استرجاع'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      isLoading.value = true;
      await _backupService.restore(selectedSource.value, backup.path);
      SnackbarHelper.success('تم استرجاع النسخة الاحتياطية');
      Get.offAllNamed('/');
    } catch (e) {
      SnackbarHelper.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> tryGoogleDriveBackup() async {
    SnackbarHelper.info(
      'Google Drive غير مفعّل حالياً. البنية جاهزة للتوسعة — راجع README.',
    );
  }
}
