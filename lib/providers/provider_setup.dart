// lib/providers/provider_setup.dart
import 'package:provider/provider.dart';
import 'package:mindtek_scholar_app/providers/scholar_provider.dart';
import 'package:mindtek_scholar_app/providers/theme_provider.dart';
import 'package:mindtek_scholar_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:mindtek_scholar_app/features/scholar/data/datasources/scholar_remote_datasource.dart';
import 'package:mindtek_scholar_app/features/scholar/data/repositories/scholar_repository.dart';
import 'package:mindtek_scholar_app/core/network/api_client.dart';

List<SingleChildWidget> providers = [
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
];