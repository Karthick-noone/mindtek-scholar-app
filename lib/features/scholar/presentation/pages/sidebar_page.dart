import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'payment_history_page.dart';
import 'profile_page.dart';
import 'complaint_page.dart';
import 'change_password_page.dart';
import 'package:seasense_scholar_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:seasense_scholar_app/core/theme/app_colors.dart';
import 'package:seasense_scholar_app/providers/scholar_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:seasense_scholar_app/core/network/api_client.dart';
import 'package:seasense_scholar_app/core/network/api_endpoints.dart';

class SidebarPage extends StatefulWidget {
  final String userId;

  const SidebarPage({super.key, required this.userId});

  @override
  State<SidebarPage> createState() => _SidebarPageState();
}

class _SidebarPageState extends State<SidebarPage> {
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _checkScholarStatus();
  }

  Future<void> _checkScholarStatus() async {
    try {
      final scholarProvider = Provider.of<ScholarProvider>(
        context,
        listen: false,
      );
      
      // Get the stored user id (33)
      final String? userId = await scholarProvider.storage.read(key: 'id');
      
      print("Checking scholar status for ID: $userId");
      
      if (userId == null || userId.isEmpty) {
        print("No user ID found");
        return;
      }
      
      final response = await _apiClient.get(
        '/user/details/$userId',
      );
      
      print("Scholar status response: ${response.data}");
      
      String? scholarStatus;
      
      if (response.data != null) {
        final data = response.data;
        
        if (data is Map) {
          // Check different possible response structures
          if (data['data'] != null && data['data'] is Map) {
            scholarStatus = data['data']['scholar_status']?.toString();
          } 
          else if (data['scholar_status'] != null) {
            scholarStatus = data['scholar_status']?.toString();
          }
          else if (data['user'] != null && data['user'] is Map) {
            scholarStatus = data['user']['status']?.toString();
          }
          else if (data['scholar'] != null && data['scholar'] is Map) {
            scholarStatus = data['scholar']['scholar_status']?.toString();
          }
        }
      }
      
      final isActive = scholarStatus?.toLowerCase() == "active";
      
      print("Scholar status: $scholarStatus, isActive: $isActive");
      
      if (!isActive && mounted) {
        _showDeactivationDialog();
      }
    } catch (e) {
      print("Error checking scholar status: $e");
    }
  }

  Future<void> _showDeactivationDialog() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return WillPopScope(
        onWillPop: () async {
          // Prevent back button/gesture from closing the dialog
          return false;
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        const Color(0xFF1E1E1E),
                        const Color(0xFF2A2A2A),
                      ]
                    : [
                        Colors.white,
                        const Color(0xFFF8F9FA),
                      ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Icon Section - RED THEME
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title
                Text(
                  'Account Deactivated',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFFDC2626),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Red Divider
                Container(
                  width: 60,
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Your account has been deactivated. Please contact support for more information.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDarkMode ? Colors.white70 : const Color(0xFF666666),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // const SizedBox(height: 24),
                
                // // Support Info Box
                // Container(
                //   margin: const EdgeInsets.symmetric(horizontal: 24),
                //   padding: const EdgeInsets.all(16),
                //   decoration: BoxDecoration(
                //     gradient: LinearGradient(
                //       begin: Alignment.topLeft,
                //       end: Alignment.bottomRight,
                //       colors: [
                //         const Color(0xFFDC2626).withOpacity(0.1),
                //         const Color(0xFFB91C1C).withOpacity(0.05),
                //       ],
                //     ),
                //     borderRadius: BorderRadius.circular(15),
                //     border: Border.all(
                //       color: const Color(0xFFDC2626).withOpacity(0.3),
                //       width: 1,
                //     ),
                //   ),
                //   child: Row(
                //     children: [
                //       Container(
                //         padding: const EdgeInsets.all(8),
                //         decoration: BoxDecoration(
                //           color: const Color(0xFFDC2626).withOpacity(0.15),
                //           borderRadius: BorderRadius.circular(10),
                //         ),
                //         child: const Icon(
                //           Icons.support_agent,
                //           size: 18,
                //           color: Color(0xFFDC2626),
                //         ),
                //       ),
                //       const SizedBox(width: 12),
                //       Expanded(
                //         child: Text(
                //           'Contact support: support@seasense.in',
                //           style: TextStyle(
                //             fontSize: 12,
                //             fontWeight: FontWeight.w500,
                //             color: isDarkMode ? Colors.white70 : const Color(0xFF444444),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // const SizedBox(height: 30),
                
                // OK Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await _performLogout();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
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
        )
        );
      },
    );
  }

Future<void> _performLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    BuildContext? dialogContext;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context;
        return const PopScope(
          canPop: false,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );

    try {
      await authProvider.logout();

      if (dialogContext != null && Navigator.canPop(dialogContext!)) {
        Navigator.pop(dialogContext!);
      }

      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

    } catch (e) {
      print('Logout error: $e');
      if (dialogContext != null && Navigator.canPop(dialogContext!)) {
        Navigator.pop(dialogContext!);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    BuildContext? dialogContext;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context;
        return const PopScope(
          canPop: false,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );

    try {
      await authProvider.logout();
      
      if (dialogContext != null && Navigator.canPop(dialogContext!)) {
        Navigator.pop(dialogContext!);
      }
      
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
    } catch (e) {
      print('Logout error: $e');
      if (dialogContext != null && Navigator.canPop(dialogContext!)) {
        Navigator.pop(dialogContext!);
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Logout',
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _logout(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: isDarkMode ? Colors.red.shade400 : Colors.red,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scholarProvider = Provider.of<ScholarProvider>(context);
    final companyLogoUrl = scholarProvider.companyLogo;

    return Drawer(
      child: Container(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        companyLogoUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: companyLogoUrl,
                                width: 165,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => Image.asset(
                                  "assets/images/seasense-logo.png",
                                  height: 30,
                                ),
                                errorWidget: (context, url, error) => Image.asset(
                                  "assets/images/seasense-logo.png",
                                  height: 30,
                                ),
                              )
                            : Image.asset("assets/images/seasense-logo.png", height: 30),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 1,
              color: isDarkMode
                  ? Colors.grey.shade700
                  : AppColors.gradientStart.withOpacity(0.3),
            ),
            const SizedBox(height: 15),

            _drawerItem(
              context,
              Icons.person_outline,
              "Profile",
              const ProfilePage(),
            ),
            _drawerItem(
              context,
              Icons.currency_rupee,
              "Payment History",
              const PaymentHistoryPage(),
            ),
            _drawerItem(
              context,
              Icons.support_agent_outlined,
              "Register Complaint",
              const ComplaintPage(),
            ),
            _drawerItem(
              context,
              Icons.lock_outline,
              "Change Password",
              const ChangePasswordPage(),
            ),

            const Spacer(),

            Divider(
              thickness: 1,
              color: isDarkMode
                  ? Colors.grey.shade700
                  : AppColors.gradientStart.withOpacity(0.3),
            ),

            ListTile(
              leading: Icon(
                Icons.logout,
                color: isDarkMode ? Colors.red.shade400 : Colors.red,
              ),
              title: Text(
                "Logout",
                style: TextStyle(
                  color: isDarkMode ? Colors.red.shade400 : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => _showLogoutConfirmation(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: isDarkMode ? const Color(0xFF6B8CFF) : const Color(0xFF2A3B7C),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
}