part of 'exam_bloc.dart';

enum ExamStatus { initial, loading, success, failure, submitted }

class ExamState extends Equatable {
  final ExamStatus status;
  final Simulacro? simulacro;
  final int currentQuestionIndex;
  final Map<String, String> answers; // questionId -> optionId
  final int timeRemaining; // in seconds
  final String? errorMessage;

  const ExamState({
    this.status = ExamStatus.initial,
    this.simulacro,
    this.currentQuestionIndex = 0,
    this.answers = const {},
    this.timeRemaining = 0,
    this.errorMessage,
  });

  ExamState copyWith({
    ExamStatus? status,
    Simulacro? simulacro,
    int? currentQuestionIndex,
    Map<String, String>? answers,
    int? timeRemaining,
    String? errorMessage,
  }) {
    return ExamState(
      status: status ?? this.status,
      simulacro: simulacro ?? this.simulacro,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        simulacro,
        currentQuestionIndex,
        answers,
        timeRemaining,
        errorMessage,
      ];
}
