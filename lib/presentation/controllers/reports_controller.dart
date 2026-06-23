import 'package:get/get.dart';
import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:pocketentry/core/utils/snackbar_helper.dart';
import 'package:pocketentry/domain/entities/entities.dart';
import 'package:pocketentry/domain/usecases/usecases.dart';
import 'package:pocketentry/services/pdf_report_service.dart';

class ReportsController extends GetxController {
  final ReportUseCases _reportUseCases = Get.find();
  final TransactionUseCases _transactionUseCases = Get.find();
  final CategoryUseCases _categoryUseCases = Get.find();
  final PersonUseCases _personUseCases = Get.find();
  final SettingsUseCases _settingsUseCases = Get.find();
  final PdfReportService _pdfService = Get.find();

  final isLoading = false.obs;
  final selectedReportType = ReportType.totalSummary.obs;
  final filter = const ReportFilter().obs;

  final totalItems = <TotalSummaryItem>[].obs;
  final transactions = <TransactionEntity>[].obs;
  final monthlyItems = <MonthlySummaryItem>[].obs;
  final categoryItems = <CategorySummaryItem>[].obs;
  final movementItems = <AccountMovementItem>[].obs;

  final categories = <CategoryEntity>[].obs;
  final persons = <PersonEntity>[].obs;
  final settings = const AppSettingsEntity().obs;

  @override
  void onInit() {
    super.onInit();
    _loadFiltersData();
    generateReport();
  }

  Future<void> _loadFiltersData() async {
    try {
      final results = await Future.wait([
        _categoryUseCases.getAll(),
        _personUseCases.getAll(),
        _settingsUseCases.getSettings(),
      ]);
      categories.value = results[0] as List<CategoryEntity>;
      persons.value = results[1] as List<PersonEntity>;
      settings.value = results[2] as AppSettingsEntity;
    } catch (_) {}
  }

  void updateFilter(ReportFilter newFilter) {
    filter.value = newFilter;
    generateReport();
  }

  Future<void> generateReport() async {
    try {
      isLoading.value = true;
      final f = filter.value;
      switch (selectedReportType.value) {
        case ReportType.totalSummary:
          totalItems.value = await _reportUseCases.getTotalSummary(f);
        case ReportType.detailSummary:
          transactions.value = await _transactionUseCases.getAll(
            categoryId: f.categoryId,
            personId: f.personId,
            currency: f.currency,
            startDate: f.startDate,
            endDate: f.endDate,
          );
        case ReportType.monthlySummary:
          monthlyItems.value = await _reportUseCases.getMonthlySummary(f);
        case ReportType.categorySummary:
          categoryItems.value = await _reportUseCases.getCategorySummary(f);
        case ReportType.accountMovement:
          movementItems.value = await _reportUseCases.getAccountMovement(f);
      }
    } catch (e) {
      SnackbarHelper.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String get reportTitle {
    switch (selectedReportType.value) {
      case ReportType.totalSummary:
        return 'تقرير إجمالي المبالغ';
      case ReportType.detailSummary:
        return 'تقرير تفاصيل المبالغ';
      case ReportType.monthlySummary:
        return 'تقرير إجمالي شهري';
      case ReportType.categorySummary:
        return 'تقرير حسب التصنيف';
      case ReportType.accountMovement:
        return 'تقرير حركة الحسابات';
    }
  }

  Future<void> exportPdf() async {
    try {
      isLoading.value = true;
      final doc = await _pdfService.buildReport(
        type: selectedReportType.value,
        title: reportTitle,
        businessName: settings.value.businessName,
        filter: filter.value,
        totalItems: totalItems,
        transactions: transactions,
        monthlyItems: monthlyItems,
        categoryItems: categoryItems,
        movementItems: movementItems,
      );
      await _pdfService.printReport(doc);
    } catch (e) {
      SnackbarHelper.error('تعذر إنشاء PDF: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sharePdf() async {
    try {
      isLoading.value = true;
      final doc = await _pdfService.buildReport(
        type: selectedReportType.value,
        title: reportTitle,
        businessName: settings.value.businessName,
        filter: filter.value,
        totalItems: totalItems,
        transactions: transactions,
        monthlyItems: monthlyItems,
        categoryItems: categoryItems,
        movementItems: movementItems,
      );
      await _pdfService.shareReport(doc, '$reportTitle.pdf');
    } catch (e) {
      SnackbarHelper.error('تعذر مشاركة PDF: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
