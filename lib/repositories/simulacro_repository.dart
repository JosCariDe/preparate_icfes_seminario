import '../models/simulacro_model.dart';
import '../models/question_model.dart';

abstract class SimulacroRepository {
  Future<List<Simulacro>> getSimulacros({String? area, String? nivel});
  Future<Simulacro> getSimulacroById(String id);
}

class MockSimulacroRepository implements SimulacroRepository {
  @override
  Future<List<Simulacro>> getSimulacros({String? area, String? nivel}) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Simulacro(
        id: 'sim_001',
        titulo: 'Simulacro de Matemáticas',
        descripcion: 'Prueba de álgebra, funciones y razonamiento cuantitativo.',
        area: 'Matemáticas',
        nivel: 'Medio',
        duracionMinutos: 90,
        totalPreguntas: 40,
        progreso: const ProgresoSimulacro(
          completado: false,
          preguntasRespondidas: 15,
          porcentajeAvance: 37.5,
          ultimoIntento: null, // DateTime.parse("2025-01-10T14:30:00Z")
        ),
        estadisticas: const EstadisticasSimulacro(
          intentos: 2,
          mejorPuntuacion: 82.5,
          promedio: 75.0,
        ),
      ),
      Simulacro(
        id: 'sim_002',
        titulo: 'Simulacro de Inglés',
        descripcion: 'Evaluación de comprensión lectora, gramática y vocabulario en inglés.',
        area: 'Inglés',
        nivel: 'Medio',
        duracionMinutos: 60,
        totalPreguntas: 45,
        progreso: const ProgresoSimulacro(
          completado: false,
          preguntasRespondidas: 0,
          porcentajeAvance: 0,
          ultimoIntento: null,
        ),
        estadisticas: const EstadisticasSimulacro(
          intentos: 0,
          mejorPuntuacion: null,
          promedio: null,
        ),
      ),
    ];
  }

  @override
  Future<Simulacro> getSimulacroById(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    if (id == 'sim_001') {
      return Simulacro(
        id: 'sim_001',
        titulo: 'Simulacro de Matemáticas',
        descripcion: 'Prueba de álgebra, funciones y razonamiento cuantitativo.',
        area: 'Matemáticas',
        nivel: 'Medio',
        duracionMinutos: 90,
        totalPreguntas: 40,
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
          Pregunta(
            id: 'preg_002',
            enunciado: '¿Cuál es la raíz cuadrada de 144?',
            area: 'Matemáticas',
            tema: 'Aritmética',
            nivel: 'Bajo',
            tipo: 'UNICA_OPCION',
            competencia: 'Razonamiento cuantitativo',
            retroalimentacion: 'La raíz cuadrada es el número que multiplicado por sí mismo da 144. En este caso, 12 × 12 = 144.',
            opciones: [
              Opcion(id: 'opt_005', texto: '10', correcta: false),
              Opcion(id: 'opt_006', texto: '11', correcta: false),
              Opcion(id: 'opt_007', texto: '12', correcta: true),
              Opcion(id: 'opt_008', texto: '14', correcta: false),
            ],
          ),
          Pregunta(
            id: 'preg_003',
            enunciado: 'Si un rectángulo mide 8 cm de largo y 3 cm de ancho, ¿cuál es su área?',
            area: 'Matemáticas',
            tema: 'Geometría',
            nivel: 'Bajo',
            tipo: 'UNICA_OPCION',
            competencia: 'Razonamiento cuantitativo',
            retroalimentacion: 'El área de un rectángulo se calcula multiplicando el largo por el ancho: Área = 8 cm × 3 cm = 24 cm².',
            opciones: [
              Opcion(id: 'opt_009', texto: '20 cm²', correcta: false),
              Opcion(id: 'opt_010', texto: '24 cm²', correcta: true),
              Opcion(id: 'opt_011', texto: '26 cm²', correcta: false),
              Opcion(id: 'opt_012', texto: '18 cm²', correcta: false),
            ],
          ),
        ],
      );
    }
    throw Exception('Simulacro no encontrado');
  }
}
