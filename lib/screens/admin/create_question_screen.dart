import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:preparate_icfes_seminario/config/theme/app_colors.dart';
import 'package:preparate_icfes_seminario/services/data_persistence_service.dart';

class CreateQuestionScreen extends StatefulWidget {
  final String? questionId;
  
  const CreateQuestionScreen({super.key, this.questionId});

  @override
  State<CreateQuestionScreen> createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _enunciadoController = TextEditingController();
  final _explicacionController = TextEditingController();
  String _selectedArea = 'Ciencias Sociales';
  String _selectedNivel = 'Medio';
  String _selectedTema = 'General';
  final List<_OptionData> _options = [
    _OptionData(label: 'A', text: '', isCorrect: false),
    _OptionData(label: 'B', text: '', isCorrect: false),
    _OptionData(label: 'C', text: '', isCorrect: false),
    _OptionData(label: 'D', text: '', isCorrect: false),
  ];
  bool _isSaving = false;
  bool _isLoading = false;
  bool get _isEditMode => widget.questionId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadQuestionData();
    }
  }

  Future<void> _loadQuestionData() async {
    setState(() => _isLoading = true);
    try {
      final questions = await DataPersistenceService.getQuestions();
      final question = questions.firstWhere(
        (q) => q['id'] == widget.questionId,
        orElse: () => throw Exception('Pregunta no encontrada'),
      );

      setState(() {
        _enunciadoController.text = question['question'] as String? ?? '';
        _explicacionController.text = question['retroalimentacion'] as String? ?? '';
        _selectedArea = question['area'] as String? ?? 'Ciencias Sociales';
        _selectedNivel = question['nivel'] as String? ?? 'Medio';
        _selectedTema = question['tema'] as String? ?? 'General';
        
        // Reconstruir opciones
        _options.clear();
        final optionsList = question['options'] as List<dynamic>? ?? [];
        for (var i = 0; i < optionsList.length; i++) {
          final opt = optionsList[i] as Map<String, dynamic>;
          final label = String.fromCharCode('A'.codeUnitAt(0) + i);
          // Remover el prefijo "A) ", "B) ", etc. del texto
          var text = opt['text'] as String? ?? '';
          if (text.length > 3 && text[1] == ')') {
            text = text.substring(3).trim();
          }
          _options.add(_OptionData(
            label: label,
            text: text,
            isCorrect: opt['correct'] == true,
          ));
        }
        
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar pregunta: $e'),
            backgroundColor: Colors.red,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  void dispose() {
    _enunciadoController.dispose();
    _explicacionController.dispose();
    for (var option in _options) {
      option.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar que haya al menos una opción correcta
    if (!_options.any((opt) => opt.isCorrect)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes marcar al menos una opción como correcta')),
      );
      return;
    }

    // Validar que todas las opciones tengan texto
    if (_options.any((opt) => opt.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todas las opciones deben tener texto')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Mapear área a category
      final categoryMap = {
        'Ciencias Sociales': 'Sociales',
        'Matemáticas': 'Matemáticas',
        'Inglés': 'Lenguaje',
        'Ciencias Naturales': 'Naturales',
        'Lenguaje': 'Lenguaje',
      };

      // Crear o actualizar pregunta
      final question = {
        'id': _isEditMode ? widget.questionId! : 'preg_${DateTime.now().millisecondsSinceEpoch}',
        'question': _enunciadoController.text.trim(),
        'area': _selectedArea,
        'category': categoryMap[_selectedArea] ?? 'General',
        'difficulty': _selectedNivel == 'Bajo' ? 'Fácil' : _selectedNivel == 'Medio' ? 'Media' : 'Difícil',
        'tema': _selectedTema,
        'nivel': _selectedNivel,
        'tipo': 'UNICA_OPCION',
        'competencia': 'Comprensión',
        'retroalimentacion': _explicacionController.text.trim(),
        'options': _options.map((opt) {
          return {
            'id': 'opt_${DateTime.now().millisecondsSinceEpoch}_${opt.label}',
            'text': '${opt.label}) ${opt.text.trim()}',
            'correct': opt.isCorrect,
          };
        }).toList(),
      };

      if (_isEditMode) {
        await DataPersistenceService.updateQuestion(widget.questionId!, question);
      } else {
        await DataPersistenceService.addQuestion(question);
      }

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Pregunta actualizada exitosamente' : 'Pregunta guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addOption() {
    setState(() {
      final nextLabel = String.fromCharCode('A'.codeUnitAt(0) + _options.length);
      _options.add(_OptionData(
        label: nextLabel,
        text: '',
        isCorrect: false,
      ));
    });
  }

  void _removeOption(int index) {
    if (_options.length > 2) {
      setState(() {
        _options.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes tener al menos 2 opciones')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _isEditMode ? 'Editar pregunta' : 'Crear pregunta',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Crea una nueva pregunta para el banco',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Información de la pregunta',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _Label(text: 'Área de conocimiento'),
                            _Dropdown(
                              value: _selectedArea,
                              items: const [
                                'Ciencias Sociales',
                                'Matemáticas',
                                'Inglés',
                                'Ciencias Naturales',
                                'Lenguaje'
                              ],
                              onChanged: (value) =>
                                  setState(() => _selectedArea = value!),
                            ),
                            const SizedBox(height: 16),
                            _Label(text: 'Tema'),
                            TextFormField(
                              controller: TextEditingController(text: _selectedTema),
                              onChanged: (value) => _selectedTema = value,
                              decoration: InputDecoration(
                                hintText: 'Ej: Álgebra, Historia, etc.',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _Label(text: 'Nivel'),
                            _Dropdown(
                              value: _selectedNivel,
                              items: const ['Bajo', 'Medio', 'Alto'],
                              onChanged: (value) =>
                                  setState(() => _selectedNivel = value!),
                            ),
                            const SizedBox(height: 16),
                            _Label(text: 'Enunciado de la pregunta'),
                            TextFormField(
                              controller: _enunciadoController,
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Campo requerido' : null,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: '¿Cuál es la capital de Colombia?',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _Label(text: 'Explicación de la respuesta'),
                            TextFormField(
                              controller: _explicacionController,
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Campo requerido' : null,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Explica por qué esta es la respuesta correcta...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Opciones de respuesta',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _addOption,
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Agregar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF81C784),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ..._options.asMap().entries.map((entry) {
                              final index = entry.key;
                              final option = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _OptionItem(
                                  label: option.label,
                                  controller: option.controller,
                                  isCorrect: option.isCorrect,
                                  onCorrectChanged: (value) {
                                    setState(() {
                                      // Solo una opción puede ser correcta
                                      for (var opt in _options) {
                                        opt.isCorrect = false;
                                      }
                                      option.isCorrect = value;
                                    });
                                  },
                                  onRemove: () => _removeOption(index),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  _isEditMode ? 'Actualizar Pregunta' : 'Guardar Pregunta',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
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

class _OptionData {
  final String label;
  final TextEditingController controller;
  bool isCorrect;

  String get text => controller.text;

  _OptionData({
    required this.label,
    required String text,
    required this.isCorrect,
  }) : controller = TextEditingController(text: text);
}

class _Label extends StatelessWidget {
  final String text;

  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryText,
        ),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isCorrect;
  final ValueChanged<bool> onCorrectChanged;
  final VoidCallback onRemove;

  const _OptionItem({
    required this.label,
    required this.controller,
    required this.isCorrect,
    required this.onCorrectChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => onCorrectChanged(!isCorrect),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCorrect ? const Color(0xFF27AE60) : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: isCorrect
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Opción $label',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            if (isCorrect) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Correcta',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const Spacer(),
            IconButton(
              onPressed: onRemove,
              icon: Icon(Icons.close, color: Colors.red[200], size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Campo requerido' : null,
          decoration: InputDecoration(
            hintText: 'Texto de la opción...',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
