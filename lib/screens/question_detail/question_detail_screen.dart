import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:preparate_icfes_seminario/config/theme/app_colors.dart';
import 'package:preparate_icfes_seminario/services/data_persistence_service.dart';

class QuestionDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? questionData;
  final String? questionId;

  const QuestionDetailScreen({
    super.key,
    this.questionData,
    this.questionId,
  });

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  String? _selectedOptionId;
  bool _showFeedback = false;
  bool _isCorrect = false;
  Map<String, dynamic>? _questionData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  Future<void> _loadQuestion() async {
    if (widget.questionData != null) {
      setState(() {
        _questionData = widget.questionData!;
        _isLoading = false;
      });
      return;
    }

    if (widget.questionId != null) {
      try {
        final questions = await DataPersistenceService.getQuestions();
        final question = questions.firstWhere(
          (q) => q['id'] == widget.questionId,
          orElse: () => _getDefaultQuestion(),
        );
        setState(() {
          _questionData = question;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _questionData = _getDefaultQuestion();
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _questionData = _getDefaultQuestion();
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _getDefaultQuestion() {
    return {
      'id': 'preg_001',
      'question': '¿Cuál es la capital de Colombia?',
      'area': 'Ciencias Sociales',
      'options': [
        {'id': 'opt_001', 'text': 'A) Bogotá', 'correct': true},
        {'id': 'opt_002', 'text': 'B) Medellín', 'correct': false},
        {'id': 'opt_003', 'text': 'C) Cali', 'correct': false},
        {'id': 'opt_004', 'text': 'D) Barranquilla', 'correct': false},
      ],
      'retroalimentacion':
          'Bogotá es la capital y ciudad más grande de Colombia. Está ubicada en el centro del país en la región andina, a una altitud de 2.640 metros sobre el nivel del mar.',
    };
  }

  void _selectOption(String optionId) {
    if (_showFeedback || _questionData == null) return; // No permitir cambiar después de responder

    setState(() {
      _selectedOptionId = optionId;
    });
  }

  void _submitAnswer() {
    if (_selectedOptionId == null || _questionData == null) return;

    final selectedOption = (_questionData!['options'] as List).firstWhere(
      (opt) => opt['id'] == _selectedOptionId,
    );

    setState(() {
      _isCorrect = selectedOption['correct'] == true;
      _showFeedback = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _questionData == null) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final question = _questionData!['question'] as String? ?? 'Pregunta no disponible';
    final area = _questionData!['area'] as String? ?? 'General';
    final options = _questionData!['options'] as List? ?? [];
    final explanation = _questionData!['retroalimentacion'] as String? ?? 
                       _questionData!['explanation'] as String? ?? 
                       'Sin explicación disponible';

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE0E0E0)),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () => context.pop(),
                    color: Colors.black87,
                  ),
                  const Text(
                    'Detalle de pregunta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Contenido
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tag de área
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        area,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Pregunta
                    Text(
                      question,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Opciones
                    ...options.map((option) {
                      final optionId = option['id'] as String;
                      final optionText = option['text'] as String;
                      final isCorrect = option['correct'] == true;
                      final isSelected = _selectedOptionId == optionId;

                      Color? borderColor;
                      Color? backgroundColor;
                      if (_showFeedback) {
                        if (isCorrect) {
                          borderColor = AppColors.primary;
                          backgroundColor = AppColors.primary.withOpacity(0.1);
                        } else if (isSelected && !isCorrect) {
                          borderColor = Colors.red;
                          backgroundColor = Colors.red.withOpacity(0.1);
                        }
                      } else if (isSelected) {
                        borderColor = AppColors.primary;
                        backgroundColor = AppColors.primary.withOpacity(0.1);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => _selectOption(optionId),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: backgroundColor ?? Colors.white,
                              border: Border.all(
                                color: borderColor ?? Colors.grey[300]!,
                                width: isSelected || (isCorrect && _showFeedback) ? 2 : 1,
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
                                      color: borderColor ?? Colors.grey[400]!,
                                      width: 2,
                                    ),
                                    color: isSelected || (isCorrect && _showFeedback)
                                        ? borderColor
                                        : null,
                                  ),
                                  child: isSelected || (isCorrect && _showFeedback)
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
                                    optionText,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: borderColor ?? Colors.black87,
                                      fontWeight: isSelected ||
                                              (isCorrect && _showFeedback)
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
                    // Retroalimentación
                    if (_showFeedback) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isCorrect
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isCorrect
                                ? Colors.green.withOpacity(0.3)
                                : Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: _isCorrect ? Colors.green[700] : Colors.red[700],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isCorrect ? '¡Correcto!' : 'Incorrecto',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _isCorrect
                                          ? Colors.green[700]
                                          : Colors.red[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    explanation,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Botón
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE0E0E0)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showFeedback
                      ? () => context.pop()
                      : _selectedOptionId != null
                          ? _submitAnswer
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: Text(
                    _showFeedback ? 'Siguiente pregunta' : 'Verificar respuesta',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
