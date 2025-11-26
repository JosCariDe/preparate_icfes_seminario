import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  Future<User?> checkAuthStatus();
  Future<void> logout();
}

class MockAuthRepository implements AuthRepository {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    if (email == 'juan.perez@example.com' && password == 'Password123!') {
      final user = const User(
        id: 'usr_123456',
        nombre: 'Juan',
        apellido: 'Pérez',
        email: 'juan.perez@example.com',
        rol: 'ESTUDIANTE',
        avatar: 'https://example.com/avatars/usr_123456.jpg',
        token: 'mock_token_123',
        refreshToken: 'mock_refresh_token_123',
      );
      
      await _saveSession(user);
      return user;
    } else if (email == 'admin@example.com' && password == 'Admin123!') {
      final user = const User(
        id: 'usr_admin_001',
        nombre: 'Admin',
        apellido: 'User',
        email: 'admin@example.com',
        rol: 'ADMIN',
        avatar: 'https://example.com/avatars/admin.jpg',
        token: 'mock_token_admin',
        refreshToken: 'mock_refresh_token_admin',
      );

      await _saveSession(user);
      return user;
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

    final user = User(
      id: 'usr_new_123',
      nombre: nombre,
      apellido: apellido,
      email: email,
      rol: 'ESTUDIANTE',
      token: 'mock_token_new_123',
    );

    await _saveSession(user);
    return user;
  }

  @override
  Future<User?> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);

    if (token != null && userJson != null) {
      try {
        // Recuperar el usuario guardado desde JSON
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      } catch (e) {
        // Si hay error al parsear, limpiar la sesión
        await logout();
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<void> _saveSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user.token != null) {
      await prefs.setString(_tokenKey, user.token!);
      // Guardar el usuario completo como JSON para mantener el rol y otros datos
      await prefs.setString(_userKey, json.encode(user.toJson()));
    }
  }
}
