import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String rol;
  final String? avatar;
  final String? token;
  final String? refreshToken;

  const User({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.rol,
    this.avatar,
    this.token,
    this.refreshToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      email: json['email'] ?? '',
      rol: json['rol'] ?? 'ESTUDIANTE',
      avatar: json['avatar'],
      token: json['token'],
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'rol': rol,
      'avatar': avatar,
      'token': token,
      'refreshToken': refreshToken,
    };
  }

  @override
  List<Object?> get props => [id, nombre, apellido, email, rol, avatar, token, refreshToken];
}
