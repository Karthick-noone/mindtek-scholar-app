import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../providers/complaint_provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'dart:async';
import '../../../../providers/scholar_provider.dart';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _complaintController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Timer? _debounce;
  bool _showSuccessToast = false;
  String _successMessage = '';

  bool _showRegisterModal = false;
  final bool _showReplyModal = false;
  bool _showRatingModal = false;
  final bool _showViewModal = false;
  bool _showDeleteConfirm = false;
  bool _showMinLengthError = false;
  bool _showMaxLengthError = false;
  bool _isSubmitting = false;
  bool _showRequiredError = false;

  Map<String, dynamic>? _selectedComplaint;
  int? _selectedComplaintId;
  String _selectedRating = '';

  @override
  void initState() {
    super.initState();
    _initializeComplaintPage();
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
    _debounce?.cancel();
    _complaintController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeComplaintPage() async {
    final provider = Provider.of<ComplaintProvider>(context, listen: false);
    await provider.fetchComplaints();
    await provider.fetchComplaintCounts();
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: isError ? 3 : 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitComplaint(String complaintText) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final scholarProvider = Provider.of<ScholarProvider>(
        context,
        listen: false,
      );
      String? regId = scholarProvider.regId;
      String? userId = scholarProvider.scholarId;

      if (regId == null || regId.isEmpty) {
        regId = await _storage.read(key: 'reg_id');
      }
      if (userId == null || userId.isEmpty) {
        userId = await _storage.read(key: 'user_id');
      }

      if (regId == null || regId.isEmpty) {
        _showErrorSnackBar(
          'Registration ID not found. Please logout and login again.',
        );
        setState(() => _isSubmitting = false);
        return;
      }

      final complaintData = {
        'complaint': complaintText,
        'reg_id': regId,
        'user_id': userId,
        'complt_reg_dt': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      };

      final provider = Provider.of<ComplaintProvider>(context, listen: false);
      final success = await provider.addComplaint(complaintData);

      if (mounted) {
        if (success) {
          _showMessage('Complaint submitted successfully!', isError: false);
          _complaintController.clear();
          setState(() {
            _showMinLengthError = false;
            _showMaxLengthError = false;
          });
        } else {
          _showErrorSnackBar(provider.error ?? 'Failed to submit complaint');
        }
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deleteComplaint() async {
    if (_selectedComplaintId == null) return;
    final provider = Provider.of<ComplaintProvider>(context, listen: false);
    final success = await provider.removeComplaint(_selectedComplaintId!);
    if (success) {
      _showMessage('Complaint deleted successfully!', isError: false);
      setState(() {
        _showDeleteConfirm = false;
        _selectedComplaintId = null;
      });
    }
  }

  Future<void> _updateRating() async {
    if (_selectedComplaint == null || _selectedRating.isEmpty) return;
    final ratingMap = {
      'excellent': 5,
      'great': 4,
      'good': 3,
      'average': 2,
      'bad': 1,
    };
    final provider = Provider.of<ComplaintProvider>(context, listen: false);
    final success = await provider.rateComplaint(
      _selectedComplaint!['id'],
      ratingMap[_selectedRating] ?? 0,
    );
    if (success) {
      _showMessage('Thank you for rating!', isError: false);
      setState(() {
        _showRatingModal = false;
        _selectedRating = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<ComplaintProvider>(context);

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0A0E27)
          : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Premium Gradient Background (底部)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDarkMode
                    ? [const Color(0xFF1A1D3E), const Color(0xFF0A0E27)]
                    : [const Color(0xFF1116F4), const Color(0xFF3B82F6)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildPremiumAppBar(isDarkMode),
                  const SizedBox(height: 16),
                  _buildPremiumStats(provider, isDarkMode),
                ],
              ),
            ),
          ),

          Positioned(
            top: 0,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // Top Right - Medium Circle
          Positioned(
            top: 60,
            right: 60,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          // Top Left - Large Circle
          Positioned(
            top: 170,
            left: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Top Left - Small Circle
          Positioned(
            top: 190,
            left: 30,
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Top Center - Tiny Circle
          Positioned(
            top: 110,
            right: 100,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          ),

          // Main Content
          Positioned(
            top: MediaQuery.of(context).size.height * 0.28,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: RefreshIndicator(
                  onRefresh: () async {
                    await provider.fetchComplaints();
                    await provider.fetchComplaintCounts();
                  },
                  color: const Color(0xFF1116F4),
                  child: Column(
                    children: [
                      _buildSearchFilterBar(provider, isDarkMode),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _buildComplaintsList(provider, isDarkMode),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating Action Button
          Positioned(
            bottom: 20,
            right: 20,
            child: _buildFloatingActionButton(isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumAppBar(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          Container(
            // decoration: BoxDecoration(
            //   color: Colors.white.withOpacity(0.15),
            //   borderRadius: BorderRadius.circular(12),
            // ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Complaints',
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
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.headset_mic_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStats(ComplaintProvider provider, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildPremiumStatItem(
            'Total',
            provider.totalComplaints,
            Icons.description_rounded,
            const Color(0xFF1116F4),
            isDarkMode,
          ),
          const SizedBox(width: 12),
          _buildPremiumStatItem(
            'Pending',
            provider.pendingCount,
            Icons.pending_rounded,
            const Color(0xFFF59E0B),
            isDarkMode,
          ),
          const SizedBox(width: 12),
          _buildPremiumStatItem(
            'Progress',
            provider.inProgressCount,
            Icons.trending_up_rounded,
            const Color(0xFF8B5CF6),
            isDarkMode,
          ),
          const SizedBox(width: 12),
          _buildPremiumStatItem(
            'Resolved',
            provider.resolvedCount,
            Icons.check_circle_rounded,
            const Color(0xFF10B981),
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStatItem(
    String label,
    int value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchFilterBar(ComplaintProvider provider, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Field
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search complaints...',
                hintStyle: TextStyle(
                  color: isDarkMode
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF94A3B8),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF1116F4),
                  size: 20,
                ),
                suffixIcon: provider.searchTerm.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          provider.clearSearch();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(
                  const Duration(milliseconds: 500),
                  () => provider.setSearchTerm(value),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPremiumFilterChip(
                  'All',
                  provider.filterStatus == 'all',
                  () => provider.setFilterStatus('all'),
                  isDarkMode,
                ),
                _buildPremiumFilterChip(
                  'Pending',
                  provider.filterStatus == 'pending',
                  () => provider.setFilterStatus('pending'),
                  isDarkMode,
                ),
                _buildPremiumFilterChip(
                  'In Progress',
                  provider.filterStatus == 'in_progress',
                  () => provider.setFilterStatus('in_progress'),
                  isDarkMode,
                ),
                _buildPremiumFilterChip(
                  'Resolved',
                  provider.filterStatus == 'resolved',
                  () => provider.setFilterStatus('resolved'),
                  isDarkMode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF1116F4), Color(0xFF3B82F6)],
                )
              : null,
          color: isSelected
              ? null
              : (isDarkMode ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDarkMode
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDarkMode ? Colors.white70 : const Color(0xFF64748B)),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintsList(ComplaintProvider provider, bool isDarkMode) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.complaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 48,
                color: const Color(0xFF1116F4).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No complaints yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to register your complaint',
              style: TextStyle(
                color: isDarkMode
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: provider.complaints.length,
      itemBuilder: (context, index) {
        final complaint = provider.complaints[index];
        final startEntry = (provider.currentPage - 1) * provider.rowsPerPage;
        final slNo = startEntry + index + 1;
        return _buildPremiumComplaintCard(complaint, slNo, isDarkMode);
      },
    );
  }

  Widget _buildPremiumComplaintCard(
    Map<String, dynamic> complaint,
    int slNo,
    bool isDarkMode,
  ) {
    final status = complaint['status'] ?? 'Pending';
    final hasReply =
        complaint['reply_content'] != null &&
        complaint['reply_content'].toString().isNotEmpty;
    final rating = complaint['ratings'];
    final isResolved = status.toLowerCase() == 'resolved';

    Color getStatusColor() {
      switch (status.toLowerCase()) {
        case 'resolved':
          return const Color(0xFF10B981);
        case 'in progress':
          return const Color(0xFF8B5CF6);
        default:
          return const Color(0xFFF59E0B);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // onTap: () => _showViewModalDialog(complaint),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Ticket ID with icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D5BE3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Color(0xFF2D5BE3),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            complaint['ticket_id'] ?? 'N/A',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            _formatDate(complaint['complt_reg_dt']),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDarkMode
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor().withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: getStatusColor(),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: getStatusColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Complaint Content
                Text(
                  complaint['complaint'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode
                        ? Colors.white70
                        : const Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                // Action Buttons - Added View button
                Row(
                  children: [
                    // View Button - Always visible
                    _buildPremiumActionButton(
                      icon: Icons.remove_red_eye_rounded,
                      label: 'View',
                      color: const Color(0xFF6366F1),
                      onTap: () => _showViewModalDialog(complaint),
                    ),
                    // const SizedBox(width: 8),

                    // Reply Button (if has reply)
                    if (hasReply)
                      _buildPremiumActionButton(
                        icon: Icons.message_rounded,
                        label: 'Reply',
                        color: const Color(0xFF8B5CF6),
                        onTap: () => _showReplyModalDialog(complaint),
                      ),

                    // Rate Button (if resolved)
                    // Rate Button (if resolved)
                    if (isResolved)
                      _buildPremiumActionButton(
                        icon: Icons.star_rate_rounded,
                        label: rating != null && rating > 0 ? 'Update' : 'Rate',
                        color: rating != null && rating > 0
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF10B981),
                        onTap: () => _showRatingModalDialog(
                          complaint,
                          rating,
                        ), // Always allow tapping, pass existing rating
                      ),

                    // Delete Button (if no reply)
                    if (complaint['reply_content'] == null)
                      _buildPremiumActionButton(
                        icon: Icons.delete_outline_rounded,
                        label: 'Delete',
                        color: const Color(0xFFEF4444),
                        onTap: () {
                          _selectedComplaintId = complaint['id'];
                          _showDeleteConfirmDialog();
                        },
                      ),
                  ],
                ),

                // Rating Badge
                if (rating != null && rating > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _buildRatingBadge(rating, isDarkMode),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBadge(int rating, bool isDarkMode) {
    Map<String, dynamic> config;
    switch (rating) {
      case 5:
        config = {
          'label': 'Excellent',
          'icon': Icons.emoji_events,
          'color': const Color(0xFFF59E0B),
        };
        break;
      case 4:
        config = {
          'label': 'Great',
          'icon': Icons.star,
          'color': const Color(0xFF1116F4),
        };
        break;
      case 3:
        config = {
          'label': 'Good',
          'icon': Icons.thumb_up,
          'color': const Color(0xFF10B981),
        };
        break;
      case 2:
        config = {
          'label': 'Average',
          'icon': Icons.sentiment_neutral,
          'color': const Color(0xFF94A3B8),
        };
        break;
      default:
        config = {
          'label': 'Bad',
          'icon': Icons.thumb_down,
          'color': const Color(0xFFEF4444),
        };
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (config['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config['icon'], size: 12, color: config['color']),
          const SizedBox(width: 4),
          Text(
            config['label'],
            style: TextStyle(
              fontSize: 10,
              color: config['color'],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(bool isDarkMode) {
    return GestureDetector(
      onTap: () => _showRegisterComplaintDialog(),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1116F4), Color(0xFF3B82F6)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1116F4).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  String _formatDate(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final date = DateTime.parse(dateTime);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateTime;
    }
  }

  void _showRegisterComplaintDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    _complaintController.clear();
    _showMinLengthError = false;
    _showMaxLengthError = false;
    _showRequiredError = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            builder: (context, double scale, child) {
              return Transform.scale(
                scale: 0.9 + (scale * 0.1),
                child: Opacity(
                  opacity: scale,
                  child: Material(
                    color: Colors.transparent,
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        // maxWidth: 500,
                        constraints: const BoxConstraints(maxHeight: 650),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Premium Header
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF2D5BE3),
                                    Color(0xFF4F46E5),
                                  ],
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  topRight: Radius.circular(32),
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
                                      Icons.edit_note_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Text(
                                      'Submit a Complaint',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(dialogContext),
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
                            Flexible(
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Description Label
                                      const Text(
                                        'Complaint Details',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Info Card
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? const Color(0xFF0F172A)
                                              : const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: isDarkMode
                                                ? Colors.grey[800]!
                                                : Colors.grey[200]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline_rounded,
                                              size: 16,
                                              color: const Color(0xFF2D5BE3),
                                            ),
                                            const SizedBox(width: 8),
                                            const Expanded(
                                              child: Text(
                                                'Please provide detailed information to help us resolve your issue quickly.',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Text Field
                                      TextField(
                                        controller: _complaintController,
                                        maxLines: 6,
                                        maxLength: 500,
                                        style: TextStyle(
                                          fontSize: 14,
                                          height: 1.5,
                                          color: isDarkMode
                                              ? Colors.white
                                              : const Color(0xFF1E293B),
                                        ),
                                        decoration: InputDecoration(
                                          hintText:
                                              'Describe your issue in detail...',
                                          hintStyle: TextStyle(
                                            color: isDarkMode
                                                ? Colors.grey[500]
                                                : Colors.grey[400],
                                            fontSize: 13,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              color: isDarkMode
                                                  ? Colors.grey[700]!
                                                  : Colors.grey[300]!,
                                              width: 1,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              color: isDarkMode
                                                  ? Colors.grey[700]!
                                                  : Colors.grey[300]!,
                                              width: 1,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF2D5BE3),
                                              width: 2,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.red[400]!,
                                              width: 2,
                                            ),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                borderSide: BorderSide(
                                                  color: Colors.red[400]!,
                                                  width: 2,
                                                ),
                                              ),
                                          counterText: "",
                                          fillColor: isDarkMode
                                              ? const Color(0xFF0F172A)
                                              : const Color(0xFFF8FAFC),
                                          filled: true,
                                        ),
                                        onChanged: (value) {
                                          setDialogState(() {
                                            if (_showRequiredError &&
                                                value.isNotEmpty)
                                              _showRequiredError = false;
                                            if (_showMinLengthError &&
                                                value.length >= 20)
                                              _showMinLengthError = false;
                                            if (_showMaxLengthError &&
                                                value.length <= 500)
                                              _showMaxLengthError = false;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 12),

                                      // Validation Status Cards
                                      if (_showRequiredError)
                                        _buildValidationCard(
                                          message:
                                              'Complaint description is required',
                                          type: 'error',
                                          isDarkMode: isDarkMode,
                                        ),

                                      if (_complaintController.text.length <
                                              20 &&
                                          _complaintController
                                              .text
                                              .isNotEmpty &&
                                          !_showRequiredError)
                                        _buildValidationCard(
                                          message:
                                              'Minimum 20 characters required (${_complaintController.text.length}/20)',
                                          type: 'warning',
                                          isDarkMode: isDarkMode,
                                        ),

                                      if (_showMaxLengthError)
                                        _buildValidationCard(
                                          message:
                                              'Maximum 500 characters exceeded',
                                          type: 'error',
                                          isDarkMode: isDarkMode,
                                        ),

                                      // const SizedBox(height: 16),

                                      // Character counter - Only count
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          '${_complaintController.text.length}/500',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                _complaintController
                                                        .text
                                                        .length >
                                                    500
                                                ? Colors.red[400]
                                                : _complaintController
                                                              .text
                                                              .length >=
                                                          20 &&
                                                      _complaintController
                                                          .text
                                                          .isNotEmpty
                                                ? const Color(0xFF10B981)
                                                : isDarkMode
                                                ? Colors.grey[400]
                                                : Colors.grey[500],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Action Buttons
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                16,
                                24,
                                24,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: isDarkMode
                                        ? Colors.grey[800]!
                                        : Colors.grey[100]!,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                        side: BorderSide(
                                          color: isDarkMode
                                              ? Colors.grey[700]!
                                              : Colors.grey[300]!,
                                          width: 1,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final text = _complaintController.text
                                            .trim();

                                        if (text.isEmpty) {
                                          setDialogState(
                                            () => _showRequiredError = true,
                                          );
                                          return;
                                        }

                                        if (text.length < 20) {
                                          setDialogState(
                                            () => _showMinLengthError = true,
                                          );
                                          return;
                                        }

                                        if (text.length > 500) {
                                          setDialogState(
                                            () => _showMaxLengthError = true,
                                          );
                                          return;
                                        }

                                        Navigator.pop(dialogContext);
                                        await _submitComplaint(text);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF2D5BE3,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: _isSubmitting
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Submit',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildValidationCard({
    required String message,
    required String type,
    required bool isDarkMode,
  }) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case 'error':
        bgColor = const Color(0xFFEF4444);
        textColor = const Color(0xFFEF4444);
        icon = Icons.error_outline_rounded;
        break;
      case 'warning':
        bgColor = const Color(0xFFF59E0B);
        textColor = const Color(0xFFF59E0B);
        icon = Icons.warning_amber_rounded;
        break;
      case 'success':
        bgColor = const Color(0xFF10B981);
        textColor = const Color(0xFF10B981);
        icon = Icons.check_circle_outline_rounded;
        break;
      default:
        bgColor = const Color(0xFF2D5BE3);
        textColor = const Color(0xFF2D5BE3);
        icon = Icons.info_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bgColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReplyModalDialog(Map<String, dynamic> complaint) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag indicator
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Response from Support',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Your Complaint Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.assignment_rounded,
                          size: 16,
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Your Complaint',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? Colors.grey[300]
                                : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      complaint['complaint'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: isDarkMode
                              ? Colors.grey[500]
                              : Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Registered: ${_formatDate(complaint['complt_reg_dt'])}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDarkMode
                                ? Colors.grey[500]
                                : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Reply Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF10B981).withOpacity(0.15),
                      const Color(0xFF10B981).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.reply_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Support Reply',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      complaint['reply_content']?.toString().isNotEmpty == true
                          ? complaint['reply_content']
                          : 'No response yet',
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: const Color(0xFF10B981).withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Replied: ${_formatDate(complaint['reply_dt'])}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Close Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D5BE3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingModalDialog(
    Map<String, dynamic> complaint, [
    int? existingRating,
  ]) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String localRating = '';

    // If there's an existing rating, set it as the initial selected value
    if (existingRating != null && existingRating > 0) {
      switch (existingRating) {
        case 5:
          localRating = 'excellent';
          break;
        case 4:
          localRating = 'great';
          break;
        case 3:
          localRating = 'good';
          break;
        case 2:
          localRating = 'average';
          break;
        case 1:
          localRating = 'bad';
          break;
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag indicator
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Header with icon
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.star_rate_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          existingRating != null && existingRating > 0
                              ? 'Update Rating'
                              : 'Rate Our Response',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    existingRating != null && existingRating > 0
                        ? 'Update your rating for this support response'
                        : 'How would you rate the support response?',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Rating Options Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildPremiumRatingOption(
                        'Excellent',
                        Icons.emoji_events,
                        const Color(0xFFF59E0B),
                        localRating,
                        (val) => setStateDialog(() => localRating = val),
                        isDarkMode,
                      ),
                      _buildPremiumRatingOption(
                        'Great',
                        Icons.star,
                        const Color(0xFF2D5BE3),
                        localRating,
                        (val) => setStateDialog(() => localRating = val),
                        isDarkMode,
                      ),
                      _buildPremiumRatingOption(
                        'Good',
                        Icons.thumb_up,
                        const Color(0xFF10B981),
                        localRating,
                        (val) => setStateDialog(() => localRating = val),
                        isDarkMode,
                      ),
                      _buildPremiumRatingOption(
                        'Average',
                        Icons.sentiment_neutral,
                        const Color(0xFF94A3B8),
                        localRating,
                        (val) => setStateDialog(() => localRating = val),
                        isDarkMode,
                      ),
                      _buildPremiumRatingOption(
                        'Bad',
                        Icons.thumb_down,
                        const Color(0xFFEF4444),
                        localRating,
                        (val) => setStateDialog(() => localRating = val),
                        isDarkMode,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            side: BorderSide(
                              color: isDarkMode
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: localRating.isNotEmpty
                              ? () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _selectedComplaint = complaint;
                                    _selectedRating = localRating.toLowerCase();
                                  });
                                  _updateRating();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D5BE3),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                            disabledBackgroundColor: const Color(
                              0xFF2D5BE3,
                            ).withOpacity(0.5),
                          ),
                          child: Text(
                            existingRating != null && existingRating > 0
                                ? 'Update'
                                : 'Submit',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
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
  }

  Widget _buildPremiumRatingOption(
    String label,
    IconData icon,
    Color color,
    String selectedRating,
    Function(String) onSelect,
    bool isDarkMode,
  ) {
    final isSelected = selectedRating == label.toLowerCase();

    return GestureDetector(
      onTap: () => onSelect(label.toLowerCase()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : (isDarkMode
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color
                : (isDarkMode ? Colors.grey[800]! : Colors.grey[200]!),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.white : color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDarkMode ? Colors.white70 : Colors.grey[700]),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check, size: 14, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }

  void _showViewModalDialog(Map<String, dynamic> complaint) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final hasReply =
        complaint['reply_content'] != null &&
        complaint['reply_content'].toString().isNotEmpty;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag indicator
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2D5BE3), Color(0xFF4F46E5)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.assignment_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Complaint Details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Ticket Info Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Ticket ID
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ticket ID',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              complaint['ticket_id'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Registered On',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(complaint['complt_reg_dt']),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? Colors.white70
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Complaint Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF2D5BE3).withOpacity(0.08),
                        const Color(0xFF2D5BE3).withOpacity(0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF2D5BE3).withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D5BE3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.description_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Complaint Description',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        complaint['complaint'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDarkMode
                              ? Colors.white70
                              : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Reply Section (if exists)
              if (hasReply) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF10B981).withOpacity(0.12),
                          const Color(0xFF10B981).withOpacity(0.04),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.reply_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Support Reply',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          complaint['reply_content'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: isDarkMode
                                ? Colors.white70
                                : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: const Color(0xFF10B981).withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Replied on: ${_formatDate(complaint['reply_dt'])}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Close Button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5BE3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Complaint'),
        content: const Text('Are you sure you want to delete this complaint?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteComplaint();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
