import '../models/user_model.dart';
import 'auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  final String apiUrl;

  ApiAuthRepository({required this.apiUrl});

  @override
  Future<User> login(String email, String password) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<User> register({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    required String fechaNacimiento,
    required String institucion,
  }) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<User?> checkAuthStatus() async {
    // TODO: Implement API call to validate token
    return null;
  }

  @override
  Future<void> logout() async {
    // TODO: Implement API call
  }
}
