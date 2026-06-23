import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketentry/core/constants/app_constants.dart';
import 'package:pocketentry/presentation/controllers/support_controller.dart';

class SupportView extends GetView<SupportController> {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الدعم والتواصل')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.support_agent, size: 80, color: Colors.teal),
              const SizedBox(height: 16),
              Text(
                AppConstants.appName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'نحن هنا لمساعدتك. تواصل معنا عبر:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: controller.sendEmail,
                icon: const Icon(Icons.email),
                label: Obx(
                  () => Text('بريد: ${controller.supportEmail.value}'),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: controller.callPhone,
                icon: const Icon(Icons.phone),
                label: Obx(
                  () => Text('هاتف: ${controller.supportPhone.value}'),
                ),
              ),
              const SizedBox(height: 32),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'للإبلاغ عن مشكلة، يرجى وصف المشكلة وإرفاق لقطة شاشة إن أمكن.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
