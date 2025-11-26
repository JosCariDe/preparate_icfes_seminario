import 'package:equatable/equatable.dart';

class ExamResult extends Equatable {
  final double totalScore;
  final int correctAnswers;
  final int incorrectAnswers;
  final int totalQuestions;
  final double percentage;
  final int timeSpentSeconds;

  const ExamResult({
    required this.totalScore,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.totalQuestions,
    required this.percentage,
    required this.timeSpentSeconds,
  });

  @override
  List<Object?> get props => [
        totalScore,
        correctAnswers,
        incorrectAnswers,
        totalQuestions,
        percentage,
        timeSpentSeconds,
      ];
}
