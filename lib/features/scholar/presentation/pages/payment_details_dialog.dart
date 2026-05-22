// lib/features/payment/presentation/pages/payment_details_dialog.dart
import 'package:flutter/material.dart';
import 'package:mindtek_scholar_app/core/theme/app_colors.dart';

class PaymentDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> payment;
  final int serialNo;

  const PaymentDetailsDialog({
    super.key,
    required this.payment,
    required this.serialNo,
  });

  double _getNumberValue(dynamic value) {
    if (value == null) return 0;
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0;
  }

  String _getValue(dynamic value, {bool isDate = false}) {
    if (value == null) return 'N/A';
    if (value is String && value.isEmpty) return 'N/A';

    if (isDate && value is String) {
      return _formatDate(value);
    }

    return value.toString();
  }

  String _formatDate(String dateTimeStr) {
    try {
      String dateStr = dateTimeStr;
      if (dateStr.contains(' ')) {
        dateStr = dateStr.split(' ')[0];
      }
      if (dateStr.contains('T')) {
        dateStr = dateStr.split('T')[0];
      }
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')} ${_getMonthAbbr(date.month)} ${date.year}';
    } catch (e) {
      return dateTimeStr;
    }
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final balanceAmount = _getNumberValue(payment['bal_amt']);
    final totalAmount = _getNumberValue(payment['total_amount']);
    final amountPaid = _getNumberValue(payment['pay_received']);
    final progressPercent = totalAmount > 0 ? (amountPaid / totalAmount) : 0.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ), // Add inset padding
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, double scale, child) {
          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: scale,
              child: Container(
                width:
                    MediaQuery.of(context).size.width *
                    0.95, // Increased to 95%
                // maxWidth: 600, // Increased max width
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium Header with Gradient
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF2D5BE3), Color(0xFF4F46E5)],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Payment Details",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Transaction #$serialNo",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Payment Summary Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF10B981).withOpacity(0.1),
                                  const Color(0xFF10B981).withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF10B981).withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Total Amount",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "₹ ${_getValue(payment['total_amount'])}",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Progress Bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: progressPercent,
                                    backgroundColor: Colors.grey[200],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF10B981),
                                        ),
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Paid: ₹ ${_getValue(payment['pay_received'])}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                    Text(
                                      "Remaining: ₹ ${_getValue(payment['bal_amt'])}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: balanceAmount > 0
                                            ? Colors.orange[600]
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Details Section Title
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 20,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2D5BE3),
                                      Color(0xFF4F46E5),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Transaction Details",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Details Grid
                          _buildPremiumDetailRow(
                            context,
                            Icons.calendar_today_rounded,
                            "Payment Date",
                            _getValue(payment['pay_dt_tm'], isDate: true),
                            isDarkMode,
                          ),

                          _buildPremiumDetailRow(
                            context,
                            Icons.currency_rupee_rounded,
                            "Total Amount",
                            "₹ ${_getValue(payment['total_amount'])}",
                            isDarkMode,
                          ),

                          _buildPremiumDetailRow(
                            context,
                            Icons.payment_rounded,
                            "Amount Paid",
                            "₹ ${_getValue(payment['pay_received'])}",
                            isDarkMode,
                            isHighlighted: true,
                          ),

                          _buildPremiumDetailRow(
                            context,
                            Icons.account_balance_wallet_rounded,
                            "Total Paid",
                            "₹ ${_getValue(payment['tot_paid'])}",
                            isDarkMode,
                          ),

                          if (balanceAmount > 0)
                            _buildPremiumDetailRow(
                              context,
                              Icons.warning_amber_rounded,
                              "Balance Amount",
                              "₹ ${_getValue(payment['bal_amt'])}",
                              isDarkMode,
                              isBalance: true,
                            ),

                          _buildPremiumDetailRow(
                            context,
                            Icons.account_balance_rounded,
                            "Bank Name",
                            _getValue(payment['bank']?['bank_nm']),
                            isDarkMode,
                          ),

                          _buildPremiumDetailRow(
                            context,
                            Icons.description_rounded,
                            "Payment Purpose",
                            _getValue(payment['purpose']?['pay_purpose']),
                            isDarkMode,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    bool isDarkMode, {
    bool isHighlighted = false,
    bool isBalance = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isBalance
                  ? const Color(0xFFEF4444).withOpacity(0.1)
                  : (isHighlighted
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : const Color(0xFF2D5BE3).withOpacity(0.1)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isBalance
                  ? const Color(0xFFEF4444)
                  : (isHighlighted
                        ? const Color(0xFF10B981)
                        : const Color(0xFF2D5BE3)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isHighlighted || isBalance
                        ? FontWeight.bold
                        : FontWeight.w600,
                    color: isBalance
                        ? const Color(0xFFEF4444)
                        : (isHighlighted
                              ? const Color(0xFF10B981)
                              : (isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF1E293B))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
