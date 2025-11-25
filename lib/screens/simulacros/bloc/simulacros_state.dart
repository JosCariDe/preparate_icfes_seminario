part of 'simulacros_bloc.dart';

enum SimulacrosStatus { initial, loading, success, failure }

class SimulacrosState extends Equatable {
  final SimulacrosStatus status;
  final List<Simulacro> simulacros;
  final String? errorMessage;

  const SimulacrosState({
    this.status = SimulacrosStatus.initial,
    this.simulacros = const [],
    this.errorMessage,
  });

  SimulacrosState copyWith({
    SimulacrosStatus? status,
    List<Simulacro>? simulacros,
    String? errorMessage,
  }) {
    return SimulacrosState(
      status: status ?? this.status,
      simulacros: simulacros ?? this.simulacros,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, simulacros, errorMessage];
}
