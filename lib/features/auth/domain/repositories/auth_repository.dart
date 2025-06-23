abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String userName, String password);
  Future<void> logout();
}

