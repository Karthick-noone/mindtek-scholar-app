import 'package:mindtek_scholar_app/features/scholar/data/datasources/change_password_remote_datasource.dart';

class ChangePasswordRepository {
  final ChangePasswordRemoteDataSource remoteDataSource;
  
  ChangePasswordRepository(this.remoteDataSource);
  
  Future<Map<String, dynamic>> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await remoteDataSource.changePassword(
      userId: userId,
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}