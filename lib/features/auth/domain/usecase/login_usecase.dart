import 'package:station_manager/features/auth/domain/repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository authRepository;

  LoginUsecase({required this.authRepository});
  Future<Map<String, dynamic>> call(String userName, String password) {
    return authRepository.login(userName, password);
  }
}

