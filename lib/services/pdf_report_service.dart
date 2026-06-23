import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pocketentry/core/constants/app_constants.dart';
import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:pocketentry/core/utils/formatters.dart';
import 'package:pocketentry/domain/entities/entities.dart';

class PdfReportService {
  Future<pw.Document> buildReport({
    required ReportType type,
    required String title,
    String? businessName,
    ReportFilter filter = const ReportFilter(),
    List<TotalSummaryItem>? totalItems,
    List<TransactionEntity>? transactions,
    List<MonthlySummaryItem>? monthlyItems,
    List<CategorySummaryItem>? categoryItems,
    List<AccountMovementItem>? movementItems,
  }) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.notoNaskhArabicRegular();
    final fontBold = await PdfGoogleFonts.notoNaskhArabicBold();
    final now = DateFormatter.formatDateTime(DateTime.now());

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              businessName?.isNotEmpty == true
                  ? businessName!
                  : AppConstants.appName,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(title, style: const pw.TextStyle(fontSize: 14)),
            pw.Text(
              'تاريخ التقرير: $now',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Divider(),
          ],
        ),

        build: (context) {
          switch (type) {
            case ReportType.totalSummary:
              return _buildTotalSummary(totalItems ?? []);
            case ReportType.detailSummary:
              return _buildDetailSummary(transactions ?? []);
            case ReportType.monthlySummary:
              return _buildMonthlySummary(monthlyItems ?? []);
            case ReportType.categorySummary:
              return _buildCategorySummary(categoryItems ?? []);
            case ReportType.accountMovement:
              return _buildAccountMovement(movementItems ?? []);
          }
        },
      ),
    );
    return doc;
  }

  List<pw.Widget> _buildTotalSummary(List<TotalSummaryItem> items) {
    if (items.isEmpty) {
      return [pw.Text('لا توجد بيانات')];
    }
    return [
      pw.TableHelper.fromTextArray(
        headers: ['العملة', 'إجمالي عليه', 'إجمالي له', 'الصافي'],
        data: items
            .map(
              (e) => [
                e.currency.labelAr,
                CurrencyFormatter.format(e.totalDebit, e.currency),
                CurrencyFormatter.format(e.totalCredit, e.currency),
                CurrencyFormatter.format(e.netBalance, e.currency),
              ],
            )
            .toList(),
      ),
    ];
  }

  List<pw.Widget> _buildDetailSummary(List<TransactionEntity> items) {
    if (items.isEmpty) {
      return [pw.Text('لا توجد عمليات')];
    }
    return [
      pw.TableHelper.fromTextArray(
        headers: [
          'التاريخ',
          'الحساب',
          'التصنيف',
          'النوع',
          'المبلغ',
          'التفاصيل',
        ],
        data: items
            .map(
              (e) => [
                DateFormatter.formatDate(e.transactionDate),
                e.personName ?? '',
                e.categoryName ?? '',
                e.type.labelAr,
                CurrencyFormatter.format(e.amount, e.currency),
                e.details ?? '',
              ],
            )
            .toList(),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      ),
    ];
  }

  List<pw.Widget> _buildMonthlySummary(List<MonthlySummaryItem> items) {
    if (items.isEmpty) {
      return [pw.Text('لا توجد بيانات')];
    }
    return [
      pw.TableHelper.fromTextArray(
        headers: ['الشهر', 'العملة', 'عليه', 'له'],
        data: items
            .map(
              (e) => [
                DateFormatter.formatMonthYear(e.month),
                e.currency.labelAr,
                CurrencyFormatter.format(e.totalDebit, e.currency),
                CurrencyFormatter.format(e.totalCredit, e.currency),
              ],
            )
            .toList(),
      ),
    ];
  }

  List<pw.Widget> _buildCategorySummary(List<CategorySummaryItem> items) {
    if (items.isEmpty) {
      return [pw.Text('لا توجد بيانات')];
    }
    return [
      pw.TableHelper.fromTextArray(
        headers: ['التصنيف', 'العملة', 'عليه', 'له', 'الصافي'],
        data: items
            .map(
              (e) => [
                e.categoryName,
                e.currency.labelAr,
                CurrencyFormatter.format(e.totalDebit, e.currency),
                CurrencyFormatter.format(e.totalCredit, e.currency),
                CurrencyFormatter.format(e.netBalance, e.currency),
              ],
            )
            .toList(),
      ),
    ];
  }

  List<pw.Widget> _buildAccountMovement(List<AccountMovementItem> items) {
    if (items.isEmpty) {
      return [pw.Text('لا توجد حركات')];
    }
    return [
      pw.TableHelper.fromTextArray(
        cellAlignment: pw.Alignment.center,

        // tableDirection: pw.TextDirection.ltr,
        // headerDirection: pw.TextDirection.rtl,
        headers: [
          'الحساب',
          'التصنيف',
          'العملة',
          'الرصيد',
          "حالة الرصيد",
        ].reversed.toList(),
        data: items
            .map(
              (e) => [
                e.personName,
                e.categoryName,
                e.currency.labelAr,

                CurrencyFormatter.format(e.balance.abs(), e.currency),
                "   ${e.balance <= 0 ? ' له' : ' عليه '}  ",
              ].reversed.toList(),
            )
            .toList(),
        // .reversed
        // .toList()
      ),
    ];
  }

  Future<void> printReport(pw.Document doc) async {
    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  Future<void> shareReport(pw.Document doc, String fileName) async {
    final bytes = await doc.save();
    final xFile = XFile.fromData(
      Uint8List.fromList(bytes),
      name: fileName,
      mimeType: 'application/pdf',
    );
    await Share.shareXFiles([xFile], text: 'تقرير $fileName');
  }
}
