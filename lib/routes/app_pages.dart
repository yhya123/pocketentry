import 'package:get/get.dart';
import 'package:pocketentry/presentation/controllers/all_persons_controller.dart';
import 'package:pocketentry/presentation/controllers/backup_controller.dart';
import 'package:pocketentry/presentation/controllers/categories_controller.dart';
import 'package:pocketentry/presentation/controllers/home_controller.dart';
import 'package:pocketentry/presentation/controllers/person_detail_controller.dart';
import 'package:pocketentry/presentation/controllers/persons_controller.dart';
import 'package:pocketentry/presentation/controllers/reports_controller.dart';
import 'package:pocketentry/presentation/controllers/search_controller.dart';
import 'package:pocketentry/presentation/controllers/settings_controller.dart';
import 'package:pocketentry/presentation/controllers/support_controller.dart';
import 'package:pocketentry/presentation/controllers/transaction_form_controller.dart';
import 'package:pocketentry/presentation/views/backup/backup_view.dart';
import 'package:pocketentry/presentation/views/categories/categories_view.dart';
import 'package:pocketentry/presentation/views/home/home_view.dart';
import 'package:pocketentry/presentation/views/persons/all_persons_view.dart';
import 'package:pocketentry/presentation/views/persons/person_detail_view.dart';
import 'package:pocketentry/presentation/views/persons/persons_view.dart';
import 'package:pocketentry/presentation/views/reports/reports_view.dart';
import 'package:pocketentry/presentation/views/search/search_view.dart';
import 'package:pocketentry/presentation/views/settings/settings_view.dart';
import 'package:pocketentry/presentation/views/support/support_view.dart';
import 'package:pocketentry/presentation/views/transactions/transaction_form_view.dart';
import 'package:pocketentry/routes/app_routes.dart';

class AppPages {
  static const initial = AppRoutes.home;

  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(HomeController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.categories,
      page: () => const CategoriesView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(CategoriesController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.persons,
      page: () => const PersonsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(PersonsController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.personDetail,
      page: () => const PersonDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(PersonDetailController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.transactionForm,
      page: () => const TransactionFormView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(TransactionFormController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(ReportsController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(SettingsController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.backup,
      page: () => const BackupView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(BackupController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.support,
      page: () => const SupportView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(SupportController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.allPersons,
      page: () => const AllPersonsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(AllPersonsController.new);
      }),
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(PersonSearchController.new);
      }),
    ),
  ];
}
