import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:preparate_icfes_seminario/models/exam_result_model.dart';
import 'package:preparate_icfes_seminario/models/question_model.dart';
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
    
    // Calculate results
    int correctAnswers = 0;
    int incorrectAnswers = 0;
    
    if (state.simulacro?.preguntas != null) {
      for (final question in state.simulacro!.preguntas!) {
        final selectedOptionId = state.answers[question.id];
        if (selectedOptionId != null) {
          final selectedOption = question.opciones.firstWhere(
            (opt) => opt.id == selectedOptionId,
            orElse: () => const Opcion(id: '', texto: '', correcta: false),
          );
          
          if (selectedOption.correcta) {
            correctAnswers++;
          } else {
            incorrectAnswers++;
          }
        } else {
          // Unanswered counts as incorrect or just unanswered? 
          // Usually incorrect in scoring.
          incorrectAnswers++;
        }
      }
    }

    final totalQuestions = state.simulacro?.preguntas?.length ?? 0;
    final totalScore = (correctAnswers / (totalQuestions > 0 ? totalQuestions : 1)) * 500; // Scale to 500
    final percentage = (correctAnswers / (totalQuestions > 0 ? totalQuestions : 1)) * 100;
    final timeSpent = (state.simulacro?.duracionMinutos ?? 0) * 60 - state.timeRemaining;

    final result = ExamResult(
      totalScore: totalScore,
      correctAnswers: correctAnswers,
      incorrectAnswers: incorrectAnswers,
      totalQuestions: totalQuestions,
      percentage: percentage,
      timeSpentSeconds: timeSpent,
    );

    emit(state.copyWith(
      status: ExamStatus.submitted,
      result: result,
    ));
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
