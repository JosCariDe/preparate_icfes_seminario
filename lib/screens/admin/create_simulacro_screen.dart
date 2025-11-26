import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:preparate_icfes_seminario/config/theme/app_colors.dart';
import 'package:preparate_icfes_seminario/models/simulacro_model.dart';
import 'package:preparate_icfes_seminario/models/question_model.dart';
import 'package:preparate_icfes_seminario/services/data_persistence_service.dart';

class CreateSimulacroScreen extends StatefulWidget {
  const CreateSimulacroScreen({super.key});

  @override
  State<CreateSimulacroScreen> createState() => _CreateSimulacroScreenState();
}

class _CreateSimulacroScreenState extends State<CreateSimulacroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _duracionController = TextEditingController();
  String _selectedArea = 'Matemáticas';
  String _selectedNivel = 'Medio';
  final List<String> _selectedQuestionIds = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _duracionController.dispose();
    super.dispose();
  }

  Future<void> _saveSimulacro() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedQuestionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes agregar al menos una pregunta')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Obtener preguntas seleccionadas
      final allQuestions = await DataPersistenceService.getQuestions();
      final selectedQuestions = allQuestions
          .where((q) => _selectedQuestionIds.contains(q['id']))
          .toList();

      // Crear nuevo simulacro
      final newSimulacro = Simulacro(
        id: 'sim_${DateTime.now().millisecondsSinceEpoch}',
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        area: _selectedArea,
        nivel: _selectedNivel,
        duracionMinutos: int.tryParse(_duracionController.text) ?? 60,
        totalPreguntas: selectedQuestions.length,
        instrucciones: 'Lee cuidadosamente cada pregunta antes de responder.',
        preguntas: selectedQuestions.map((q) => _mapToPregunta(q)).toList(),
      );

      await DataPersistenceService.addSimulacro(newSimulacro);

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Simulacro guardado exitosamente'),
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

  Pregunta _mapToPregunta(Map<String, dynamic> questionData) {
    final options = (questionData['options'] as List)
        .map((opt) => Opcion(
              id: opt['id'] as String,
              texto: opt['text'] as String,
              correcta: opt['correct'] == true,
            ))
        .toList();

    return Pregunta(
      id: questionData['id'] as String,
      enunciado: questionData['question'] as String,
      area: questionData['area'] as String,
      tema: questionData['tema'] as String? ?? 'General',
      nivel: questionData['nivel'] as String? ?? 'Medio',
      tipo: questionData['tipo'] as String? ?? 'UNICA_OPCION',
      competencia: questionData['competencia'] as String?,
      retroalimentacion: questionData['retroalimentacion'] as String?,
      opciones: options,
    );
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
                  const Text(
                    'Crear simulacro',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Configura tu simulacro personalizado',
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
                              'Información del simulacro',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _Label(text: 'Nombre del simulacro'),
                            TextFormField(
                              controller: _tituloController,
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Campo requerido' : null,
                              decoration: InputDecoration(
                                hintText: 'Ej: Simulacro Matemáticas Avanzado',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _Label(text: 'Área principal'),
                            _Dropdown(
                              value: _selectedArea,
                              items: const [
                                'Matemáticas',
                                'Inglés',
                                'Ciencias Naturales',
                                'Ciencias Sociales',
                                'Lenguaje'
                              ],
                              onChanged: (value) =>
                                  setState(() => _selectedArea = value!),
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
                            _Label(text: 'Descripción'),
                            TextFormField(
                              controller: _descripcionController,
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Campo requerido' : null,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Describe brevemente el contenido del simulacro...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _Label(text: 'Duración (min)'),
                                      TextFormField(
                                        controller: _duracionController,
                                        keyboardType: TextInputType.number,
                                        validator: (value) =>
                                            value?.isEmpty ?? true ? 'Campo requerido' : null,
                                        decoration: InputDecoration(
                                          hintText: '60',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                                  'Preguntas del simulacro',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _showQuestionSelector(),
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
                            if (_selectedQuestionIds.isEmpty)
                              const Text(
                                'No hay preguntas seleccionadas',
                                style: TextStyle(color: Colors.grey),
                              )
                            else
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: DataPersistenceService.getQuestions(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const CircularProgressIndicator();
                                  }
                                  final selectedQuestions = snapshot.data!
                                      .where((q) =>
                                          _selectedQuestionIds.contains(q['id']))
                                      .toList();
                                  return Column(
                                    children: selectedQuestions
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final index = entry.key;
                                      final question = entry.value;
                                      return _QuestionItem(
                                        number: index + 1,
                                        tag: question['category'] as String? ?? 'General',
                                        text: question['question'] as String? ?? '',
                                        onRemove: () {
                                          setState(() {
                                            _selectedQuestionIds
                                                .remove(question['id']);
                                          });
                                        },
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveSimulacro,
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
                              : const Text(
                                  'Guardar Simulacro',
                                  style: TextStyle(
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

  void _showQuestionSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FutureBuilder<List<Map<String, dynamic>>>(
        future: DataPersistenceService.getQuestions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final questions = snapshot.data!;
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Container(
                padding: const EdgeInsets.all(24),
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seleccionar preguntas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          final question = questions[index];
                          final questionId = question['id'] as String;
                          final isSelected = _selectedQuestionIds.contains(questionId);
                          return CheckboxListTile(
                            title: Text(question['question'] as String? ?? ''),
                            subtitle: Text(question['category'] as String? ?? ''),
                            value: isSelected,
                            onChanged: (value) {
                              setModalState(() {
                                if (value == true) {
                                  _selectedQuestionIds.add(questionId);
                                } else {
                                  _selectedQuestionIds.remove(questionId);
                                }
                              });
                              setState(() {}); // Actualizar el estado principal también
                            },
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Confirmar'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
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

class _QuestionItem extends StatelessWidget {
  final int number;
  final String tag;
  final String text;
  final VoidCallback onRemove;

  const _QuestionItem({
    required this.number,
    required this.tag,
    required this.text,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.drag_indicator, color: Colors.grey[400], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#$number',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.close, color: Colors.red[300], size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
