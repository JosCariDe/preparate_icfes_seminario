import 'package:equatable/equatable.dart';
import 'question_model.dart';

class ProgresoSimulacro extends Equatable {
  final bool completado;
  final int preguntasRespondidas;
  final double porcentajeAvance;
  final DateTime? ultimoIntento;

  const ProgresoSimulacro({
    required this.completado,
    required this.preguntasRespondidas,
    required this.porcentajeAvance,
    this.ultimoIntento,
  });

  factory ProgresoSimulacro.fromJson(Map<String, dynamic> json) {
    return ProgresoSimulacro(
      completado: json['completado'] ?? false,
      preguntasRespondidas: json['preguntasRespondidas'] ?? 0,
      porcentajeAvance: (json['porcentajeAvance'] ?? 0).toDouble(),
      ultimoIntento: json['ultimoIntento'] != null
          ? DateTime.parse(json['ultimoIntento'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completado': completado,
      'preguntasRespondidas': preguntasRespondidas,
      'porcentajeAvance': porcentajeAvance,
      'ultimoIntento': ultimoIntento?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props =>
      [completado, preguntasRespondidas, porcentajeAvance, ultimoIntento];
}

class EstadisticasSimulacro extends Equatable {
  final int intentos;
  final double? mejorPuntuacion;
  final double? promedio;

  const EstadisticasSimulacro({
    required this.intentos,
    this.mejorPuntuacion,
    this.promedio,
  });

  factory EstadisticasSimulacro.fromJson(Map<String, dynamic> json) {
    return EstadisticasSimulacro(
      intentos: json['intentos'] ?? 0,
      mejorPuntuacion: json['mejorPuntuacion']?.toDouble(),
      promedio: json['promedio']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intentos': intentos,
      'mejorPuntuacion': mejorPuntuacion,
      'promedio': promedio,
    };
  }

  @override
  List<Object?> get props => [intentos, mejorPuntuacion, promedio];
}

class Simulacro extends Equatable {
  final String id;
  final String titulo;
  final String descripcion;
  final String area;
  final String nivel;
  final int duracionMinutos;
  final int totalPreguntas;
  final ProgresoSimulacro? progreso;
  final EstadisticasSimulacro? estadisticas;
  final List<Pregunta>? preguntas;
  final String? instrucciones;

  const Simulacro({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.area,
    required this.nivel,
    required this.duracionMinutos,
    required this.totalPreguntas,
    this.progreso,
    this.estadisticas,
    this.preguntas,
    this.instrucciones,
  });

  factory Simulacro.fromJson(Map<String, dynamic> json) {
    return Simulacro(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      area: json['area'] ?? '',
      nivel: json['nivel'] ?? '',
      duracionMinutos: json['duracionMinutos'] ?? 0,
      totalPreguntas: json['totalPreguntas'] ?? 0,
      progreso: json['progreso'] != null
          ? ProgresoSimulacro.fromJson(json['progreso'])
          : null,
      estadisticas: json['estadisticas'] != null
          ? EstadisticasSimulacro.fromJson(json['estadisticas'])
          : null,
      preguntas: (json['preguntas'] as List<dynamic>?)
          ?.map((e) => Pregunta.fromJson(e))
          .toList(),
      instrucciones: json['instrucciones'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'area': area,
      'nivel': nivel,
      'duracionMinutos': duracionMinutos,
      'totalPreguntas': totalPreguntas,
      'progreso': progreso?.toJson(),
      'estadisticas': estadisticas?.toJson(),
      'preguntas': preguntas?.map((e) => e.toJson()).toList(),
      'instrucciones': instrucciones,
    };
  }

  @override
  List<Object?> get props => [
        id,
        titulo,
        descripcion,
        area,
        nivel,
        duracionMinutos,
        totalPreguntas,
        progreso,
        estadisticas,
        preguntas,
        instrucciones,
      ];
}
