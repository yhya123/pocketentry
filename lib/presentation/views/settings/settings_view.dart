import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:pocketentry/presentation/controllers/settings_controller.dart';
import 'package:pocketentry/routes/app_routes.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: controller.businessNameController,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                labelText: 'اسم المحل / الجهة',
                prefixIcon: Icon(Icons.store),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'العملة الافتراضية',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                spacing: 8,
                children: AppCurrency.values.map((currency) {
                  final selected =
                      controller.settings.value.defaultCurrency == currency;
                  return ChoiceChip(
                    label: Text(currency.labelAr),
                    selected: selected,
                    onSelected: (_) => controller.setDefaultCurrency(currency),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('النسخ الاحتياطي'),
              trailing: const Icon(Icons.arrow_back_ios, size: 16),
              onTap: () => Get.toNamed(AppRoutes.backup),
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('الدعم والتواصل'),
              trailing: const Icon(Icons.arrow_back_ios, size: 16),
              onTap: () => Get.toNamed(AppRoutes.support),
            ),
            const SizedBox(height: 24),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isSaving.value ? null : controller.save,
                child: controller.isSaving.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('حفظ الإعدادات'),
              ),
            ),
          ],
        );
      }),
    );
  }
}
