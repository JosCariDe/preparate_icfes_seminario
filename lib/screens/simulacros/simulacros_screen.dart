import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:preparate_icfes_seminario/config/theme/app_colors.dart';
import 'package:preparate_icfes_seminario/repositories/simulacro_repository.dart';
import 'bloc/simulacros_bloc.dart';

class SimulacrosScreen extends StatelessWidget {
  const SimulacrosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SimulacrosBloc(
        simulacroRepository: context.read<SimulacroRepository>(),
      )..add(const SimulacrosRequested()),
      child: const _SimulacrosView(),
    );
  }
}

class _SimulacrosView extends StatelessWidget {
  const _SimulacrosView();

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
                        'Simulacros',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Practica con simulacros completos',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            // Lista de simulacros
            Expanded(
              child: BlocBuilder<SimulacrosBloc, SimulacrosState>(
                builder: (context, state) {
                  if (state.status == SimulacrosStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state.status == SimulacrosStatus.failure) {
                    return Center(
                        child: Text(state.errorMessage ?? 'Error al cargar'));
                  } else if (state.status == SimulacrosStatus.success) {
                    if (state.simulacros.isEmpty) {
                      return const Center(
                          child: Text('No hay simulacros disponibles'));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: state.simulacros.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final simulacro = state.simulacros[index];
                        return _SimulacroCard(
                          title: simulacro.titulo,
                          subject: simulacro.area,
                          difficulty: simulacro.nivel,
                          duration: '${simulacro.duracionMinutos} min',
                          iconColor: simulacro.area == 'Matemáticas'
                              ? AppColors.secondary
                              : AppColors.primary,
                          iconBgColor: (simulacro.area == 'Matemáticas'
                                  ? AppColors.secondary
                                  : AppColors.primary)
                              .withOpacity(0.1),
                          buttonColor: simulacro.area == 'Matemáticas'
                              ? AppColors.secondary
                              : AppColors.primary,
                          onTap: () => context.go('/question', extra: simulacro.id),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimulacroCard extends StatelessWidget {
  final String title;
  final String subject;
  final String difficulty;
  final String duration;
  final Color iconColor;
  final Color iconBgColor;
  final Color buttonColor;
  final VoidCallback onTap;

  const _SimulacroCard({
    required this.title,
    required this.subject,
    required this.difficulty,
    required this.duration,
    required this.iconColor,
    required this.iconBgColor,
    required this.buttonColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Ícono circular
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.track_changes,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Información del simulacro
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Información adicional
          Row(
            children: [
              _InfoChip(
                label: difficulty,
                icon: Icons.signal_cellular_alt,
              ),
              const SizedBox(width: 12),
              _InfoChip(
                label: duration,
                icon: Icons.access_time,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Botón de iniciar
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.play_arrow, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Iniciar simulacro',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _InfoChip({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}