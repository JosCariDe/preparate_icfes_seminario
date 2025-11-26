import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  final String apiUrl;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  ApiAuthRepository({required this.apiUrl});

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        final userData = jsonResponse['data'];
        final user = User.fromJson(userData);
        await _saveSession(user);
        return user;
      } else {
        throw Exception(jsonResponse['error']['message'] ?? 'Error al iniciar sesión');
      }
    } else if (response.statusCode == 401) {
      final jsonResponse = json.decode(response.body);
      throw Exception(jsonResponse['error']['message'] ?? 'Email o contraseña incorrectos');
    } else {
      throw Exception('Error al conectar con el servidor');
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
    final response = await http.post(
      Uri.parse('$apiUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'password': password,
        'fechaNacimiento': fechaNacimiento,
        'institucion': institucion,
      }),
    );

    if (response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        final userData = jsonResponse['data'];
        final user = User.fromJson(userData);
        await _saveSession(user);
        return user;
      } else {
        throw Exception(jsonResponse['error']['message'] ?? 'Error al registrar');
      }
    } else if (response.statusCode == 400) {
      final jsonResponse = json.decode(response.body);
      throw Exception(jsonResponse['error']['message'] ?? 'Error al registrar');
    } else {
      throw Exception('Error al conectar con el servidor');
    }
  }

  @override
  Future<User?> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);

    if (token == null || userJson == null) {
      return null;
    }

    // En una app real, aquí validarías el token con el backend
    // Por ahora, retornamos el usuario guardado
    try {
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      await logout();
      return null;
    }
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
      await prefs.setString(_userKey, json.encode(user.toJson()));
    }
  }
}
