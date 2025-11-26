import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/simulacro_model.dart';
import 'simulacro_repository.dart';

class ApiSimulacroRepository implements SimulacroRepository {
  final String apiUrl;
  static const String _tokenKey = 'auth_token';

  ApiSimulacroRepository({required this.apiUrl});

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<Simulacro>> getSimulacros({String? area, String? nivel}) async {
    final headers = await _getHeaders();
    final queryParams = <String, String>{};
    if (area != null) queryParams['area'] = area;
    if (nivel != null) queryParams['nivel'] = nivel;

    final uri = Uri.parse('$apiUrl/api/simulacros').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        final simulacrosData = jsonResponse['data']['simulacros'] as List;
        return simulacrosData.map((json) => Simulacro.fromJson(json)).toList();
      } else {
        throw Exception(jsonResponse['error']['message'] ?? 'Error al obtener simulacros');
      }
    } else {
      throw Exception('Error al conectar con el servidor');
    }
  }

  @override
  Future<Simulacro> getSimulacroById(String id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$apiUrl/api/simulacros/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        return Simulacro.fromJson(jsonResponse['data']);
      } else {
        throw Exception(jsonResponse['error']['message'] ?? 'Error al obtener simulacro');
      }
    } else if (response.statusCode == 404) {
      throw Exception('Simulacro no encontrado');
    } else {
      throw Exception('Error al conectar con el servidor');
    }
  }
}
