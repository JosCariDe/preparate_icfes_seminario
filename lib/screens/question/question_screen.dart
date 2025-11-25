import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:preparate_icfes_seminario/config/theme/app_colors.dart';
import 'package:preparate_icfes_seminario/repositories/simulacro_repository.dart';
import 'bloc/exam_bloc.dart';

class QuestionScreen extends StatelessWidget {
  const QuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExamBloc(
        simulacroRepository: MockSimulacroRepository(),
      )..add(const ExamStarted(simulacroId: 'sim_001')),
      child: const _QuestionView(),
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExamBloc, ExamState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == ExamStatus.submitted) {
          context.go('/results');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: SafeArea(
          child: BlocBuilder<ExamBloc, ExamState>(
            builder: (context, state) {
              if (state.status == ExamStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state.status == ExamStatus.failure) {
                return Center(
                    child: Text(state.errorMessage ?? 'Error al cargar'));
              } else if (state.status == ExamStatus.success) {
                final question =
                    state.simulacro!.preguntas![state.currentQuestionIndex];
                final totalQuestions = state.simulacro!.preguntas!.length;

                return Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              /*IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => context.pop(),
                              ),*/
                              const SizedBox(width: 8),
                              Text(
                                'Pregunta ${state.currentQuestionIndex + 1}/$totalQuestions',
                                style: const TextStyle( 
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTime(state.timeRemaining),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Question Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question.enunciado,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ...question.opciones.map((option) {
                              final isSelected =
                                  state.answers[question.id] == option.id;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: InkWell(
                                  onTap: () {
                                    context.read<ExamBloc>().add(
                                          ExamAnswerSelected(
                                            questionId: question.id,
                                            optionId: option.id,
                                          ),
                                        );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary.withOpacity(0.1)
                                          : Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.grey[300]!,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : Colors.grey[400]!,
                                              width: 2,
                                            ),
                                            color: isSelected
                                                ? AppColors.primary
                                                : null,
                                          ),
                                          child: isSelected
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 16,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            option.texto,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : Colors.black87,
                                              fontWeight: isSelected
                                                  ? FontWeight.w500
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    // Navigation Buttons
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (state.currentQuestionIndex > 0)
                            TextButton.icon(
                              onPressed: () {
                                context.read<ExamBloc>().add(
                                      ExamQuestionChanged(
                                          state.currentQuestionIndex - 1),
                                    );
                              },
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Anterior'),
                            )
                          else
                            const SizedBox.shrink(),
                          if (state.currentQuestionIndex < totalQuestions - 1)
                            ElevatedButton.icon(
                              onPressed: () {
                                context.read<ExamBloc>().add(
                                      ExamQuestionChanged(
                                          state.currentQuestionIndex + 1),
                                    );
                              },
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Siguiente'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                            )
                          else
                            ElevatedButton.icon(
                              onPressed: () {
                                context
                                    .read<ExamBloc>()
                                    .add(const ExamSubmitted());
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Finalizar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
