import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../models/simulacro_model.dart';
import '../../../repositories/simulacro_repository.dart';

part 'simulacros_event.dart';
part 'simulacros_state.dart';

class SimulacrosBloc extends Bloc<SimulacrosEvent, SimulacrosState> {
  final SimulacroRepository _simulacroRepository;

  SimulacrosBloc({required SimulacroRepository simulacroRepository})
      : _simulacroRepository = simulacroRepository,
        super(const SimulacrosState()) {
    on<SimulacrosRequested>(_onSimulacrosRequested);
  }

  Future<void> _onSimulacrosRequested(
      SimulacrosRequested event, Emitter<SimulacrosState> emit) async {
    emit(state.copyWith(status: SimulacrosStatus.loading));

    try {
      final simulacros = await _simulacroRepository.getSimulacros();
      emit(state.copyWith(
        status: SimulacrosStatus.success,
        simulacros: simulacros,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SimulacrosStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
