import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../../core/theme/app_colors.dart';
import '../../../../../providers/payment_provider.dart';
import '../../../../../providers/scholar_provider.dart';
import 'package:mindtek_scholar_app/features/scholar/presentation/pages/payment_details_dialog.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage>
    with SingleTickerProviderStateMixin {
  int _currentPage = 1;
  int _rowsPerPage = 10;
  Map<String, dynamic>? _selectedPayment;
  Map<String, dynamic>? _downloadReceipt;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadPayments();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );
    await paymentProvider.fetchPayments();
  }

  String _capsLetter(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  String _numberToWords(int num) {
    const ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
    ];
    const tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety',
    ];
    const teens = [
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen',
    ];

    String convertToWords(int n) {
      if (n == 0) return '';
      if (n < 10) return ones[n];
      if (n < 20) return teens[n - 10];
      if (n < 100) {
        return tens[n ~/ 10] + (n % 10 != 0 ? ' ${ones[n % 10]}' : '');
      }
      if (n < 1000) {
        return '${ones[n ~/ 100]} Hundred${n % 100 != 0 ? ' ${convertToWords(n % 100)}' : ''}';
      }
      if (n < 100000) {
        return '${convertToWords(n ~/ 1000)} Thousand${n % 1000 != 0 ? ' ${convertToWords(n % 1000)}' : ''}';
      }
      if (n < 10000000) {
        return '${convertToWords(n ~/ 100000)} Lakh${n % 100000 != 0 ? ' ${convertToWords(n % 100000)}' : ''}';
      }
      return '${convertToWords(n ~/ 10000000)} Crore${n % 10000000 != 0 ? ' ${convertToWords(n % 10000000)}' : ''}';
    }

    if (num == 0) return 'Zero';
    return convertToWords(num);
  }

  void _showPaymentDetailsDialog(Map<String, dynamic> payment, int serialNo) {
    showDialog(
      context: context,
      builder: (context) =>
          PaymentDetailsDialog(payment: payment, serialNo: serialNo),
    );
  }

  Future<void> _downloadReceiptAsPDF(Map<String, dynamic> payment) async {
    final scholarProvider = Provider.of<ScholarProvider>(
      context,
      listen: false,
    );
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          pw.Center(
            child: pw.Column(
              children: [
                if (paymentProvider.companyLogo.isNotEmpty)
                  pw.Image(
                    pw.MemoryImage(
                      File(paymentProvider.companyLogo).readAsBytesSync(),
                    ),
                    width: 100,
                    height: 100,
                  ),
                pw.SizedBox(height: 10),
                pw.Text(
                  paymentProvider.companyName,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  paymentProvider.companyAddress,
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Email: ${paymentProvider.companyEmail} | Contact: ${paymentProvider.companyContact}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
                pw.SizedBox(height: 20),
              ],
            ),
          ),
          pw.Center(
            child: pw.Text(
              'PAYMENT RECEIPT',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Date: ${_formatDate(payment['pay_dt_tm'])}',
                style: const pw.TextStyle(fontSize: 11),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  color: payment['pay_status'] == 'approved'
                      ? PdfColors.green
                      : PdfColors.orange,
                  borderRadius: pw.BorderRadius.circular(20),
                ),
                child: pw.Text(
                  _capsLetter(payment['pay_status']),
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Text(
            'SCHOLAR DETAILS',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          _buildInfoRow('Scholar Name:', scholarProvider.name),
          _buildInfoRow('Scholar ID:', scholarProvider.scholarId),
          _buildInfoRow('Email:', scholarProvider.email),
          _buildInfoRow('Contact:', scholarProvider.mobile),
          _buildInfoRow(
            'Work Description:',
            scholarProvider.workDesc,
            isMultiLine: true,
          ),
          pw.SizedBox(height: 15),
          pw.Text(
            'PAYMENT DETAILS',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          _buildInfoRow('Payment Purpose:', payment['purpose']['pay_purpose']),
          _buildInfoRow('Total Amount:', '₹${payment['total_amount']}'),
          _buildInfoRow(
            'Last Payment Amount:',
            '₹${payment['pay_received']}',
            isHighlighted: true,
          ),
          _buildInfoRow('Total Paid:', '₹${payment['tot_paid']}'),
          if (payment['bal_amt'] > 0)
            _buildInfoRow('Balance Amount:', '₹${payment['bal_amt']}'),
          _buildInfoRow(
            'Last Payment Amount in Words:',
            '${_numberToWords(payment['pay_received'])} Rupees Only',
          ),
          pw.SizedBox(height: 15),
          pw.Text(
            'BANK DETAILS',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          _buildInfoRow(
            'Payment Method:',
            'Bank Transfer - ${payment['bank']['bank_nm']}',
          ),
          _buildInfoRow(
            'Account Status:',
            scholarProvider.gstStatus == 'gst' ? 'Account 1' : 'Account 2',
          ),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Authorized Signature'),
                  pw.SizedBox(height: 30),
                  pw.Text(paymentProvider.companyName),
                ],
              ),
              pw.Text(
                'Generated on: ${DateTime.now().toString().split(' ')[0]}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'receipt_${payment['id']}.pdf',
    );
  }

  pw.Widget _buildInfoRow(
    String label,
    String value, {
    bool isHighlighted = false,
    bool isMultiLine = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: isMultiLine
            ? pw.CrossAxisAlignment.start
            : pw.CrossAxisAlignment.center,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: const pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: isHighlighted
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateTime) {
    if (dateTime == null) return '';
    final date = DateTime.parse(dateTime);
    return '${date.day.toString().padLeft(2, '0')} ${_getMonthAbbr(date.month)} ${date.year}';
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  List<int> _getPageNumbers(int totalPages, int currentPage) {
    List<int> pageNumbers = [];
    const int maxPagesToShow = 5;

    if (totalPages <= maxPagesToShow) {
      for (int i = 1; i <= totalPages; i++) {
        pageNumbers.add(i);
      }
    } else {
      int startPage = (currentPage - 2).clamp(1, totalPages);
      int endPage = (startPage + maxPagesToShow - 1).clamp(1, totalPages);

      if (endPage - startPage + 1 < maxPagesToShow) {
        startPage = (endPage - maxPagesToShow + 1).clamp(1, totalPages);
      }

      for (int i = startPage; i <= endPage; i++) {
        pageNumbers.add(i);
      }
    }
    return pageNumbers;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0F172A)
          : const Color(0xFFF0F2F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: _buildPremiumAppBar(isDarkMode),
      ),
      body: Consumer2<PaymentProvider, ScholarProvider>(
        builder: (context, paymentProvider, scholarProvider, child) {
          if (paymentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (paymentProvider.error != null) {
            return _buildErrorWidget(paymentProvider, isDarkMode);
          }

          final payments = paymentProvider.payments;
          final firstPayment = payments.isNotEmpty ? payments.first : null;
          final approvedPayments = payments
              .where((p) => p['pay_status'] == 'approved')
              .toList();

          double totalAmount = 0;
          double totalPaid = 0;
          double balanceAmount = 0;

          if (firstPayment != null) {
            final totalAmountValue = firstPayment['total_amount'];
            final totalPaidValue = firstPayment['tot_paid'];
            final balanceAmountValue = firstPayment['bal_amt'];

            totalAmount = totalAmountValue is double
                ? totalAmountValue
                : double.tryParse(totalAmountValue?.toString() ?? '0') ?? 0;

            totalPaid = totalPaidValue is double
                ? totalPaidValue
                : double.tryParse(totalPaidValue?.toString() ?? '0') ?? 0;

            balanceAmount = balanceAmountValue is double
                ? balanceAmountValue
                : double.tryParse(balanceAmountValue?.toString() ?? '0') ?? 0;
          }

          final totalTransactions = approvedPayments.length;

          final indexOfLastRow = _currentPage * _rowsPerPage;
          final indexOfFirstRow = indexOfLastRow - _rowsPerPage;
          final currentRows = payments.sublist(
            indexOfFirstRow < payments.length ? indexOfFirstRow : 0,
            indexOfLastRow < payments.length ? indexOfLastRow : payments.length,
          );
          final totalPages = (payments.length / _rowsPerPage).ceil();

          return FadeTransition(
            opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: () => paymentProvider.fetchPayments(),
              color: const Color(0xFF1116F4),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 30),
                  // Circular Stats Cards
                  _buildCircularStatsGrid(
                    totalAmount: totalAmount,
                    totalPaid: totalPaid,
                    balanceAmount: balanceAmount,
                    totalTransactions: totalTransactions,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 24),
                  // Transaction List Header
                  _buildListHeader(isDarkMode),
                  const SizedBox(height: 12),
                  // Transaction Cards (instead of table)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentRows.length,
                    itemBuilder: (context, index) {
                      final payment = currentRows[index];
                      final serialNumber = indexOfFirstRow + index + 1;
                      return _buildTransactionCard(
                        payment: payment,
                        serialNumber: serialNumber,
                        isDarkMode: isDarkMode,
                        onTap: () =>
                            _showPaymentDetailsDialog(payment, serialNumber),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Pagination
                  if (payments.isNotEmpty && totalPages > 1)
                    _buildPagination(
                      totalPages: totalPages,
                      currentPage: _currentPage,
                      totalEntries: payments.length,
                      indexOfFirstRow: indexOfFirstRow,
                      indexOfLastRow: indexOfLastRow,
                      isDarkMode: isDarkMode,
                      onPageChanged: (page) =>
                          setState(() => _currentPage = page),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumAppBar(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [const Color(0xFF1A1D3E), const Color(0xFF0A0E27)]
              : [const Color(0xFF1116F4), const Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          // Decorative Circles - Positioned in Stack
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(isDarkMode ? 0.03 : 0.06),
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: 40,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(isDarkMode ? 0.02 : 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(isDarkMode ? 0.02 : 0.05),
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: 120,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(isDarkMode ? 0.04 : 0.08),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Payment Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.currency_rupee_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 25),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment History',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage your transaction history',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularStatsGrid({
    required double totalAmount,
    required double totalPaid,
    required double balanceAmount,
    required int totalTransactions,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildCircularStatCard(
              value: '₹${totalAmount.toStringAsFixed(0)}',
              label: 'Total',
              icon: Icons.currency_rupee_rounded,
              color: const Color(0xFF10B981),
              isDarkMode: isDarkMode,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildCircularStatCard(
              value: '₹${totalPaid.toStringAsFixed(0)}',
              label: 'Paid',
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF6C63FF),
              isDarkMode: isDarkMode,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildCircularStatCard(
              value: '₹${balanceAmount.toStringAsFixed(0)}',
              label: 'Pending',
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFF59E0B),
              isDarkMode: isDarkMode,
            ),
          ),
          // const SizedBox(width: 12),
          // Expanded(
          //   child: _buildCircularStatCard(
          //     value: totalTransactions.toString(),
          //     label: 'Txn',
          //     icon: Icons.receipt_long_rounded,
          //     color: const Color(0xFFEF4444),
          //     isDarkMode: isDarkMode,
          //     isCurrency: false,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildCircularStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required bool isDarkMode,
    bool isCurrency = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1D3E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF1A1D3E),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDarkMode ? Colors.white60 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF3F3D9E)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1D3E),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.filter_list_rounded,
                  size: 14,
                  color: Color(0xFF6C63FF),
                ),
                const SizedBox(width: 4),
                DropdownButton<int>(
                  value: _rowsPerPage,
                  underline: const SizedBox(),
                  dropdownColor: isDarkMode
                      ? const Color(0xFF1A1D3E)
                      : Colors.white,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1D3E),
                    fontSize: 12,
                  ),
                  items: [5, 10, 25, 50].map((value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value rows'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _rowsPerPage = value!;
                      _currentPage = 1;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard({
    required Map<String, dynamic> payment,
    required int serialNumber,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    final amount = payment['pay_received'] ?? 0;
    final isApproved = payment['pay_status'] == 'approved';
    final formattedDate = _formatDate(payment['pay_dt_tm']);

    // Extract day, month, and year from formatted date
    final dateParts = formattedDate.split(' ');
    final day = dateParts.isNotEmpty ? dateParts[0] : '';
    final month = dateParts.length > 1 ? dateParts[1] : '';
    final year = dateParts.length > 2 ? dateParts[2] : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1D3E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Date Column - Day on top, Month+Year in same row below
                SizedBox(
                  width: 50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Day
                      Text(
                        day,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF1A1D3E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Month and Year in same row
                      Row(
                        children: [
                          Text(
                            month,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            year,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDarkMode
                                  ? Colors.white60
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8), // Reduced from 12 to 8
                // // Icon
                // Container(
                //   padding: const EdgeInsets.all(10),
                //   decoration: BoxDecoration(
                //     color: isApproved
                //         ? const Color(0xFF10B981).withOpacity(0.1)
                //         : const Color(0xFFF59E0B).withOpacity(0.1),
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   child: Icon(
                //     isApproved ? Icons.check_circle_rounded : Icons.pending_rounded,
                //     color: isApproved ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                //     size: 22,
                //   ),
                // ),

                // const SizedBox(width: 12),

                // Details - Expanded to take remaining space
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        payment['purpose']['pay_purpose'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF1A1D3E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        payment['bank']['bank_nm'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDarkMode ? Colors.white60 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Amount Column - Fixed width
                SizedBox(
                  width: 85,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '₹${amount.toString()}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isApproved
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isApproved
                              ? const Color(0xFF10B981).withOpacity(0.15)
                              : const Color(0xFFF59E0B).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _capsLetter(payment['pay_status']),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: isApproved
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF6C63FF).withOpacity(0.09),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF6C63FF),
                    size: 20,
                  ),
                ),
                // Chevron Icon
                // const Icon(
                //   Icons.chevron_right_rounded,
                //   size: 20,
                //   color: Color(0xFF6C63FF),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPagination({
    required int totalPages,
    required int currentPage,
    required int totalEntries,
    required int indexOfFirstRow,
    required int indexOfLastRow,
    required bool isDarkMode,
    required Function(int) onPageChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1D3E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${indexOfFirstRow + 1} - ${indexOfLastRow < totalEntries ? indexOfLastRow : totalEntries} of $totalEntries',
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.white60 : Colors.grey[600],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: currentPage != 1
                    ? () => onPageChanged(currentPage - 1)
                    : null,
                color: const Color(0xFF6C63FF),
              ),
              Text(
                '$currentPage / $totalPages',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1D3E),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                onPressed: currentPage != totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                color: const Color(0xFF6C63FF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(PaymentProvider paymentProvider, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1A1D3E) : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.shade300,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Error loading payments',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF1A1D3E),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              paymentProvider.error!,
              style: TextStyle(
                color: isDarkMode ? Colors.white60 : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => paymentProvider.fetchPayments(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
