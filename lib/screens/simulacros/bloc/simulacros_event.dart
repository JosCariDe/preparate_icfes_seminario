part of 'simulacros_bloc.dart';

abstract class SimulacrosEvent extends Equatable {
  const SimulacrosEvent();

  @override
  List<Object> get props => [];
}

class SimulacrosRequested extends SimulacrosEvent {
  const SimulacrosRequested();
}
