import 'package:equatable/equatable.dart';

class Opcion extends Equatable {
  final String id;
  final String texto;
  final bool correcta;

  const Opcion({
    required this.id,
    required this.texto,
    required this.correcta,
  });

  factory Opcion.fromJson(Map<String, dynamic> json) {
    return Opcion(
      id: json['id'] ?? '',
      texto: json['texto'] ?? '',
      correcta: json['correcta'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'texto': texto,
      'correcta': correcta,
    };
  }

  @override
  List<Object?> get props => [id, texto, correcta];
}

class Pregunta extends Equatable {
  final String id;
  final String enunciado;
  final String area;
  final String tema;
  final String nivel;
  final String tipo;
  final String? competencia;
  final String? retroalimentacion;
  final List<Opcion> opciones;

  const Pregunta({
    required this.id,
    required this.enunciado,
    required this.area,
    required this.tema,
    required this.nivel,
    required this.tipo,
    this.competencia,
    this.retroalimentacion,
    required this.opciones,
  });

  factory Pregunta.fromJson(Map<String, dynamic> json) {
    return Pregunta(
      id: json['id'] ?? '',
      enunciado: json['enunciado'] ?? '',
      area: json['area'] ?? '',
      tema: json['tema'] ?? '',
      nivel: json['nivel'] ?? '',
      tipo: json['tipo'] ?? '',
      competencia: json['competencia'],
      retroalimentacion: json['retroalimentacion'],
      opciones: (json['opciones'] as List<dynamic>?)
              ?.map((e) => Opcion.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enunciado': enunciado,
      'area': area,
      'tema': tema,
      'nivel': nivel,
      'tipo': tipo,
      'competencia': competencia,
      'retroalimentacion': retroalimentacion,
      'opciones': opciones.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        enunciado,
        area,
        tema,
        nivel,
        tipo,
        competencia,
        retroalimentacion,
        opciones,
      ];
}
