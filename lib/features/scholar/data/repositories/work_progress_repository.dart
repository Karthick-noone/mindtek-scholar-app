import 'package:mindtek_scholar_app/features/scholar/data/datasources/work_progress_remote_datasource.dart';

class WorkProgressRepository {
  final WorkProgressRemoteDataSource remoteDataSource;
  
  WorkProgressRepository(this.remoteDataSource);
  
  Future<Map<String, dynamic>> getLastWorkStatus(int scholarId) async {
    return await remoteDataSource.getLastWorkStatus(scholarId);
  }
}