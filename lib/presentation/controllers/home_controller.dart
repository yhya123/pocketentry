import 'package:get/get.dart';
import 'package:pocketentry/core/utils/snackbar_helper.dart';
import 'package:pocketentry/domain/entities/entities.dart';
import 'package:pocketentry/domain/usecases/usecases.dart';
import 'package:pocketentry/presentation/widgets/person_form_sheet.dart';
import 'package:pocketentry/routes/app_routes.dart';

class HomeController extends GetxController {
  final ReportUseCases _reportUseCases = Get.find();
  final SettingsUseCases _settingsUseCases = Get.find();

  final isLoading = true.obs;
  final stats = DashboardStats().obs;
  final settings = const AppSettingsEntity().obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        _reportUseCases.getDashboardStats(),
        _settingsUseCases.getSettings(),
      ]);
      stats.value = results[0] as DashboardStats;
      settings.value = results[1] as AppSettingsEntity;
    } catch (e) {
      SnackbarHelper.error('تعذر تحميل البيانات');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() => loadData();

  void openAddTransaction() {
    Get.toNamed(AppRoutes.transactionForm)?.then((_) => refreshData());
  }

  Future<void> openAddPerson() async {
    final result = await PersonFormSheet.show();
    if (result != null) await refreshData();
  }
}
