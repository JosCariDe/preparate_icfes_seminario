import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/simulacro_model.dart';

class DataPersistenceService {
  static const String _simulacrosKey = 'persisted_simulacros';
  static const String _questionsKey = 'persisted_questions';

  // Simulacros
  static Future<List<Simulacro>> getSimulacros() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_simulacrosKey);
    
    if (jsonString == null) {
      // Retornar datos iniciales si no hay nada guardado
      return _getInitialSimulacros();
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Simulacro.fromJson(json)).toList();
    } catch (e) {
      return _getInitialSimulacros();
    }
  }

  static Future<void> saveSimulacros(List<Simulacro> simulacros) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = simulacros.map((s) => s.toJson()).toList();
    await prefs.setString(_simulacrosKey, json.encode(jsonList));
  }

  static Future<void> addSimulacro(Simulacro simulacro) async {
    final simulacros = await getSimulacros();
    simulacros.add(simulacro);
    await saveSimulacros(simulacros);
  }

  // Preguntas
  static Future<List<Map<String, dynamic>>> getQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_questionsKey);
    
    if (jsonString == null) {
      // Retornar datos iniciales si no hay nada guardado
      return _getInitialQuestions();
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      return _getInitialQuestions();
    }
  }

  static Future<void> saveQuestions(List<Map<String, dynamic>> questions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_questionsKey, json.encode(questions));
  }

  static Future<void> addQuestion(Map<String, dynamic> question) async {
    final questions = await getQuestions();
    questions.add(question);
    await saveQuestions(questions);
  }

  static Future<void> updateQuestion(String questionId, Map<String, dynamic> updatedQuestion) async {
    final questions = await getQuestions();
    final index = questions.indexWhere((q) => q['id'] == questionId);
    if (index != -1) {
      questions[index] = updatedQuestion;
      await saveQuestions(questions);
    }
  }

  static Future<void> updateSimulacro(String simulacroId, Simulacro updatedSimulacro) async {
    final simulacros = await getSimulacros();
    final index = simulacros.indexWhere((s) => s.id == simulacroId);
    if (index != -1) {
      simulacros[index] = updatedSimulacro;
      await saveSimulacros(simulacros);
    }
  }

  static Future<void> deleteQuestion(String questionId) async {
    final questions = await getQuestions();
    questions.removeWhere((q) => q['id'] == questionId);
    await saveQuestions(questions);
  }

  static Future<void> deleteSimulacro(String simulacroId) async {
    final simulacros = await getSimulacros();
    simulacros.removeWhere((s) => s.id == simulacroId);
    await saveSimulacros(simulacros);
  }

  // Datos iniciales
  static List<Simulacro> _getInitialSimulacros() {
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
        ),
        estadisticas: const EstadisticasSimulacro(
          intentos: 0,
          mejorPuntuacion: null,
          promedio: null,
        ),
      ),
    ];
  }

  static List<Map<String, dynamic>> _getInitialQuestions() {
    return [
      {
        'id': 'preg_001',
        'question': '¿Cuál es la capital de Colombia?',
        'area': 'Ciencias Sociales',
        'category': 'Sociales',
        'difficulty': 'Fácil',
        'tema': 'Geografía',
        'nivel': 'Bajo',
        'tipo': 'UNICA_OPCION',
        'competencia': 'Comprensión geográfica',
        'retroalimentacion':
            'Bogotá es la capital y ciudad más grande de Colombia. Está ubicada en el centro del país en la región andina, a una altitud de 2.640 metros sobre el nivel del mar.',
        'options': [
          {'id': 'opt_001', 'text': 'A) Bogotá', 'correct': true},
          {'id': 'opt_002', 'text': 'B) Medellín', 'correct': false},
          {'id': 'opt_003', 'text': 'C) Cali', 'correct': false},
          {'id': 'opt_004', 'text': 'D) Barranquilla', 'correct': false},
        ],
      },
      {
        'id': 'preg_002',
        'question': 'Resuelve la ecuación: 2x + 5 = 15',
        'area': 'Matemáticas',
        'category': 'Matemáticas',
        'difficulty': 'Media',
        'tema': 'Álgebra',
        'nivel': 'Medio',
        'tipo': 'UNICA_OPCION',
        'competencia': 'Razonamiento cuantitativo',
        'retroalimentacion':
            'Para resolver, suma 5 a ambos lados: 2x = 20. Luego divide entre 2: x = 10.',
        'options': [
          {'id': 'opt_005', 'text': 'A) 5', 'correct': false},
          {'id': 'opt_006', 'text': 'B) 10', 'correct': true},
          {'id': 'opt_007', 'text': 'C) 15', 'correct': false},
          {'id': 'opt_008', 'text': 'D) 20', 'correct': false},
        ],
      },
      {
        'id': 'preg_003',
        'question': 'Identifica el sujeto en la oración: "El estudiante estudia matemáticas"',
        'area': 'Lenguaje',
        'category': 'Lenguaje',
        'difficulty': 'Media',
        'tema': 'Gramática',
        'nivel': 'Medio',
        'tipo': 'UNICA_OPCION',
        'competencia': 'Comprensión lectora',
        'retroalimentacion':
            'El sujeto es "El estudiante" porque es quien realiza la acción del verbo "estudia".',
        'options': [
          {'id': 'opt_009', 'text': 'A) El estudiante', 'correct': true},
          {'id': 'opt_010', 'text': 'B) estudia', 'correct': false},
          {'id': 'opt_011', 'text': 'C) matemáticas', 'correct': false},
          {'id': 'opt_012', 'text': 'D) la oración', 'correct': false},
        ],
      },
      {
        'id': 'preg_004',
        'question': '¿Qué es la fotosíntesis?',
        'area': 'Ciencias Naturales',
        'category': 'Naturales',
        'difficulty': 'Fácil',
        'tema': 'Biología',
        'nivel': 'Bajo',
        'tipo': 'UNICA_OPCION',
        'competencia': 'Uso comprensivo del conocimiento científico',
        'retroalimentacion':
            'La fotosíntesis es el proceso biológico donde las plantas convierten la luz solar, agua y dióxido de carbono en glucosa y oxígeno.',
        'options': [
          {'id': 'opt_013', 'text': 'A) Un proceso químico', 'correct': false},
          {'id': 'opt_014', 'text': 'B) Un proceso físico', 'correct': false},
          {'id': 'opt_015', 'text': 'C) Un proceso biológico donde las plantas producen energía', 'correct': true},
          {'id': 'opt_016', 'text': 'D) Un proceso de respiración', 'correct': false},
        ],
      },
      {
        'id': 'preg_005',
        'question': '¿Cuál es la fórmula del área de un círculo?',
        'area': 'Matemáticas',
        'category': 'Matemáticas',
        'difficulty': 'Fácil',
        'tema': 'Geometría',
        'nivel': 'Bajo',
        'tipo': 'UNICA_OPCION',
        'competencia': 'Razonamiento cuantitativo',
        'retroalimentacion':
            'El área de un círculo se calcula con la fórmula A = πr², donde r es el radio del círculo.',
        'options': [
          {'id': 'opt_017', 'text': 'A) πr²', 'correct': true},
          {'id': 'opt_018', 'text': 'B) 2πr', 'correct': false},
          {'id': 'opt_019', 'text': 'C) πd', 'correct': false},
          {'id': 'opt_020', 'text': 'D) r²', 'correct': false},
        ],
      },
      {
        'id': 'preg_006',
        'question': '¿En qué año se independizó Colombia?',
        'area': 'Ciencias Sociales',
        'category': 'Sociales',
        'difficulty': 'Media',
        'tema': 'Historia',
        'nivel': 'Medio',
        'tipo': 'UNICA_OPCION',
        'competencia': 'Comprensión histórica',
        'retroalimentacion':
            'Colombia se independizó de España el 20 de julio de 1810, aunque la independencia definitiva se logró en 1819.',
        'options': [
          {'id': 'opt_021', 'text': 'A) 1810', 'correct': true},
          {'id': 'opt_022', 'text': 'B) 1821', 'correct': false},
          {'id': 'opt_023', 'text': 'C) 1808', 'correct': false},
          {'id': 'opt_024', 'text': 'D) 1815', 'correct': false},
        ],
      },
    ];
  }
}

