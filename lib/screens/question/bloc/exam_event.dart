part of 'exam_bloc.dart';

abstract class ExamEvent extends Equatable {
  const ExamEvent();

  @override
  List<Object> get props => [];
}

class ExamStarted extends ExamEvent {
  final String simulacroId;

  const ExamStarted({required this.simulacroId});

  @override
  List<Object> get props => [simulacroId];
}

class ExamQuestionChanged extends ExamEvent {
  final int questionIndex;

  const ExamQuestionChanged(this.questionIndex);

  @override
  List<Object> get props => [questionIndex];
}

class ExamAnswerSelected extends ExamEvent {
  final String questionId;
  final String optionId;

  const ExamAnswerSelected({required this.questionId, required this.optionId});

  @override
  List<Object> get props => [questionId, optionId];
}

class ExamSubmitted extends ExamEvent {
  const ExamSubmitted();
}

class ExamTimerTicked extends ExamEvent {
  final int duration;

  const ExamTimerTicked({required this.duration});

  @override
  List<Object> get props => [duration];
}
