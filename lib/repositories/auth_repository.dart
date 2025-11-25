import '../models/user_model.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    required String fechaNacimiento,
    required String institucion,
  });
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    if (email == 'juan.perez@example.com' && password == '12345678') {
      return const User(
        id: 'usr_123456',
        nombre: 'Juan',
        apellido: 'Pérez',
        email: 'juan.perez@example.com',
        rol: 'ESTUDIANTE',
        avatar: 'https://example.com/avatars/usr_123456.jpg',
        token: 'mock_token_123',
        refreshToken: 'mock_refresh_token_123',
      );
    } else {
      throw Exception('Email o contraseña incorrectos');
    }
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
    await Future.delayed(const Duration(seconds: 2));

    if (email == 'juan.perez@example.com') {
      throw Exception('El correo electrónico ya está registrado');
    }

    return User(
      id: 'usr_new_123',
      nombre: nombre,
      apellido: apellido,
      email: email,
      rol: 'ESTUDIANTE',
      token: 'mock_token_new_123',
    );
  }
}
