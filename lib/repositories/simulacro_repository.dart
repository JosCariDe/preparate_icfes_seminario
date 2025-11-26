import '../models/simulacro_model.dart';
import '../models/question_model.dart';
import '../services/data_persistence_service.dart';

abstract class SimulacroRepository {
  Future<List<Simulacro>> getSimulacros({String? area, String? nivel});
  Future<Simulacro> getSimulacroById(String id);
}

class MockSimulacroRepository implements SimulacroRepository {
  @override
  Future<List<Simulacro>> getSimulacros({String? area, String? nivel}) async {
    await Future.delayed(const Duration(seconds: 1));
    var simulacros = await DataPersistenceService.getSimulacros();
    
    // Aplicar filtros
    if (area != null) {
      simulacros = simulacros.where((s) => s.area == area).toList();
    }
    if (nivel != null) {
      simulacros = simulacros.where((s) => s.nivel == nivel).toList();
    }
    
    return simulacros;
  }

  @override
  Future<Simulacro> getSimulacroById(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    final simulacros = await DataPersistenceService.getSimulacros();
    final simulacro = simulacros.firstWhere(
      (s) => s.id == id,
      orElse: () => _getDefaultSimulacro(id),
    );
    
    // Si el simulacro tiene preguntas, retornarlo tal cual
    if (simulacro.preguntas != null && simulacro.preguntas!.isNotEmpty) {
      return simulacro;
    }
    
    // Si no tiene preguntas, buscar preguntas relacionadas y agregarlas
    final questions = await DataPersistenceService.getQuestions();
    final relatedQuestions = questions
        .where((q) => q['area'] == simulacro.area)
        .take(3)
        .map((q) => _mapQuestionToPregunta(q))
        .toList();
    
    return Simulacro(
      id: simulacro.id,
      titulo: simulacro.titulo,
      descripcion: simulacro.descripcion,
      area: simulacro.area,
      nivel: simulacro.nivel,
      duracionMinutos: simulacro.duracionMinutos,
      totalPreguntas: relatedQuestions.length,
      instrucciones: simulacro.instrucciones ?? 'Lee cuidadosamente cada pregunta antes de responder.',
      preguntas: relatedQuestions,
      progreso: simulacro.progreso,
      estadisticas: simulacro.estadisticas,
    );
  }

  Simulacro _getDefaultSimulacro(String id) {
    return Simulacro(
      id: id,
      titulo: 'Simulacro de Matemáticas',
      descripcion: 'Prueba de álgebra, funciones y razonamiento cuantitativo.',
      area: 'Matemáticas',
      nivel: 'Medio',
      duracionMinutos: 90,
      totalPreguntas: 3,
      instrucciones: 'Lee cuidadosamente cada pregunta antes de responder. Tienes 90 minutos para completar el simulacro.',
      preguntas: const [
        Pregunta(
          id: 'preg_001',
          enunciado: '¿Cuál es el valor de x en la ecuación 3x + 9 = 24?',
          area: 'Matemáticas',
          tema: 'Álgebra',
          nivel: 'Medio',
          tipo: 'UNICA_OPCION',
          competencia: 'Razonamiento cuantitativo',
          retroalimentacion: 'Para resolver esta ecuación lineal, primero debes restar 9 de ambos lados: 3x = 15. Luego, divide ambos lados entre 3 para obtener x = 5.',
          opciones: [
            Opcion(id: 'opt_001', texto: '3', correcta: false),
            Opcion(id: 'opt_002', texto: '5', correcta: true),
            Opcion(id: 'opt_003', texto: '6', correcta: false),
            Opcion(id: 'opt_004', texto: '8', correcta: false),
          ],
        ),
      ],
    );
  }

  Pregunta _mapQuestionToPregunta(Map<String, dynamic> questionData) {
    final options = (questionData['options'] as List)
        .map((opt) => Opcion(
              id: opt['id'] as String,
              texto: opt['text'] as String,
              correcta: opt['correct'] == true,
            ))
        .toList();

    return Pregunta(
      id: questionData['id'] as String,
      enunciado: questionData['question'] as String,
      area: questionData['area'] as String,
      tema: questionData['tema'] as String? ?? 'General',
      nivel: questionData['nivel'] as String? ?? 'Medio',
      tipo: questionData['tipo'] as String? ?? 'UNICA_OPCION',
      competencia: questionData['competencia'] as String?,
      retroalimentacion: questionData['retroalimentacion'] as String?,
      opciones: options,
    );
  }
}
