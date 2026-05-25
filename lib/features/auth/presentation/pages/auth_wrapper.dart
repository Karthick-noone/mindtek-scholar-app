// auth_wrapper.dart - Fixed Version
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mindtek_scholar_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:mindtek_scholar_app/features/auth/presentation/pages/login_selector_page.dart';
import 'package:mindtek_scholar_app/features/scholar/presentation/pages/scholar_dashboard_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // While the provider is performing the initial auth check, show a loader
        if (!authProvider.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If logged in, go to dashboard
        if (authProvider.isAuthenticated) {
          final userId = authProvider.userId ?? 'User';
          print('Navigating to Dashboard with userId: $userId');
          return DashboardPage(userId: userId);
        } 
        // Otherwise show login page
        else {
          print('Navigating to Login Page');
          return const LoginPage();
        }
      },
    );
  }
}
