// lib/features/scholar/presentation/pages/profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'full_image_view.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/scholar_provider.dart';
import '../../../../providers/theme_provider.dart';
import 'package:mindtek_scholar_app/providers/work_progress_provider.dart';
import 'package:mindtek_scholar_app/features/auth/presentation/providers/auth_provider.dart';

// ─── Design tokens ─────────────────────────────────────────────────────────
const _kNavy = Color(0xFF0F1F3D);
const _kBlue = Color(0xFF2D5BE3);
const _kBlueMid = Color(0xFF4B7BF5);
const _kBlueSoft = Color(0xFFEEF2FF);
const _kBg = Color(0xFFF2F4F8);
const _kBorder = Color(0xFFE2E8F0);
const _kHint = Color(0xFF94A3B8);
const _kGreen = Color(0xFF22C55E);
const _kGreenSoft = Color(0xFFDCFCE7);
const _kAmber = Color(0xFFF59E0B);
const _kRed = Color(0xFFEF4444);
const _kRedSoft = Color(0xFFFEF2F2);

// Dark mode surfaces
const _kDarkBg = Color(0xFF0B1120);
const _kDarkCard = Color(0xFF151F32);
const _kDarkCard2 = Color(0xFF1C2A42);
const _kDarkBorder = Color(0xFF243147);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  File? _image;
  final picker = ImagePicker();
  bool _isUploading = false;
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _kExpandedHeight = 280.0;
  static const _kCollapsedThreshold = 200.0;

  @override
  void initState() {
    super.initState();
    _loadImage();
    _loadData();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final collapsed =
        _scrollController.hasClients &&
        _scrollController.offset > _kCollapsedThreshold;
    if (collapsed != _isCollapsed) setState(() => _isCollapsed = collapsed);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _loadData() async {
    final sp = context.read<ScholarProvider>();
    if (sp.scholar == null) await sp.fetchScholar();
    await context.read<WorkProgressProvider>().fetchWorkProgress();
  }

  Future<void> _loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString("profile_image");
    if (path != null && mounted) setState(() => _image = File(path));
  }

  //   Future<void> _performLogout() async {
  //   await context.read<AuthProvider>().logout();
  //   if (mounted) Navigator.pop(context);
  // }


  Future<void> _onRefresh() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("profile_image");
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      await context.read<ScholarProvider>().fetchScholar();
      if (mounted) _snack('Profile refreshed', false);
    } catch (e) {
      if (mounted) _snack('Failed to refresh', true);
    }
  }

  void _snack(String msg, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? _kRed : _kGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _uploadImage(ScholarProvider sp) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = File(picked.path);
    setState(() {
      _isUploading = true;
      _image = file;
    });
    final ok = await sp.uploadProfileImage(file);
    if (!mounted) return;
    setState(() => _isUploading = false);
    if (ok) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("profile_image");
      setState(() => _image = null);
      _snack('Photo updated!', false);
    } else {
      await _loadImage();
      setState(() {});
      _snack(sp.error ?? 'Upload failed', true);
    }
  }

  Future<void> _deleteImage(ScholarProvider sp) async {
    final ok2 = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Remove Photo'),
        content: const Text(
          'Are you sure you want to remove your profile photo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: _kRed),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok2 != true) return;
    setState(() => _isUploading = true);
    final ok = await sp.deleteProfileImage();
    if (!mounted) return;
    setState(() => _isUploading = false);
    if (ok) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("profile_image");
      setState(() => _image = null);
      _snack('Photo removed', false);
    } else {
      _snack(sp.error ?? 'Delete failed', true);
    }
  }


  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _kDarkBg : _kBg;

    return Scaffold(
      backgroundColor: bg,
      body: Consumer<ScholarProvider>(
        builder: (ctx, sp, _) {
          if (sp.isLoading && sp.scholar == null) {
            return const Center(
              child: CircularProgressIndicator(color: _kBlue),
            );
          }
          if (sp.error != null && sp.scholar == null) {
            return _ErrorView(error: sp.error!, onRetry: sp.fetchScholar);
          }
          if (sp.scholar == null) return const Center(child: Text('No data'));

          return FadeTransition(
            opacity: _fadeAnim,
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: _kBlue,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ── Hero SliverAppBar ──────────────────────────────────
               SliverAppBar(
  pinned: true,
  expandedHeight: _kExpandedHeight,
  backgroundColor: Colors.transparent,
  systemOverlayStyle: const SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.light,
  ),
  flexibleSpace: Stack(
    children: [
      // Gradient Background
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1A1D3E),
                      const Color(0xFF0A0E27),
                    ]
                  : [
                      const Color(0xFF1116F4),
                      const Color(0xFF3B82F6),
                    ],
            ),
          ),
        ),
      ),
      
      // Decorative Circles
      Positioned(
        top: -40,
        right: -40,
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(isDark ? 0.03 : 0.06),
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
            color: Colors.white.withOpacity(isDark ? 0.02 : 0.04),
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
            color: Colors.white.withOpacity(isDark ? 0.02 : 0.05),
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
            color: Colors.white.withOpacity(isDark ? 0.04 : 0.08),
          ),
        ),
      ),
      Positioned(
        top: 30,
        left: 20,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(isDark ? 0.05 : 0.1),
          ),
        ),
      ),
      
      // Original Hero Section
      FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _HeroSection(
          sp: sp,
          image: _image,
          isUploading: _isUploading,
          isDark: isDark,
          onUpload: () => _uploadImage(sp),
          onDelete: () => _deleteImage(sp),
          onPhotoTap: () {
            final url = sp.scholarProfileImage;
            if (_image != null || url.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullImageView(
                    imageFile: _image,
                    imageUrl: url,
                  ),
                ),
              );
            }
          },
        ),
      ),
    ],
  ),
  leading: _NavBtn(
    icon: Icons.arrow_back_ios_new_rounded,
    onTap: () => Navigator.pop(context),
  ),
  actions: [
    // Profile avatar appears in toolbar only when collapsed
    AnimatedOpacity(
      opacity: _isCollapsed ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Center(
          child: _MiniAvatar(
            image: _image,
            url: sp.scholarProfileImage,
            onTap: () {
              final url = sp.scholarProfileImage;
              if (_image != null || url.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullImageView(
                      imageFile: _image,
                      imageUrl: url,
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    ),
    Consumer<ThemeProvider>(
      builder: (_, tp, __) => _NavBtn(
        icon: tp.isDarkMode
            ? Icons.light_mode_rounded
            : Icons.dark_mode_rounded,
        onTap: tp.toggleTheme,
      ),
    ),
    const SizedBox(width: 8),
  ],
),
                  // ── Content ────────────────────────────────────────────
           SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Scholar badge row ────────────────────────
        _ScholarBadgeRow(sp: sp, isDark: isDark),
        const SizedBox(height: 24),

        // ── Personal Info — horizontal chip layout ───
        _SectionTitle(
          'Personal Information',
          Icons.person_rounded,
        ),
        const SizedBox(height: 12),
        _PersonalInfoBlock(sp: sp, isDark: isDark),
        const SizedBox(height: 24),

        // ── Secondary Emails — pill cards ────────────
        if (sp.hasSecondaryEmails) ...[
          _SectionTitle(
            'Secondary Emails',
            Icons.alternate_email_rounded,
          ),
          const SizedBox(height: 12),
          _SecondaryEmailsBlock(
            emails: sp.secondaryEmails,
            isDark: isDark,
          ),
          const SizedBox(height: 24),
        ],

        // ── Work Info — two-column icon grid ─────────
        _SectionTitle('Work Information', Icons.work_rounded),
        const SizedBox(height: 12),
        _WorkInfoBlock(sp: sp, isDark: isDark),
        const SizedBox(height: 24),

        // ── Work Description ─────────────────────────
        if (sp.workDesc.isNotEmpty) ...[
          _SectionTitle(
            'Work Description',
            Icons.notes_rounded,
          ),
          const SizedBox(height: 12),
          _WorkDescBlock(text: sp.workDesc, isDark: isDark),
          const SizedBox(height: 24),
        ],

        // ── Work Progress — straight bar style ───────
        _WorkProgressBlock(isDark: isDark),

        const SizedBox(height: 32),

        // ── Logout Button ────────────────────────────
        _LogoutButton(isDark: isDark),
      ],
    ),
  ),
),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
// ═══════════════════════════════════════════════════════════════════════════
// LOGOUT BUTTON
// ═══════════════════════════════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════
// LOGOUT BUTTON — fixed redirect (matches sidebar_page.dart behaviour)
// ═══════════════════════════════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════
// LOGOUT BUTTON — fixed redirect (matches sidebar_page.dart behaviour)
// ═══════════════════════════════════════════════════════════════════════════

class _LogoutButton extends StatelessWidget {
  final bool isDark;
  const _LogoutButton({required this.isDark});

  Future<void> _performLogout(BuildContext context) async {
    BuildContext? dialogContext;

    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        dialogContext = ctx;
        return const PopScope(
          canPop: false,
          child: Center(child: CircularProgressIndicator(color: _kBlue)),
        );
      },
    );

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // ── KEY FIX: call logout() THEN pop ALL routes back to root ──────────
      await authProvider.logout();

      // Dismiss the loading dialog first
      if (dialogContext != null && Navigator.canPop(dialogContext!)) {
        Navigator.pop(dialogContext!);
      }

      // Pop everything back to the first route (login screen)
      // This matches what the sidebar does via Navigator.pop(context) chain
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }

    } catch (e) {
      debugPrint('Logout error: $e');

      // Dismiss loading dialog on error
      if (dialogContext != null && Navigator.canPop(dialogContext!)) {
        Navigator.pop(dialogContext!);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: $e'),
            backgroundColor: _kRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogCtx) {
        return AlertDialog(
          backgroundColor: isDark ? _kDarkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Logout',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                'Cancel',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx);       // close confirmation dialog
                _performLogout(context);        // run logout with context of the page
              },
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.red.shade400 : _kRed,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutConfirmation(context),
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text(
          'Logout',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _kRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }
}// ═══════════════════════════════════════════════════════════════════════════
// NAV BUTTON
// ═══════════════════════════════════════════════════════════════════════════
class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => IconButton(
    icon: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Icon(icon, size: 16, color: Colors.white),
    ),
    onPressed: onTap,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// MINI AVATAR (collapsed toolbar)
// ═══════════════════════════════════════════════════════════════════════════
class _MiniAvatar extends StatelessWidget {
  final File? image;
  final String url;
    final VoidCallback onTap;

  const _MiniAvatar({required this.image, required this.url,   required this.onTap,});
  @override
  Widget build(BuildContext context) {
    Widget child;
    if (image != null) {
      child = Image.file(image!, fit: BoxFit.cover);
    } else if (url.isNotEmpty) {
      child = CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) =>
            const Icon(Icons.person, color: _kHint, size: 18),
      );
    } else {
      child = const Icon(Icons.person, color: _kHint, size: 18);
    }
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
      ),
      child: ClipOval(child: child),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HERO SECTION
// ═══════════════════════════════════════════════════════════════════════════
class _HeroSection extends StatelessWidget {
  final ScholarProvider sp;
  final File? image;
  final bool isUploading, isDark;
  final VoidCallback onUpload, onDelete, onPhotoTap;
  const _HeroSection({
    required this.sp,
    required this.image,
    required this.isUploading,
    required this.isDark,
    required this.onUpload,
    required this.onDelete,
    required this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    final url = sp.scholarProfileImage;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Cover gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F1F3D), Color(0xFF1A3B8C), Color(0xFF2D5BE3)],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),

        // Decorative circles
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
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
              color: Colors.white.withOpacity(0.04),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: -30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),

        // Cover photo layer (blended)
        if (image != null || url.isNotEmpty)
          Positioned.fill(
            child: Opacity(
              opacity: 0.18,
              child: image != null
                  ? Image.file(image!, fit: BoxFit.cover)
                  : CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const SizedBox(),
                    ),
            ),
          ),
// Bottom name card with avatar - Diagonal split
Positioned(
  bottom: -20,
  left: 0,
  right: -45,
  child: ClipPath(
    clipper: _DiagonalTopClipper(),
    child: Container(
      color: isDark ? _kDarkBg : _kBg,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add a spacer to push content below the avatar
          const SizedBox(height: 150), // This creates space for the avatar
          
          // Name
          Text(
            sp.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : _kNavy,
              letterSpacing: -0.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          // // Scholar ID
          // Row(
          //   children: [
          //     Icon(Icons.school_rounded, size: 13, color: _kHint),
          //     const SizedBox(width: 5),
          //     Text(
          //       sp.scholarId,
          //       style: const TextStyle(
          //         fontSize: 12,
          //         color: _kHint,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 8),
          
          // Active badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: _kGreenSoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kGreen.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: _kGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 11,
                    color: _kGreen,
                    fontWeight: FontWeight.w700,
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

// Avatar overlapping curve (position unchanged)
Positioned(
  bottom: 90,
  left: 20,
  child: _BigAvatar(
    image: image,
    url: url,
    isUploading: isUploading,
    onTap: onPhotoTap,
    onUpload: onUpload,
    onDelete: onDelete,
    hasPhoto: image != null || url.isNotEmpty,
  ),
),
   ],
    );
  }
}

class _BigAvatar extends StatelessWidget {
  final File? image;
  final String url;
  final bool isUploading, hasPhoto;
  final VoidCallback onTap, onUpload, onDelete;
  const _BigAvatar({
    required this.image,
    required this.url,
    required this.isUploading,
    required this.hasPhoto,
    required this.onTap,
    required this.onUpload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (image != null) {
      child = Image.file(image!, fit: BoxFit.cover);
    } else if (url.isNotEmpty) {
      child = CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => const Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: _kBlue),
        ),
        errorWidget: (_, __, ___) => _placeholder(),
      );
    } else {
      child = _placeholder();
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: _kBlue.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipOval(child: child),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: isUploading
                ? Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: _kBlue,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'upload')
                        onUpload();
                      else
                        onDelete();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: _kBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'upload',
                        child: Row(
                          children: [
                            Icon(Icons.upload_rounded, size: 18),
                            SizedBox(width: 10),
                            Text('Upload photo'),
                          ],
                        ),
                      ),
                      if (hasPhoto)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: _kRed,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Remove photo',
                                style: TextStyle(color: _kRed),
                              ),
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

  Widget _placeholder() => Container(
    color: _kBlueSoft,
    child: const Icon(Icons.person_rounded, size: 40, color: _kBlue),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// SCHOLAR BADGE ROW — joined date + company
// ═══════════════════════════════════════════════════════════════════════════
class _ScholarBadgeRow extends StatelessWidget {
  final ScholarProvider sp;
  final bool isDark;
  const _ScholarBadgeRow({required this.sp, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? _kDarkCard : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? _kDarkBorder : _kBorder, width: 0.5),
      ),
      child: Row(
        children: [
          _BadgeChip(
            icon: Icons.badge_rounded,
            color: _kBlue,
            bg: _kBlueSoft,
            label: sp.scholarId,
          ),
          const SizedBox(width: 10),
          if (sp.formattedRegDate.isNotEmpty)
            Expanded(
              child: _BadgeChip(
                icon: Icons.calendar_month_rounded,
                color: _kAmber,
                bg: const Color(0xFFFFF9EB),
                label: 'Joined ${sp.formattedRegDate}',
              ),
            ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  final String label;
  const _BadgeChip({
    required this.icon,
    required this.color,
    required this.bg,
    required this.label,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION TITLE
// ═══════════════════════════════════════════════════════════════════════════
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle(this.title, this.icon);
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 3,
          height: 20,
          decoration: BoxDecoration(
            color: _kBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 17, color: _kBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : _kNavy,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PERSONAL INFO BLOCK — two horizontal contact cards side-by-side
// ═══════════════════════════════════════════════════════════════════════════
class _PersonalInfoBlock extends StatelessWidget {
  final ScholarProvider sp;
  final bool isDark;
  const _PersonalInfoBlock({required this.sp, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ContactTile(
                icon: Icons.phone_rounded,
                color: _kGreen,
                bg: _kGreenSoft,
                label: 'Mobile',
                value: sp.mobile.isNotEmpty ? '+91 ${sp.mobile}' : '—',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ContactTile(
                icon: Icons.email_rounded,
                color: _kBlue,
                bg: _kBlueSoft,
                label: 'Email',
                value: sp.email.isNotEmpty ? sp.email : '—',
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
class _ContactTile extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  final String label, value;
  final bool isDark;
  const _ContactTile({
    required this.icon,
    required this.color,
    required this.bg,
    required this.label,
    required this.value,
    required this.isDark,
  });
  
  @override
  Widget build(BuildContext context) {
    final surface = isDark ? _kDarkCard : Colors.white;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? _kDarkBorder : _kBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Label in same row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _kHint,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Value below
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : _kNavy,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
// ═══════════════════════════════════════════════════════════════════════════
// SECONDARY EMAILS — numbered pill list
// ═══════════════════════════════════════════════════════════════════════════
class _SecondaryEmailsBlock extends StatelessWidget {
  final List<String> emails;
  final bool isDark;
  const _SecondaryEmailsBlock({required this.emails, required this.isDark});
  @override
  Widget build(BuildContext context) {
    final surface = isDark ? _kDarkCard : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? _kDarkBorder : _kBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: emails.asMap().entries.map((e) {
          final isLast = e.key == emails.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Numbered circle
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _kBlueSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${e.key + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _kBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.mail_outline_rounded,
                      size: 15,
                      color: _kHint,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : _kNavy,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Copy button
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: e.value));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Email copied'),
                            duration: Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _kBlueSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.copy_rounded,
                          size: 14,
                          color: _kBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: isDark ? _kDarkBorder : _kBorder,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WORK INFO BLOCK — 2-column icon grid
// ═══════════════════════════════════════════════════════════════════════════
class _WorkInfoBlock extends StatelessWidget {
  final ScholarProvider sp;
  final bool isDark;
  const _WorkInfoBlock({required this.sp, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final items = [
      _WorkItem(
        Icons.domain_rounded,
        _kBlue,
        _kBlueSoft,
        'Domain',
        sp.domainName,
      ),
      _WorkItem(
        Icons.menu_book_rounded,
        _kAmber,
        const Color(0xFFFFF9EB),
        'Journal Index',
        sp.journalIndex,
      ),
      _WorkItem(
        Icons.person_search_rounded,
        _kGreen,
        _kGreenSoft,
        'Technical Expert',
        sp.techExpert,
      ),
      _WorkItem(
        Icons.phone_forwarded_rounded,
        _kGreen,
        _kGreenSoft,
        'Expert Contact',
        sp.techExpertContact,
      ),
      _WorkItem(
        Icons.support_agent_rounded,
        _kBlue,
        _kBlueSoft,
        'BDA Name',
        sp.bdaName,
      ),
      _WorkItem(
        Icons.contact_phone_rounded,
        _kBlue,
        _kBlueSoft,
        'BDA Contact',
        sp.bdaContact,
      ),
    ];

    return Column(
      children: [
        for (int i = 0; i < items.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: _WorkTile(item: items[i], isDark: isDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < items.length
                      ? _WorkTile(item: items[i + 1], isDark: isDark)
                      : const SizedBox(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _WorkItem {
  final IconData icon;
  final Color color, bg;
  final String label, value;
  const _WorkItem(this.icon, this.color, this.bg, this.label, this.value);
}

class _WorkTile extends StatelessWidget {
  final _WorkItem item;
  final bool isDark;
  const _WorkTile({required this.item, required this.isDark});
  
  @override
  Widget build(BuildContext context) {
    final surface = isDark ? _kDarkCard : Colors.white;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? _kDarkBorder : _kBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Label in same row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, size: 18, color: item.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _kHint,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Value below
          Text(
            item.value.isNotEmpty ? item.value : '—',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : _kNavy,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WORK DESCRIPTION
// ═══════════════════════════════════════════════════════════════════════════
class _WorkDescBlock extends StatefulWidget {
  final String text;
  final bool isDark;
  const _WorkDescBlock({required this.text, required this.isDark});
  @override
  State<_WorkDescBlock> createState() => _WorkDescBlockState();
}

class _WorkDescBlockState extends State<_WorkDescBlock> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final surface = widget.isDark ? _kDarkCard : Colors.white;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.isDark ? _kDarkBorder : _kBorder,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: widget.isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _expanded ? '↑ Show less' : '↓ Read more',
                style: const TextStyle(
                  fontSize: 12,
                  color: _kBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WORK PROGRESS — straight segmented bar style
// ═══════════════════════════════════════════════════════════════════════════
class _WorkProgressBlock extends StatelessWidget {
  final bool isDark;
  const _WorkProgressBlock({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkProgressProvider>();
    final hasData =
        wp.workProgress != null &&
        (wp.progressPercentage > 0 || wp.latestNote.isNotEmpty);
    if (!hasData) return const SizedBox.shrink();

    final pct = wp.progressPercentage.clamp(0.0, 100.0);
    final note = wp.latestNote;
    final date = wp.lastUpdateDate;
    final surface = isDark ? _kDarkCard : Colors.white;

    // Determine status color
    final Color statusColor = pct >= 80
        ? _kGreen
        : pct >= 50
        ? _kAmber
        : _kBlue;
    final Color statusBg = pct >= 80
        ? _kGreenSoft
        : pct >= 50
        ? const Color(0xFFFFFBEB)
        : _kBlueSoft;
    final String statusLabel = pct >= 80
        ? 'Excellent'
        : pct >= 50
        ? 'Good Progress'
        : 'In Progress';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Work Progress', Icons.trending_up_rounded),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? _kDarkBorder : _kBorder,
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: pct + status badge
              Row(
                children: [
                  Text(
                    '${pct.toInt()}%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Overall completion',
                        style: TextStyle(fontSize: 11, color: _kHint),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Segmented bar (10 segments)
              _SegmentedBar(
                progress: pct / 100,
                color: statusColor,
                isDark: isDark,
              ),

              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '0%',
                    style: TextStyle(fontSize: 10, color: _kHint),
                  ),
                  const Text(
                    '50%',
                    style: TextStyle(fontSize: 10, color: _kHint),
                  ),
                  const Text(
                    '100%',
                    style: TextStyle(fontSize: 10, color: _kHint),
                  ),
                ],
              ),

              // Note section
              if (note.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? _kDarkCard2 : _kBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? _kDarkBorder : _kBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.sticky_note_2_rounded,
                            size: 14,
                            color: _kBlue,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Latest Note',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _kBlue,
                            ),
                          ),
                          const Spacer(),
                          if (date.isNotEmpty)
                            Text(
                              _fmtDate(date),
                              style: const TextStyle(
                                fontSize: 10,
                                color: _kHint,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        note,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: isDark ? Colors.white70 : _kNavy,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _fmtDate(String raw) {
    try {
      final dt = DateTime.parse(raw.split(' ')[0].split('T')[0]);
      const m = [
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
      return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

// Segmented progress bar
class _SegmentedBar extends StatelessWidget {
  final double progress; // 0.0 – 1.0
  final Color color;
  final bool isDark;
  const _SegmentedBar({
    required this.progress,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const segments = 12;
    final filled = (progress * segments).round().clamp(0, segments);
    final trackColor = isDark ? _kDarkCard2 : _kBg;

    return Row(
      children: List.generate(segments, (i) {
        final isFilled = i < filled;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 10,
            decoration: BoxDecoration(
              color: isFilled ? color : trackColor,
              borderRadius: BorderRadius.circular(4),
              border: isFilled
                  ? null
                  : Border.all(
                      color: isDark ? _kDarkBorder : _kBorder,
                      width: 0.5,
                    ),
            ),
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ERROR VIEW
// ═══════════════════════════════════════════════════════════════════════════
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: _kRedSoft, shape: BoxShape.circle),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: _kRed,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Error loading profile',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _kNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: _kHint),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: _kBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}


// ═══════════════════════════════════════════════════════════════════════════
// DIAGONAL TOP CLIPPER - Creates diagonal line with top-left at 10% down
// ═══════════════════════════════════════════════════════════════════════════
class _DiagonalTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Start from top-left corner at 55% down
    path.moveTo(0, size.height * 0.30);
    
    // Draw diagonal line from top-left to bottom-right
    path.lineTo(size.width, size.height);
    
    // Draw along bottom edge to bottom-left corner
    path.lineTo(0, size.height);
    
    // Draw back up to the starting point along left edge
    path.lineTo(0, size.height * 0.30);
    
    path.close();
    
    return path;
  }
  
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}