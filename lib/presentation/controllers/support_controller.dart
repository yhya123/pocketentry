import 'package:get/get.dart';
import 'package:pocketentry/core/constants/app_constants.dart';
import 'package:pocketentry/domain/usecases/usecases.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportController extends GetxController {
  final SettingsUseCases _settingsUseCases = Get.find();

  final isLoading = true.obs;
  final supportEmail = AppConstants.supportEmail.obs;
  final supportPhone = AppConstants.supportPhone.obs;

  @override
  void onInit() {
    super.onInit();
    loadSupportInfo();
  }

  Future<void> loadSupportInfo() async {
    try {
      isLoading.value = true;
      final settings = await _settingsUseCases.getSettings();
      supportEmail.value = settings.supportEmail;
      supportPhone.value = settings.supportPhone;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail.value,
      queryParameters: {'subject': 'دعم ${AppConstants.appName}'},
    );
    if (!await launchUrl(uri)) {
      Get.snackbar('خطأ', 'تعذر فتح تطبيق البريد');
    }
  }

  Future<void> callPhone() async {
    final uri = Uri(scheme: 'tel', path: supportPhone.value);
    if (!await launchUrl(uri)) {
      Get.snackbar('خطأ', 'تعذر فتح تطبيق الهاتف');
    }
  }
}
