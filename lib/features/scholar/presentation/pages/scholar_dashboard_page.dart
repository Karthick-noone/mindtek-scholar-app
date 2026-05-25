import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'payment_history_page.dart';
import 'profile_page.dart';
import 'complaint_page.dart';
import 'change_password_page.dart';
import 'package:mindtek_scholar_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:mindtek_scholar_app/providers/payment_provider.dart';
import 'package:mindtek_scholar_app/providers/complaint_provider.dart';
import 'package:mindtek_scholar_app/providers/scholar_provider.dart';
import 'package:mindtek_scholar_app/providers/work_progress_provider.dart';
import 'package:mindtek_scholar_app/core/network/api_client.dart';
import 'full_image_view.dart';

// Light Mode Colors
const _kNavy = Color(0xFF1A2B4A);
const _kBlue = Color(0xFF2D5BE3);
const _klightBlue = Color(0xFF1116F4);
const _kBlueSoft = Color(0xFFEEF2FF);
const _kBg = Color(0xFFF4F6FB);
const _kCard = Colors.white;
const _kBorder = Color(0xFFE4E9F2);
const _kHint = Color(0xFF9AA5BE);
const _kRed = Color(0xFFE53E3E);
const _kGreen = Color(0xFF38A169);
const _kAmber = Color(0xFFD97706);

// Dark Mode Colors
const _kDarkBg = Color(0xFF0F172A);
const _kDarkCard = Color(0xFF1E293B);
const _kDarkBorder = Color(0xFF334155);
const _kDarkHint = Color(0xFF94A3B8);
const _kDarkNavy = Color(0xFFE2E8F0);
const _kDarkBlueSoft = Color(0xFF1E3A5F);

class DashboardPage extends StatefulWidget {
  final String userId;
  const DashboardPage({super.key, required this.userId});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  final ApiClient _apiClient = ApiClient();
  bool _isCheckingStatus = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        context.read<ScholarProvider>().fetchScholar(),
        context.read<PaymentProvider>().fetchPayments(),
        context.read<ComplaintProvider>().fetchComplaints(),
        context.read<ComplaintProvider>().fetchComplaintCounts(),
        context.read<WorkProgressProvider>().fetchWorkProgress(),
      ]);
      await _checkScholarStatus();
    } catch (e) {
      debugPrint('Dashboard load error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  double _getTotalPaid() {
    final p = context.read<PaymentProvider>();
    return p.payments.isNotEmpty ? _toDouble(p.payments.first['tot_paid']) : 0;
  }

  double _getBalance() {
    final p = context.read<PaymentProvider>();
    return p.payments.isNotEmpty ? _toDouble(p.payments.first['bal_amt']) : 0;
  }

  String _fmt(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      return DateFormat(
        'dd MMM yy',
      ).format(DateTime.parse(raw.split(' ')[0].split('T')[0]));
    } catch (_) {
      return raw;
    }
  }

  String _lastComplaintDate() {
    final c = context.read<ComplaintProvider>();
    return c.complaints.isNotEmpty
        ? _fmt(c.complaints.first['complt_reg_dt']?.toString())
        : '';
  }

  String _lastPaymentDate() {
    final p = context.read<PaymentProvider>();
    if (p.payments.isNotEmpty) {
      return _fmt(
        p.payments.first['pay_dt_tm']?.toString() ??
            p.payments.first['created_at']?.toString(),
      );
    }
    return '';
  }

  String _timeOfDay() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }

  Future<void> _checkScholarStatus() async {
    if (_isCheckingStatus) return;
    setState(() => _isCheckingStatus = true);
    try {
      final sp = context.read<ScholarProvider>();
      final id =
          await sp.storage.read(key: 'id') ??
          await sp.storage.read(key: 'user_id') ??
          sp.regId;
      if (id.isEmpty) return;
      final resp = await _apiClient.get('/user/details/$id');
      final data = resp.data;
      final status = (data is Map)
          ? ((data['data'] ?? data['user'] ?? data)?['scholar_status']
                    ?.toString() ??
                data['scholar_status']?.toString())
          : null;
      if (status?.toLowerCase() != 'active' && mounted)
        _showDeactivationDialog();
    } catch (e) {
      debugPrint('Status check: $e');
    } finally {
      if (mounted) setState(() => _isCheckingStatus = false);
    }
  }

  Future<void> _performLogout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _showDeactivationDialog() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDarkMode ? _kDarkCard : Colors.white,
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFFFFF1F1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            color: _kRed,
            size: 36,
          ),
        ),
        title: Text(
          'Account Deactivated',
          textAlign: TextAlign.center,
          style: TextStyle(color: isDarkMode ? Colors.white : _kNavy),
        ),
        content: Text(
          'Your account has been deactivated. Please contact support.',
          textAlign: TextAlign.center,
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await _performLogout();
              },
              style: FilledButton.styleFrom(backgroundColor: _kRed),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDarkMode ? _kDarkCard : Colors.white,
        title: Text(
          'Log out',
          style: TextStyle(color: isDarkMode ? Colors.white : _kNavy),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            style: TextButton.styleFrom(foregroundColor: _kRed),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDarkMode ? _kDarkCard : Colors.white,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline_rounded, color: _kBlue),
                title: const Text(
                  'Change Password',
                  style: TextStyle(color: _kNavy),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordPage(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: _kRed),
                title: const Text('Log out', style: TextStyle(color: _kRed)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _showLogoutDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNavTap(int i) {
    setState(() => _selectedIndex = i);
    final pages = <Widget?>[
      null,
      ProfilePage(),
      PaymentHistoryPage(),
      ComplaintPage(),
    ];
    final page = pages[i];
    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      // ).then((_) => _loadDashboardData());
    }
  }
  // ── Drop-in replacement for the build() method body inside DashboardPage ──
  // Only the Expanded content area shows the loader.
  // Header and _FixedBottomNav are always rendered.

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    final sp = context.watch<ScholarProvider>();
    final pp = context.watch<PaymentProvider>();
    final cp = context.watch<ComplaintProvider>();
    final wp = context.watch<WorkProgressProvider>();

    final name = sp.name.isNotEmpty ? sp.name : widget.userId;
    final scholarId = sp.scholarId.isNotEmpty ? sp.scholarId : widget.userId;
    final photoUrl = sp.scholarProfileImage;
    final logoUrl = sp.companyLogo;
    final fmt = NumberFormat('#,##0');
    final balance = _getBalance();
    final totalPaid = _getTotalPaid();

    return Scaffold(
      backgroundColor: isDarkMode ? _kDarkBg : _kBg,
      body: Stack(
        children: [
          Column(
            children: [
              // ── Header — always visible ──────────────────────────────
              _Header(
                name: name,
                scholarId: scholarId,
                photoUrl: photoUrl,
                logoUrl: logoUrl,
                timeOfDay: _timeOfDay(),
                onAvatarTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return FullImageView(
                          imageUrl: photoUrl.isNotEmpty ? photoUrl : null,
                          // heroTag: 'profile_image',
                        );
                      },
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOutCubic;
                            var tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              ),
                            );
                          },
                    ),
                  );
                },
                isDarkMode: isDarkMode,
              ),

              // ── Content area — loader lives here only ────────────────
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: _klightBlue),
                      )
                    : RefreshIndicator(
                        color: _klightBlue,
                        onRefresh: _loadDashboardData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: MediaQuery.of(context).padding.bottom + 100,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _WelcomeBanner(isDarkMode: isDarkMode),
                              const SizedBox(height: 24),

                              _SectionHeader(
                                title: 'Overview',
                                onViewAll: () {},
                                isDarkMode: isDarkMode,
                              ),

                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                childAspectRatio: 1.1,
                                children: [
                                  _ModernStatCard(
                                    icon: Icons.hourglass_top_rounded,
                                    iconColor: _kAmber,
                                    iconBg: const Color(0xFFFFFBEB),
                                    label: 'Pending Complaints',
                                    value: cp.pendingCount.toString(),
                                    subtitle: 'Awaiting action',
                                    date: _lastComplaintDate(),
                                    gradient: const LinearGradient(
                                       colors: [
                                        Color(0xFFF59E0B),
                                        Color(0xFFD97706),
                                      ],
                                    ),
                                  ),
                                  _ModernStatCard(
                                    icon: Icons.check_circle_outline_rounded,
                                    iconColor: _kGreen,
                                    iconBg: const Color(0xFFF0FDF4),
                                    label: 'Resolved Complaints',
                                    value: cp.resolvedCount.toString(),
                                    subtitle: 'Completed',
                                    date: _lastComplaintDate(),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF10B981),
                                        Color(0xFF059669),
                                      ],
                                    ),
                                  ),
                                  _ModernStatCard(
                                    icon: Icons.credit_card_rounded,
                                    iconColor: _kRed,
                                    iconBg: const Color(0xFFFFF1F1),
                                    label: 'Balance Payment',
                                    value: '₹${fmt.format(balance)}',
                                    subtitle: 'Amount due',
                                    date: _lastPaymentDate(),
                                    gradient: const LinearGradient(
                                 
                                       colors: [
                                        Color(0xFFEF4444),
                                        Color(0xFFDC2626),
                                      ],
                                    ),
                                  ),
                                  _ModernStatCard(
                                    icon: Icons.account_balance_wallet_rounded,
                                    iconColor: _kBlue,
                                    iconBg: _kBlueSoft,
                                    label: 'Total Paid',
                                    value: '₹${fmt.format(totalPaid)}',
                                    subtitle: 'Lifetime',
                                    date: _lastPaymentDate(),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF6366F1),
                                        Color(0xFF4F46E5),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              if (wp.workProgress != null) ...[
                                const SizedBox(height: 24),
                                _SectionHeader(
                                  title: 'Research Progress',
                                  onViewAll: () {},
                                  isDarkMode: isDarkMode,
                                ),
                                const SizedBox(height: 12),
                                _ProgressCard(wp: wp, isDarkMode: isDarkMode),
                              ],

                              const SizedBox(height: 24),
                              _SectionHeader(
                                title: 'Recent Activity',
                                onViewAll: () {},
                                isDarkMode: isDarkMode,
                              ),
                              const SizedBox(height: 12),
                              _ActivityCard(
                                complaintText: cp.complaints.isNotEmpty
                                    ? cp.complaints.first['complaint'] ??
                                          'No complaints'
                                    : 'No complaints',
                                complaintDate: _lastComplaintDate(),
                                paymentText: pp.payments.isNotEmpty
                                    ? '₹${fmt.format(_toDouble(pp.payments.first['pay_received']))}'
                                    : 'No payments',
                                paymentDate: _lastPaymentDate(),
                                isDarkMode: isDarkMode,
                              ),

                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),

          // ── Bottom nav — always visible ──────────────────────────────
          _FixedBottomNav(
            selectedIndex: _selectedIndex,
            onTap: _onNavTap,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }
}

class _FixedBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool isDarkMode;

  const _FixedBottomNav({
    required this.selectedIndex,
    required this.onTap,
    required this.isDarkMode,
  });

  static const _items = [
    {'icon': Icons.home_rounded, 'label': 'Home'},
    {'icon': Icons.person_rounded, 'label': 'Profile'},
    {'icon': Icons.currency_rupee, 'label': 'Payment'},
    {'icon': Icons.support_agent_rounded, 'label': 'Complaints'},
    {'icon': Icons.lock_outline_rounded, 'label': 'Security'},
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: bottomPadding + 10,
      left: 16,
      right: 16,
      child: Container(
        height: 74,
        decoration: BoxDecoration(
          color: isDarkMode ? _kDarkCard : Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: _kBlue.withOpacity(isDarkMode ? 0.15 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(_items.length, (i) {
            final item = _items[i];
            final icon = item['icon'] as IconData;
            final label = item['label'] as String;
            // Only Home (index 0) is always active, others are never active
            final isActive = i == 0;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  if (i == 0) {
                    // Home - already active, just refresh if needed
                    // You can add refresh logic here
                  } else if (i == 4) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordPage(),
                      ),
                    );
                  } else {
                    onTap(i);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: isActive
                            ? LinearGradient(
                                colors: [_klightBlue, _kBlue.withOpacity(0.8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: _klightBlue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: isActive
                            ? Colors.white
                            : (isDarkMode ? _kDarkHint : _kHint),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isActive
                            ? _klightBlue
                            : (isDarkMode ? _kDarkHint : _kHint),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HEADER — With Dark Mode Support
// ═══════════════════════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  final String name, scholarId, photoUrl, logoUrl, timeOfDay;
  final VoidCallback onAvatarTap;
  final bool isDarkMode;

  const _Header({
    required this.name,
    required this.scholarId,
    required this.photoUrl,
    required this.logoUrl,
    required this.timeOfDay,
    required this.onAvatarTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? _kDarkCard : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Logo - Original colors in light mode, white in dark mode
                logoUrl.isNotEmpty
                    ? isDarkMode
                          ? ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                              child: Image.network(
                                logoUrl,
                                height: 32,
                                fit: BoxFit.contain,
                              ),
                            )
                          : Image.network(
                              logoUrl,
                              height: 32,
                              fit: BoxFit.contain,
                            )
                    : Row(
                        children: [
                          Icon(Icons.school_rounded, color: _kBlue, size: 26),
                          const SizedBox(width: 6),
                          Text(
                            'MindTek',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode ? Colors.white : _kNavy,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      _greetIcon(timeOfDay),
                      color: isDarkMode ? _kDarkHint : _kHint,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Good $timeOfDay,',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode ? _kDarkHint : _kHint,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  name.split(' ').first,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : _kNavy,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Container(
                    //   width: 7,
                    //   height: 7,
                    //   decoration: const BoxDecoration(
                    //     color: _kGreen,
                    //     shape: BoxShape.circle,
                    //   ),
                    // ),
                    Icon(Icons.school_rounded, color: _kBlue, size: 20),
                    const SizedBox(width: 5),
                    Text(
                      ' $scholarId',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDarkMode ? Colors.white70 : _kNavy,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode ? _kDarkBlueSoft : _kBlueSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: _kGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 10,
                              color: _kBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [_kBlue, _kBlue.withOpacity(0.5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _kBlue.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2),
              child: ClipOval(
                child: photoUrl.isNotEmpty
                    ? CachedNetworkImage(imageUrl: photoUrl, fit: BoxFit.cover)
                    : Container(
                        color: isDarkMode ? _kDarkBlueSoft : _kBlueSoft,
                        child: const Icon(
                          Icons.person_rounded,
                          color: _kBlue,
                          size: 28,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _greetIcon(String tod) {
    if (tod == 'Morning') return Icons.wb_sunny_rounded;
    if (tod == 'Afternoon') return Icons.wb_cloudy_rounded;
    return Icons.nights_stay_rounded;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MODERN STAT CARD - With Particles, Stars & Dots
// ═══════════════════════════════════════════════════════════════════════════

class _ModernStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg;
  final String label, value, subtitle, date;
  final Gradient gradient;

  const _ModernStatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.date,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final circleOpacity = isDarkMode ? 0.08 : 0.12;
    final starOpacity = isDarkMode ? 0.15 : 0.2;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(isDarkMode ? 0.15 : 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Circle 1 - Top Right (Large)
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(circleOpacity),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Circle 2 - Bottom Left (Medium)
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(circleOpacity),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Circle 3 - Bottom Right (Small)
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(circleOpacity * 0.7),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // ⭐ STAR 1 - Top Left (4-point star)
            Positioned(
              top: 8,
              left: 12,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(starOpacity),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // ⭐ STAR 2 - Near top center
            Positioned(
              top: 25,
              left: 45,
              child: Transform.rotate(
                angle: 0.5,
                child: Icon(
                  Icons.star,
                  size: 6,
                  color: Colors.white.withOpacity(starOpacity),
                ),
              ),
            ),

            // ⭐ STAR 3 - Middle right
            Positioned(
              top: 50,
              right: 15,
              child: Transform.rotate(
                angle: 0.3,
                child: Icon(
                  Icons.star,
                  size: 5,
                  color: Colors.white.withOpacity(starOpacity),
                ),
              ),
            ),

            // ⭐ STAR 4 - Bottom area
            Positioned(
              bottom: 45,
              left: 20,
              child: Transform.rotate(
                angle: 0.7,
                child: Icon(
                  Icons.star,
                  size: 4,
                  color: Colors.white.withOpacity(starOpacity * 0.8),
                ),
              ),
            ),

            // ✨ SPARKLE 1
            Positioned(
              top: 15,
              right: 50,
              child: Icon(
                Icons.auto_awesome,
                size: 5,
                color: Colors.white.withOpacity(starOpacity * 0.7),
              ),
            ),

            // ✨ SPARKLE 2
            Positioned(
              bottom: 20,
              right: 45,
              child: Icon(
                Icons.auto_awesome,
                size: 4,
                color: Colors.white.withOpacity(starOpacity * 0.6),
              ),
            ),

            // • Small Dots scattered
            // Dot 1
            Positioned(
              top: 12,
              right: 70,
              child: Container(
                width: 2,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(starOpacity * 0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Dot 2
            Positioned(
              top: 55,
              left: 55,
              child: Container(
                width: 2,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(starOpacity * 0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Dot 3
            Positioned(
              bottom: 30,
              right: 70,
              child: Container(
                width: 2,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(starOpacity * 0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Dot 4
            Positioned(
              bottom: 55,
              left: 45,
              child: Container(
                width: 1.5,
                height: 1.5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(starOpacity * 0.4),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Dot 5
            Positioned(
              top: 42,
              left: 70,
              child: Container(
                width: 1.5,
                height: 1.5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(starOpacity * 0.4),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Dot 6
            Positioned(
              top: 75,
              right: 55,
              child: Container(
                width: 2,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(starOpacity * 0.45),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Dot 7
            Positioned(
              bottom: 65,
              right: 25,
              child: Container(
                width: 1.5,
                height: 1.5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(starOpacity * 0.35),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Tiny sparkle dots cluster
            Positioned(
              top: 35,
              right: 35,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 1.5,
                    height: 1.5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Container(
                    width: 1,
                    height: 1,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 15,
              left: 35,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 1,
                    height: 1,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Container(
                    width: 1.5,
                    height: 1.5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Container(
                    width: 1,
                    height: 1,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(
                            isDarkMode ? 0.2 : 0.2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: Colors.white, size: 18),
                      ),
                      if (date.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                              isDarkMode ? 0.15 : 0.15,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 8,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                date,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ═══════════════════════════════════════════════════════════════════════════
// WELCOME BANNER - With Dark Mode Support
// ═══════════════════════════════════════════════════════════════════════════

class _WelcomeBanner extends StatelessWidget {
  final bool isDarkMode;
  const _WelcomeBanner({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? _kDarkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF2D5BE3).withOpacity(isDarkMode ? 0.1 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF2D5BE3).withOpacity(isDarkMode ? 0.2 : 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1116F4), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2D5BE3).withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.business_center,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Company',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D5BE3),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'MindTek Research and IT Solutions (P) Ltd.,',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A2B4A),
                    height: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION HEADER - With Dark Mode Support
// ═══════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  final bool isDarkMode;
  const _SectionHeader({
    required this.title,
    this.onViewAll,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: _kBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : _kNavy,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROGRESS CARD - With Dark Mode Support
// ═══════════════════════════════════════════════════════════════════════════

class _ProgressCard extends StatelessWidget {
  final WorkProgressProvider wp;
  final bool isDarkMode;
  const _ProgressCard({required this.wp, required this.isDarkMode});

  String _fmt(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      return DateFormat(
        'dd MMM yy',
      ).format(DateTime.parse(raw.split(' ')[0].split('T')[0]));
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = wp.progressPercentage;
    final note = wp.latestNote;
    final date = wp.lastUpdateDate;
    final formattedDate = _fmt(date);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDarkMode ? _kDarkCard : _kCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: _kBlue.withOpacity(isDarkMode ? 0.1 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: _kBlue.withOpacity(isDarkMode ? 0.2 : 0.12),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(100, 100),
                  painter: _RingPainter(
                    progress: pct / 100,
                    ringColor: _kBlue,
                    trackColor: isDarkMode ? _kDarkBlueSoft : _kBlueSoft,
                    strokeWidth: 10,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${pct.toInt()}%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _kBlue,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: _kBlue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    Text(
                      'complete',
                      style: TextStyle(
                        fontSize: 9,
                        color: isDarkMode ? _kDarkHint : _kHint,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _kBlue.withOpacity(0.1),
                            _kBlue.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _kBlue.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            size: 12,
                            color: _kBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            pct >= 80 ? 'Excellent Progress' : 'On Track',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _kBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _kBlue.withOpacity(isDarkMode ? 0.12 : 0.06),
                        _kBlue.withOpacity(isDarkMode ? 0.05 : 0.02),
                        (isDarkMode ? _kDarkCard : Colors.white).withOpacity(
                          0.5,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _kBlue.withOpacity(isDarkMode ? 0.25 : 0.15),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1116F4), Color(0xFF3B82F6)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              note.isNotEmpty
                                  ? Icons.note_alt_rounded
                                  : Icons.calendar_today_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            note.isNotEmpty ? 'Latest Update' : 'Last Activity',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode ? Colors.white : _kNavy,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      if (note.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.only(left: 4),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: _kBlue.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            note,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode
                                  ? Colors.white70
                                  : _kNavy.withOpacity(0.8),
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 12,
                              color: isDarkMode ? _kDarkHint : _kHint,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              date.isNotEmpty
                                  ? 'Last updated on $formattedDate'
                                  : 'No updates available yet',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDarkMode ? _kDarkHint : _kHint,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
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

// ═══════════════════════════════════════════════════════════════════════════
// RING PAINTER
// ═══════════════════════════════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════
// RING PAINTER — fixed track visibility in dark mode
// ═══════════════════════════════════════════════════════════════════════════
class _RingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color trackColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.ringColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // ── Track: full 360° arc (NOT drawCircle) so strokeCap & color render correctly ──
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, trackPaint);

    // ── Progress arc ──────────────────────────────────────────────────────────
    if (progress > 0) {
      final arcPaint = Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.ringColor != ringColor ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth;
}

// ═══════════════════════════════════════════════════════════════════════════
// DARK MODE COLOUR CONSTANTS to add alongside your existing ones
// ═══════════════════════════════════════════════════════════════════════════
// Replace _kDarkBlueSoft with a higher-contrast value:
// const _kDarkBlueSoft = Color(0xFF1E3A5F); // was too dark — now clearly visible on dark bg

// ═══════════════════════════════════════════════════════════════════════════
// _ProgressCard — only the CustomPaint call changes (trackColor fix)
// ═══════════════════════════════════════════════════════════════════════════
//
// In your _ProgressCard build(), change:
//
//   trackColor: isDarkMode ? _kDarkBlueSoft : _kBlueSoft,
//
// to:
//
//   trackColor: isDarkMode
//       ? _kBlue.withOpacity(0.25)   // ← explicit semi-transparent blue, always visible
//       : _kBlueSoft,
//
// Full corrected CustomPaint block:

/*
CustomPaint(
  size: const Size(100, 100),
  painter: _RingPainter(
    progress: pct / 100,
    ringColor: _kBlue,
    trackColor: isDarkMode
        ? _kBlue.withOpacity(0.25)   // visble track on dark bg
        : _kBlueSoft,
    strokeWidth: 10,
  ),
),
*/
// ═══════════════════════════════════════════════════════════════════════════
// ACTIVITY CARD - With Dark Mode Support
// ═══════════════════════════════════════════════════════════════════════════

class _ActivityCard extends StatelessWidget {
  final String complaintText, complaintDate, paymentText, paymentDate;
  final bool isDarkMode;
  const _ActivityCard({
    required this.complaintText,
    required this.complaintDate,
    required this.paymentText,
    required this.paymentDate,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? _kDarkCard : _kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _kBlue.withOpacity(isDarkMode ? 0.2 : 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _ActivityRow(
            icon: Icons.headset_mic_rounded,
            iconBg: const Color(0xFFFFF1F1),
            iconColor: _kRed,
            label: 'Last Complaint',
            value: complaintText,
            date: complaintDate,
            isDarkMode: isDarkMode,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              color: isDarkMode ? _kDarkBorder : _kBorder,
              height: 1,
              thickness: 0.5,
            ),
          ),
          _ActivityRow(
            icon: Icons.receipt_long_rounded,
            iconBg: const Color(0xFFF0FDF4),
            iconColor: _kGreen,
            label: 'Last Payment',
            value: paymentText,
            date: paymentDate,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String label, value, date;
  final bool isDarkMode;

  const _ActivityRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.date,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isDarkMode ? _kDarkHint : _kHint,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : _kNavy,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (date.isNotEmpty)
          Text(
            date,
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode ? _kDarkHint : _kHint,
            ),
          ),
      ],
    );
  }
}
