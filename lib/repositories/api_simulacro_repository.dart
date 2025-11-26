import '../models/simulacro_model.dart';
import 'simulacro_repository.dart';

class ApiSimulacroRepository implements SimulacroRepository {
  final String apiUrl;

  ApiSimulacroRepository({required this.apiUrl});

  @override
  Future<List<Simulacro>> getSimulacros({String? area, String? nivel}) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<Simulacro> getSimulacroById(String id) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }
}
