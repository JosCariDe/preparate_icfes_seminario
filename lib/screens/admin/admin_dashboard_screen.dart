import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:preparate_icfes_seminario/config/theme/app_colors.dart';
import 'package:preparate_icfes_seminario/screens/login/bloc/authentication_bloc.dart';
import 'package:preparate_icfes_seminario/models/simulacro_model.dart';
import 'package:preparate_icfes_seminario/services/data_persistence_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Simulacro> _simulacros = [];
  List<Simulacro> _filteredSimulacros = [];
  String _selectedArea = 'Todas las áreas';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSimulacros();
  }

  Future<void> _loadSimulacros() async {
    setState(() => _isLoading = true);
    try {
      final simulacros = await DataPersistenceService.getSimulacros();
      setState(() {
        _simulacros = simulacros;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar simulacros: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilter() {
    if (_selectedArea == 'Todas las áreas') {
      _filteredSimulacros = List.from(_simulacros);
    } else {
      _filteredSimulacros = _simulacros
          .where((s) => s.area == _selectedArea)
          .toList();
    }
  }

  void _onAreaChanged(String? newArea) {
    if (newArea != null) {
      setState(() {
        _selectedArea = newArea;
        _applyFilter();
      });
    }
  }

  Future<void> _deleteSimulacro(String simulacroId, String titulo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar "$titulo"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DataPersistenceService.deleteSimulacro(simulacroId);
        await _loadSimulacros();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Simulacro eliminado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _editSimulacro(String simulacroId) {
    context.push('/admin/create-simulacro', extra: simulacroId).then((_) {
      _loadSimulacros(); // Recargar después de editar
    });
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
                color: Color(0xFF1E1E1E), // Dark header like in mockup
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          context
                              .read<AuthenticationBloc>()
                              .add(AuthenticationLogoutRequested());
                        },
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
                        'Panel Admin',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Gestiona simulacros y preguntas',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Crear simulacro',
                      icon: Icons.add,
                      color: const Color(0xFF81C784), // Greenish
                      onTap: () => context.push('/admin/create-simulacro').then((_) {
                        _loadSimulacros(); // Recargar después de crear
                      }),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ActionButton(
                      label: 'Crear pregunta',
                      icon: Icons.description_outlined,
                      color: const Color(0xFF64B5F6), // Blueish
                      onTap: () => context.push('/admin/create-question'),
                    ),
                  ),
                ],
              ),
            ),
            // Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtrar por área',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedArea,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: ['Todas las áreas', 'Matemáticas', 'Inglés', 'Ciencias Naturales', 'Ciencias Sociales', 'Lenguaje']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: _onAreaChanged,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Simulacros creados (${_filteredSimulacros.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.search, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredSimulacros.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay simulacros disponibles',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _filteredSimulacros.length,
                          itemBuilder: (context, index) {
                            final simulacro = _filteredSimulacros[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _AdminSimulacroCard(
                                title: simulacro.titulo,
                                area: simulacro.area,
                                questionsCount: simulacro.totalPreguntas,
                                status: 'Publicado',
                                statusColor: const Color(0xFFE0F2F1),
                                statusTextColor: const Color(0xFF00695C),
                                onEdit: () => _editSimulacro(simulacro.id),
                                onDelete: () => _deleteSimulacro(simulacro.id, simulacro.titulo),
                              ),
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

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminSimulacroCard extends StatelessWidget {
  final String title;
  final String area;
  final int questionsCount;
  final String status;
  final Color statusColor;
  final Color statusTextColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminSimulacroCard({
    required this.title,
    required this.area,
    required this.questionsCount,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Tag(text: area, color: Colors.grey[100]!, textColor: Colors.grey[800]!),
                        const SizedBox(width: 8),
                        _Tag(text: '$questionsCount preguntas', color: Colors.blue[50]!, textColor: Colors.blue[800]!),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _Tag(text: status, color: statusColor, textColor: statusTextColor),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Editar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: BorderSide(color: Colors.green.withOpacity(0.2)),
                    backgroundColor: Colors.green.withOpacity(0.05),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Eliminar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.withOpacity(0.2)),
                    backgroundColor: Colors.red.withOpacity(0.05),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const _Tag({
    required this.text,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
