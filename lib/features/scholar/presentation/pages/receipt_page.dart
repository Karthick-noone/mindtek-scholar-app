import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:mindtek_scholar_app/core/theme/app_colors.dart';

class ReceiptPage extends StatelessWidget {
  final String receiptNo;
  final String date;
  final String scholarId;
  final String amount;
  final String inWords;
  final String description;

  const ReceiptPage({
    super.key,
    required this.receiptNo,
    required this.date,
    required this.scholarId,
    required this.amount,
    required this.inWords,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          "Receipt",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.white,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: () => _generatePDF(context),
            ),
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow(context),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "SEA SENSE",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Receipt #$receiptNo",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  "Marthandam, Kanyakumari District\n"
                  "Tamil Nadu - 629165\n"
                  "Phone : 04651-271057",
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 20),

                /// Receipt Info Table
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Table(
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                        width: 1,
                      ),
                      verticalInside: BorderSide(
                        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    children: [
                      _tableRow(context, "Receipt No", receiptNo),
                      _tableRow(context, "Date", date),
                      _tableRow(context, "Scholar ID", scholarId),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// Payment Details
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Table(
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                        width: 1,
                      ),
                      verticalInside: BorderSide(
                        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    children: [
                      _tableRow(context, "Amount Paid", "₹ $amount", isBold: true),
                      _tableRow(context, "In Words", inWords),
                      _tableRow(context, "Description", description, isMultiline: true),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// Total Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.gradientStart.withOpacity(0.1),
                        AppColors.gradientEnd.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Amount:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        "₹ $amount",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                /// Signature
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 200,
                        height: 1,
                        color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Authorized Signature",
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// Company Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Sea Sense Interdisciplinary Research and IT Solution (OPC) Pvt. Ltd.",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.textPrimary(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "JJ Arcade, Second Floor, Near New Bus Stand Marthandam, "
                        "Kanyakumari District, Tamil Nadu - 629165",
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TableRow _tableRow(
    BuildContext context, 
    String title, 
    String value, {
    bool isBold = false,
    bool isMultiline = false,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return TableRow(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold 
                  ? AppColors.primary 
                  : (isDarkMode ? Colors.white70 : Colors.black87),
            ),
            maxLines: isMultiline ? 3 : 1,
            overflow: isMultiline ? TextOverflow.ellipsis : null,
          ),
        ),
      ],
    );
  }
/// ---------------- PDF ----------------
Future<void> _generatePDF(BuildContext context) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Container(
          width: double.infinity,
          height: double.infinity,
          color: PdfColor.fromHex("#DCEFF4"), // Always light blue background
          padding: const pw.EdgeInsets.all(25),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              /// HEADER ROW
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [

                  /// LEFT SIDE
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "SEA SENSE",
                        style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        "Marthandam, Kanyakumari District,\n"
                        "Tamil Nadu - 629165\n"
                        "Phone : 04651-271057",
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.black, // Always black text
                        ),
                      ),
                      pw.SizedBox(height: 15),
                      pw.Text(
                        "Bill To :  Ratheesh",
                        style: const pw.TextStyle(
                          color: PdfColors.black, // Always black text
                        ),
                      ),
                    ],
                  ),

                  /// RIGHT SIDE TABLE
                  pw.Container(
                    width: 200,
                    child: pw.Table(
                      border: pw.TableBorder.all(
                        width: 1,
                        color: PdfColors.grey, // Always grey border
                      ),
                      children: [
                        pw.TableRow(children: [
                          _pdfCellTitle("Receipt"),
                          _pdfCellTitle("Date"),
                        ]),
                        pw.TableRow(children: [
                          _pdfCellValue(receiptNo),
                          _pdfCellValue(date),
                        ]),
                        pw.TableRow(children: [
                          _pdfCellTitle("Scholar Id"),
                          _pdfCellTitle("Work Id"),
                        ]),
                        pw.TableRow(children: [
                          _pdfCellValue(scholarId),
                          _pdfCellValue(""),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 25),

              /// PAYMENT DETAILS TABLE
              pw.Table(
                border: pw.TableBorder.all(
                  width: 1,
                  color: PdfColors.grey, // Always grey border
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(4),
                },
                children: [
                  pw.TableRow(children: [
                    _pdfCellTitle("Amount Paid"),
                    _pdfCellValue(" ₹ $amount"),
                  ]),
                  pw.TableRow(children: [
                    _pdfCellTitle("In Words"),
                    _pdfCellValue(inWords),
                  ]),
                  pw.TableRow(children: [
                    _pdfCellTitle("Description"),
                    _pdfCellValue(description),
                  ]),
                ],
              ),

              pw.SizedBox(height: 40),

              /// SIGNATURE
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  children: [
                    pw.Container(
                      width: 200,
                      height: 1,
                      color: PdfColors.grey400, // Always grey line
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      "Authorized Signature",
                      style: const pw.TextStyle(
                        color: PdfColors.black, // Always black text
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              /// COMPANY FOOTER
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex("#F5F5F5"), // Always light grey
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      "Sea Sense Interdisciplinary Research and IT Solution (OPC) Pvt. Ltd.",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                        color: PdfColors.black, // Always black text
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "JJ Arcade, Second Floor, Near New Bus Stand Marthandam, "
                      "Kanyakumari District\nTamilNadu, India - 629165",
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.black, // Always black text
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

pw.Widget _pdfCellTitle(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.black, // Always black text
      ),
    ),
  );
}

pw.Widget _pdfCellValue(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(
      text,
      style: const pw.TextStyle(
        color: PdfColors.black, // Always black text
      ),
    ),
  );
}
}
