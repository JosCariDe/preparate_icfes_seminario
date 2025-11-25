import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../models/simulacro_model.dart';
import '../../../repositories/simulacro_repository.dart';

part 'exam_event.dart';
part 'exam_state.dart';

class ExamBloc extends Bloc<ExamEvent, ExamState> {
  final SimulacroRepository _simulacroRepository;
  StreamSubscription<int>? _tickerSubscription;

  ExamBloc({required SimulacroRepository simulacroRepository})
      : _simulacroRepository = simulacroRepository,
        super(const ExamState()) {
    on<ExamStarted>(_onExamStarted);
    on<ExamQuestionChanged>(_onQuestionChanged);
    on<ExamAnswerSelected>(_onAnswerSelected);
    on<ExamSubmitted>(_onSubmitted);
    on<ExamTimerTicked>(_onTimerTicked);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  Future<void> _onExamStarted(
      ExamStarted event, Emitter<ExamState> emit) async {
    emit(state.copyWith(status: ExamStatus.loading));

    try {
      final simulacro =
          await _simulacroRepository.getSimulacroById(event.simulacroId);
      
      _startTimer(simulacro.duracionMinutos * 60);

      emit(state.copyWith(
        status: ExamStatus.success,
        simulacro: simulacro,
        timeRemaining: simulacro.duracionMinutos * 60,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ExamStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onQuestionChanged(
      ExamQuestionChanged event, Emitter<ExamState> emit) {
    emit(state.copyWith(currentQuestionIndex: event.questionIndex));
  }

  void _onAnswerSelected(ExamAnswerSelected event, Emitter<ExamState> emit) {
    final newAnswers = Map<String, String>.from(state.answers);
    newAnswers[event.questionId] = event.optionId;
    emit(state.copyWith(answers: newAnswers));
  }

  Future<void> _onSubmitted(
      ExamSubmitted event, Emitter<ExamState> emit) async {
    _tickerSubscription?.cancel();
    emit(state.copyWith(status: ExamStatus.submitted));
    // Here we would send the answers to the backend
  }

  void _onTimerTicked(ExamTimerTicked event, Emitter<ExamState> emit) {
    emit(state.copyWith(timeRemaining: event.duration));
  }

  void _startTimer(int duration) {
    _tickerSubscription?.cancel();
    _tickerSubscription = Stream.periodic(
            const Duration(seconds: 1), (x) => duration - x - 1)
        .take(duration)
        .listen((duration) => add(ExamTimerTicked(duration: duration)));
  }
}
