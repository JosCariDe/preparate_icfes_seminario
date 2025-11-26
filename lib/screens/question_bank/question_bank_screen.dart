import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:preparate_icfes_seminario/config/theme/app_colors.dart';
import 'package:preparate_icfes_seminario/services/data_persistence_service.dart';

class QuestionBankScreen extends StatefulWidget {
  const QuestionBankScreen({super.key});

  @override
  State<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends State<QuestionBankScreen> {
  String _selectedCategory = 'Todas';
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _favorites = {'preg_001', 'preg_003'}; // IDs de favoritas
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    final questions = await DataPersistenceService.getQuestions();
    setState(() {
      _questions = questions;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredQuestions {
    var filtered = List<Map<String, dynamic>>.from(_questions);

    // Filtrar por categoría
    if (_selectedCategory != 'Todas') {
      filtered = filtered.where((q) {
        final category = q['category'] as String? ?? '';
        return category == _selectedCategory;
      }).toList();
    }

    // Filtrar por búsqueda
    final searchText = _searchController.text.toLowerCase();
    if (searchText.isNotEmpty) {
      filtered = filtered.where((q) {
        final question = (q['question'] as String? ?? '').toLowerCase();
        return question.contains(searchText);
      }).toList();
    }

    return filtered;
  }

  void _toggleFavorite(String questionId) {
    setState(() {
      if (_favorites.contains(questionId)) {
        _favorites.remove(questionId);
      } else {
        _favorites.add(questionId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header verde
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botón de regresar y título
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Banco de Preguntas',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Barra de búsqueda
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Buscar preguntas...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[600],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Filtros
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _CategoryChip(
                      label: 'Todas',
                      isSelected: _selectedCategory == 'Todas',
                      onTap: () => setState(() => _selectedCategory = 'Todas'),
                    ),
                    const SizedBox(width: 8),
                    _CategoryChip(
                      label: 'Matemáticas',
                      isSelected: _selectedCategory == 'Matemáticas',
                      onTap: () => setState(() => _selectedCategory = 'Matemáticas'),
                    ),
                    const SizedBox(width: 8),
                    _CategoryChip(
                      label: 'Lenguaje',
                      isSelected: _selectedCategory == 'Lenguaje',
                      onTap: () => setState(() => _selectedCategory = 'Lenguaje'),
                    ),
                    const SizedBox(width: 8),
                    _CategoryChip(
                      label: 'Sociales',
                      isSelected: _selectedCategory == 'Sociales',
                      onTap: () => setState(() => _selectedCategory = 'Sociales'),
                    ),
                    const SizedBox(width: 8),
                    _CategoryChip(
                      label: 'Naturales',
                      isSelected: _selectedCategory == 'Naturales',
                      onTap: () => setState(() => _selectedCategory = 'Naturales'),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.tune,
                        color: Colors.grey[700],
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Lista de preguntas
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredQuestions.isEmpty
                      ? Center(
                          child: Text(
                            'No se encontraron preguntas',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(24),
                          itemCount: _filteredQuestions.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final question = _filteredQuestions[index];
                            final questionId = question['id'] as String? ?? '';
                            final isFavorite = _favorites.contains(questionId);
                            return _QuestionCard(
                              question: question['question'] as String? ?? '',
                              category: question['category'] as String? ?? 'General',
                              difficulty: question['difficulty'] as String? ?? 'Media',
                              isFavorite: isFavorite,
                              onTap: () {
                                final questionId = question['id'] as String? ?? '';
                                context.push('/question-detail/$questionId', extra: question);
                              },
                              onFavoriteTap: () => _toggleFavorite(questionId),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String question;
  final String category;
  final String difficulty;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const _QuestionCard({
    required this.question,
    required this.category,
    required this.difficulty,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        difficulty,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => onFavoriteTap(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.red : Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
