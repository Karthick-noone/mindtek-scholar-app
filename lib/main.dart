// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/scholar_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/complaint_provider.dart';
import 'providers/work_progress_provider.dart';
import 'providers/change_password_provider.dart';  // Add this
import 'providers/theme_provider.dart';
import 'package:mindtek_scholar_app/core/theme/app_theme.dart';
import 'package:mindtek_scholar_app/features/auth/presentation/pages/auth_wrapper.dart';
import 'package:mindtek_scholar_app/core/network/api_client.dart';
import 'package:mindtek_scholar_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:mindtek_scholar_app/features/scholar/data/datasources/scholar_remote_datasource.dart';
import 'package:mindtek_scholar_app/features/scholar/data/repositories/scholar_repository.dart';
import 'package:mindtek_scholar_app/features/scholar/data/datasources/payment_remote_datasource.dart';
import 'package:mindtek_scholar_app/features/scholar/data/repositories/payment_repository.dart';
import 'package:mindtek_scholar_app/features/scholar/data/datasources/complaint_remote_datasource.dart';
import 'package:mindtek_scholar_app/features/scholar/data/repositories/complaint_repository.dart';
import 'package:mindtek_scholar_app/features/scholar/data/datasources/work_progress_remote_datasource.dart';
import 'package:mindtek_scholar_app/features/scholar/data/repositories/work_progress_repository.dart';
import 'package:mindtek_scholar_app/features/scholar/data/datasources/change_password_remote_datasource.dart';  // Add this
import 'package:mindtek_scholar_app/features/scholar/data/repositories/change_password_repository.dart';  // Add this

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API Client (no await needed since it's void)
  ApiClient().init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (context) {
            final apiClient = ApiClient();
            final remoteDataSource = ScholarRemoteDataSource(apiClient);
            final repository = ScholarRepository(remoteDataSource);
            return ScholarProvider(repository);
          },
        ),
        // PaymentProvider
        ChangeNotifierProvider(
          create: (context) {
            final apiClient = ApiClient();
            final remoteDataSource = PaymentRemoteDataSource(apiClient);
            final repository = PaymentRepository(remoteDataSource);
            return PaymentProvider(repository);
          },
        ),
        // ComplaintProvider
        ChangeNotifierProvider(
          create: (context) {
            final apiClient = ApiClient();
            final remoteDataSource = ComplaintRemoteDataSource(apiClient);
            final repository = ComplaintRepository(remoteDataSource);
            return ComplaintProvider(repository);
          },
        ),
        // WorkProgressProvider
        ChangeNotifierProvider(
          create: (context) {
            final apiClient = ApiClient();
            final remoteDataSource = WorkProgressRemoteDataSource(apiClient);
            final repository = WorkProgressRepository(remoteDataSource);
            return WorkProgressProvider(repository);
          },
        ),
        // ChangePasswordProvider - Add this
        ChangeNotifierProvider(
          create: (context) {
            final apiClient = ApiClient();
            final remoteDataSource = ChangePasswordRemoteDataSource(apiClient);
            final repository = ChangePasswordRepository(remoteDataSource);
            return ChangePasswordProvider(repository);
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Scholar App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}