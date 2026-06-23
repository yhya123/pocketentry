import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:pocketentry/core/utils/formatters.dart';
import 'package:pocketentry/core/widgets/common_widgets.dart';
import 'package:pocketentry/presentation/controllers/backup_controller.dart';

class BackupView extends GetView<BackupController> {
  const BackupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('النسخ الاحتياطي')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingOverlay(message: 'جاري المعالجة...');
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'إنشاء نسخة احتياطية',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'احفظ نسخة من قاعدة البيانات محلياً على الجهاز.',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: controller.createBackup,
                      icon: const Icon(Icons.save),
                      label: const Text('إنشاء نسخة احتياطية'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: controller.tryGoogleDriveBackup,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Google Drive (قريباً)'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'النسخ المحفوظة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (controller.backups.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'لا توجد نسخ احتياطية محفوظة',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...controller.backups.map(
                (backup) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      backup.source == BackupSource.local
                          ? Icons.storage
                          : Icons.cloud,
                    ),
                    title: Text(backup.fileName),
                    subtitle: Text(
                      DateFormatter.formatDateTime(backup.createdAt),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.restore, color: Colors.orange),
                      tooltip: 'استرجاع',
                      onPressed: () => controller.restoreBackup(backup),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
