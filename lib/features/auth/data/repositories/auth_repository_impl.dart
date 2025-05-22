import 'package:station_manager/features/auth/data/datasources/auth_remote_data_sources.dart';
import 'package:station_manager/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthRemoteDataSources authRemoteDataSources;

  AuthRepositoryImpl({required this.authRemoteDataSources});

  @override
  Future<Map<String, dynamic>> login(String userName, String password) {
    return authRemoteDataSources.login(userName, password);
  }

  @override
  Future<void> logout() {
    return authRemoteDataSources.logOut();
  }
}
