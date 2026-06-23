import 'package:get/get.dart';
import 'package:pocketentry/data/database/database_helper.dart';
import 'package:pocketentry/data/datasources/local/category_local_datasource.dart';
import 'package:pocketentry/data/datasources/local/person_local_datasource.dart';
import 'package:pocketentry/data/datasources/local/report_local_datasource.dart';
import 'package:pocketentry/data/datasources/local/settings_local_datasource.dart';
import 'package:pocketentry/data/datasources/local/transaction_local_datasource.dart';
import 'package:pocketentry/data/repositories/repository_impl.dart';
import 'package:pocketentry/domain/repositories/repositories.dart';
import 'package:pocketentry/domain/usecases/usecases.dart';
import 'package:pocketentry/services/backup_service.dart';
import 'package:pocketentry/services/image_service.dart';
import 'package:pocketentry/services/pdf_report_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Database
    Get.put(DatabaseHelper.instance, permanent: true);

    // Data sources
    Get.lazyPut(() => CategoryLocalDataSource(Get.find()), fenix: true);
    Get.lazyPut(() => PersonLocalDataSource(Get.find()), fenix: true);
    Get.lazyPut(() => TransactionLocalDataSource(Get.find()), fenix: true);
    Get.lazyPut(() => SettingsLocalDataSource(Get.find()), fenix: true);
    Get.lazyPut(
      () => ReportLocalDataSource(Get.find(), Get.find()),
      fenix: true,
    );

    // Repositories
    Get.lazyPut<CategoryRepository>(
      () => CategoryRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<PersonRepository>(
      () => PersonRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<TransactionRepository>(
      () => TransactionRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<SettingsRepository>(
      () => SettingsRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<ReportRepository>(
      () => ReportRepositoryImpl(Get.find()),
      fenix: true,
    );

    // Use cases
    Get.lazyPut(() => CategoryUseCases(Get.find()), fenix: true);
    Get.lazyPut(() => PersonUseCases(Get.find()), fenix: true);
    Get.lazyPut(() => TransactionUseCases(Get.find()), fenix: true);
    Get.lazyPut(() => SettingsUseCases(Get.find()), fenix: true);
    Get.lazyPut(() => ReportUseCases(Get.find()), fenix: true);

    // Services
    Get.lazyPut(ImageService.new, fenix: true);
    Get.lazyPut(PdfReportService.new, fenix: true);
    Get.lazyPut(
      () => BackupService(localProvider: LocalBackupProvider(Get.find())),
      fenix: true,
    );
  }
}
