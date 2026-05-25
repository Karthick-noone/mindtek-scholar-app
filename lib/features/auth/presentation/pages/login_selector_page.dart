import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mindtek_scholar_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:mindtek_scholar_app/providers/scholar_provider.dart';
import 'forgot_password_page.dart';

// ─── Enhanced Color Palette ────────────────────────────────────────────────
const _kPrimary = Color(0xFF1A2B4C);
const _kPrimaryLight = Color(0xFF2A3B7C);
const _kPrimaryDark = Color(0xFF0F1F3D);
const _kAccent = Color(0xFF1116F4);
const _kAccentLight = Color(0xFF3B82F6);
const _kAccentGradient = Color(0xFF6B8CFF);
const _kSuccess = Color(0xFF10B981);
const _kSuccessLight = Color(0xFFD1FAE5);
const _kWarning = Color(0xFFF59E0B);
const _kError = Color(0xFFEF4444);
const _kErrorLight = Color(0xFFFEE2F2);
const _kBlueSoft = Color(0xFFEEF2FF);
const _kBg = Color(0xFFF8FAFC);
const _kCard = Colors.white;
const _kBorder = Color(0xFFE2E8F0);
const _kHint = Color(0xFF64748B);
const _kFieldBg = Color(0xFFF8FAFC);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool _obscure = true;
  final _userIdCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  late AnimationController _ctl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fade = CurvedAnimation(parent: _ctl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctl, curve: Curves.easeOut));
    _ctl.forward();
  }

  @override
  void dispose() {
    _ctl.dispose();
    _userIdCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (_userIdCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      _snack('Please enter User ID and Password', true);
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_userIdCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    if (!ok) _snack(auth.errorMessage ?? 'Invalid User ID or Password', true);
  }

  void _snack(String msg, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? _kError : _kSuccess,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Consumer<AuthProvider>(
      builder: (_, auth, __) => Scaffold(
        backgroundColor: _kBg,
        resizeToAvoidBottomInset: true,
        body: LayoutBuilder(
          builder: (ctx, constraints) {
            if (constraints.maxWidth >= 860) {
              return _DesktopLayout(
                fade: _fade,
                slide: _slide,
                userIdCtrl: _userIdCtrl,
                passwordCtrl: _passwordCtrl,
                obscure: _obscure,
                onToggle: () => setState(() => _obscure = !_obscure),
                onLogin: _handleLogin,
                auth: auth,
                onForgot: _goForgot,
              );
            }
            return _MobileLayout(
              fade: _fade,
              slide: _slide,
              userIdCtrl: _userIdCtrl,
              passwordCtrl: _passwordCtrl,
              obscure: _obscure,
              onToggle: () => setState(() => _obscure = !_obscure),
              onLogin: _handleLogin,
              auth: auth,
              onForgot: _goForgot,
            );
          },
        ),
      ),
    );
  }

  void _goForgot() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// MOBILE LAYOUT
// ═══════════════════════════════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════
// MOBILE LAYOUT - Fixed (removed footer space)
// ═══════════════════════════════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════
// MOBILE LAYOUT - Fixed (footer space removed)
// ═══════════════════════════════════════════════════════════════════════════

class _MobileLayout extends StatelessWidget {
  final Animation<double> fade;
  final Animation<Offset> slide;
  final TextEditingController userIdCtrl, passwordCtrl;
  final bool obscure;
  final VoidCallback onToggle, onLogin, onForgot;
  final AuthProvider auth;

  const _MobileLayout({
    required this.fade,
    required this.slide,
    required this.userIdCtrl,
    required this.passwordCtrl,
    required this.obscure,
    required this.onToggle,
    required this.onLogin,
    required this.auth,
    required this.onForgot,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header content (not scrollable)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: FadeTransition(
                opacity: fade,
                child: Row(
                  children: [_LogoRow(), const Spacer(), const _HelpBtn()],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: FadeTransition(
                opacity: fade,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: _kPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to continue your journey',
                      style: TextStyle(
                        fontSize: 14,
                        color: _kHint,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: FadeTransition(
                opacity: fade,
                child: Row(
                  children: const [
                    Expanded(child: _StatChip(Icons.people_alt_outlined, '2.4k+', 'Active scholars')),
                    SizedBox(width: 10),
                    Expanded(child: _StatChip(Icons.show_chart_rounded, '98%', 'Success rate')),
                    SizedBox(width: 10),
                    Expanded(child: _StatChip(Icons.workspace_premium_rounded, '12yr', 'Excellence')),
                  ],
                ),
              ),
            ),

            // Scrollable form content
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: SlideTransition(
                  position: slide,
                  child: FadeTransition(
                    opacity: fade,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 28),
                      decoration: BoxDecoration(
                        color: _kCard,
                        borderRadius: const BorderRadius.all(Radius.circular(28)),
                        border: Border.all(color: _kBorder, width: 0.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, -4),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: _kAccent.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, -8),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                      child: _FormContent(
                        userIdCtrl: userIdCtrl,
                        passwordCtrl: passwordCtrl,
                        obscure: obscure,
                        onToggle: onToggle,
                        onLogin: onLogin,
                        auth: auth,
                        onForgot: onForgot,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ═══════════════════════════════════════════════════════════════════════════
// DESKTOP LAYOUT
// ═══════════════════════════════════════════════════════════════════════════
// DESKTOP LAYOUT - Fixed with margins and no scroll
class _DesktopLayout extends StatelessWidget {
  final Animation<double> fade;
  final Animation<Offset> slide;
  final TextEditingController userIdCtrl, passwordCtrl;
  final bool obscure;
  final VoidCallback onToggle, onLogin, onForgot;
  final AuthProvider auth;

  const _DesktopLayout({
    required this.fade,
    required this.slide,
    required this.userIdCtrl,
    required this.passwordCtrl,
    required this.obscure,
    required this.onToggle,
    required this.onLogin,
    required this.auth,
    required this.onForgot,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Side - Branding Section
        Expanded(
          flex: 55,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF1A2B4C), const Color(0xFF2A3B7C)],
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: fade,
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LogoRow(),
                      const SizedBox(height: 56),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Track research progress, manage\npayments and contact support.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white70,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: const [
                          Expanded(child: _StatChip(Icons.people_alt_outlined, '2.4k+', 'Active scholars')),
                          SizedBox(width: 14),
                          Expanded(child: _StatChip(Icons.show_chart_rounded, '98%', 'Success rate')),
                          SizedBox(width: 14),
                          Expanded(child: _StatChip(Icons.workspace_premium_rounded, '12yr', 'Excellence')),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: const [
                          Icon(Icons.shield_outlined, size: 14, color: Colors.white70),
                          SizedBox(width: 6),
                          Text(
                            '256-bit encrypted · Enterprise-grade security',
                            style: TextStyle(fontSize: 11, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Right Side - Form Container with margins
        Expanded(
          flex: 45,
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Form Container with margins on left and right
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40), // Left and right margin
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: SlideTransition(
                    position: slide,
                    child: FadeTransition(
                      opacity: fade,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _kCard,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: _FormContent(
                            userIdCtrl: userIdCtrl,
                            passwordCtrl: passwordCtrl,
                            obscure: obscure,
                            onToggle: onToggle,
                            onLogin: onLogin,
                            auth: auth,
                            onForgot: onForgot,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LOGO ROW
// ═══════════════════════════════════════════════════════════════════════════

class _LogoRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String? logoUrl;
    try {
      logoUrl = context.read<ScholarProvider>().companyLogo;
    } catch (_) {}

    return Row(
      mainAxisSize: MainAxisSize.min,
     children: [
  Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_kAccent, _kAccentLight],
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: _kAccent.withOpacity(0.35),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: const Icon(Icons.school_rounded, color: Colors.white, size: 24), // Always show icon, not logo image
  ),
  const SizedBox(width: 12),
  Image.asset(
    "assets/images/mindtek-logo.png",
    height: 32,
  ),
],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HELP BUTTON
// ═══════════════════════════════════════════════════════════════════════════

class _HelpBtn extends StatelessWidget {
  const _HelpBtn();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: _kCard,
      border: Border.all(color: _kBorder, width: 0.5),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: const Text(
      'Scholar Portal',
      style: TextStyle(
        fontSize: 11,
        color: _kHint,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// STAT CHIP
// ═══════════════════════════════════════════════════════════════════════════

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _StatChip(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kCard,
        border: Border.all(color: _kBorder, width: 0.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_kAccent, _kAccentLight]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _kPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: _kHint),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FORM CONTENT - Premium Design
// ═══════════════════════════════════════════════════════════════════════════

class _FormContent extends StatelessWidget {
  final TextEditingController userIdCtrl, passwordCtrl;
  final bool obscure;
  final VoidCallback onToggle, onLogin, onForgot;
  final AuthProvider auth;

  const _FormContent({
    required this.userIdCtrl,
    required this.passwordCtrl,
    required this.obscure,
    required this.onToggle,
    required this.onLogin,
    required this.auth,
    required this.onForgot,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_kAccent, _kAccentLight],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Access Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _kPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                'Enter your credentials to continue',
                style: TextStyle(
                  fontSize: 13,
                  color: _kHint,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),

        // User ID Field
        _EnhancedLoginField(
          label: 'USER ID',
          hint: 'Enter your user ID',
          icon: Icons.badge_outlined,
          controller: userIdCtrl,
        ),
        const SizedBox(height: 28),

        // Password Field
        _EnhancedLoginField(
          label: 'PASSWORD',
          hint: 'Enter your password',
          icon: Icons.fingerprint_outlined,
          controller: passwordCtrl,
          obscure: obscure,
          suffix: GestureDetector(
            onTap: onToggle,
            child: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20,
              color: _kHint,
            ),
          ),
        ),
        
        const SizedBox(height: 16),

        // Forgot Password
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: onForgot,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                'Forgot password?',
                style: TextStyle(
                  fontSize: 13,
                  color: _kAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),

        // Sign In Button
        _EnhancedSignInButton(
          onLogin: onLogin, 
          isLoading: auth.isLoading,
        ),
        
        // const SizedBox(height: 32),

        // Divider
        // Row(
        //   children: [
        //     Expanded(
        //       child: Container(
        //         height: 1,
        //         color: _kBorder,
        //       ),
        //     ),
        //     const Padding(
        //       padding: EdgeInsets.symmetric(horizontal: 16),
        //       child: Row(
        //         children: [
        //           Icon(Icons.shield_rounded, size: 12, color: _kHint),
        //           SizedBox(width: 6),
        //           Text(
        //             'Secured by MindTek',
        //             style: TextStyle(
        //               fontSize: 11,
        //               color: _kHint,
        //               fontWeight: FontWeight.w500,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //     Expanded(
        //       child: Container(
        //         height: 1,
        //         color: _kBorder,
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ENHANCED LOGIN FIELD
// ═══════════════════════════════════════════════════════════════════════════

class _EnhancedLoginField extends StatelessWidget {
  final String label, hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscure;
  final Widget? suffix;

  const _EnhancedLoginField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 12,
              decoration: BoxDecoration(
                color: _kAccent,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _kHint,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        
        Container(
          child: Row(
            children: [
              Icon(icon, size: 20, color: _kAccent),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _kPrimary,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: _kHint,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: _kBorder,
                        width: 1,
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: _kAccent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              if (suffix != null) 
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: suffix,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SIGN IN BUTTON
// ═══════════════════════════════════════════════════════════════════════════

class _EnhancedSignInButton extends StatelessWidget {
  final VoidCallback onLogin;
  final bool isLoading;

  const _EnhancedSignInButton({
    required this.onLogin, 
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kAccent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _kAccent.withOpacity(0.5),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}