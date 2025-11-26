import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:preparate_icfes_seminario/config/theme/app_colors.dart';
import 'package:preparate_icfes_seminario/screens/login/bloc/authentication_bloc.dart';
import 'package:preparate_icfes_seminario/services/data_persistence_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _simulacrosCount = 0;
  int _questionsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final simulacros = await DataPersistenceService.getSimulacros();
    final questions = await DataPersistenceService.getQuestions();
    setState(() {
      _simulacrosCount = simulacros.length;
      _questionsCount = questions.length;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header verde con información del usuario
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
                    // Saludo y nombre
                    BlocBuilder<AuthenticationBloc, AuthenticationState>(
                      builder: (context, authState) {
                        final user = authState.user;
                        final nombre = user?.nombre ?? 'Usuario';
                        final apellido = user?.apellido ?? '';
                        final nombreCompleto = '$nombre $apellido'.trim();
                        
                        return Row(
                          children: [
                            GestureDetector(
                              onTap: () => _showProfileMenu(context),
                              child: CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.3),
                                radius: 24,
                                backgroundImage: user?.avatar != null
                                    ? NetworkImage(user!.avatar!)
                                    : null,
                                child: user?.avatar == null
                                    ? const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 28,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hola',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    nombreCompleto.isNotEmpty ? nombreCompleto : nombre,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Tarjeta de progreso
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tu progreso',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '72%',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.bookmark_border,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Barra de progreso
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: 0.72,
                              minHeight: 8,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.error,
                               ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Sección de Acceso rápido
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Acceso rápido',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Grid de tarjetas
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.95,
                      children: [
                        _QuickAccessCard(
                          icon: Icons.description_outlined,
                          title: 'Simulacros',
                          subtitle: _isLoading
                              ? 'Cargando...'
                              : '$_simulacrosCount ${_simulacrosCount == 1 ? 'disponible' : 'disponibles'}',
                          iconColor: AppColors.primary,
                          iconBgColor: AppColors.primary.withOpacity(0.1),
                          onTap: () => context.push('/simulacros'),
                        ),
                        _QuickAccessCard(
                          icon: Icons.menu_book_outlined,
                          title: 'Banco',
                          subtitle: _isLoading
                              ? 'Cargando...'
                              : '$_questionsCount ${_questionsCount == 1 ? 'pregunta' : 'preguntas'}',
                          iconColor: AppColors.secondary,
                          iconBgColor: AppColors.secondary.withOpacity(0.1),
                          onTap: () => context.push('/question-bank'),
                        ),
                        _QuickAccessCard(
                          icon: Icons.bar_chart_outlined,
                          title: 'Estadísticas',
                          subtitle: 'Ver desempeño',
                          iconColor: AppColors.error,
                          iconBgColor: AppColors.error.withOpacity(0.1),
                          onTap: () => context.push('/statistics'),
                        ),
                        _QuickAccessCard(
                          icon: Icons.emoji_events_outlined,
                          title: 'Resultados',
                          subtitle: 'Ver resultados',
                          iconColor: Color(0xFF3FADA8),
                          iconBgColor: Color(0xFF3FADA8).withOpacity(0.1),
                          onTap: () => context.push('/results'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, authState) {
                final user = authState.user;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user?.avatar != null
                        ? NetworkImage(user!.avatar!)
                        : null,
                    child: user?.avatar == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(
                    '${user?.nombre ?? ''} ${user?.apellido ?? ''}'.trim(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(user?.email ?? ''),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthenticationBloc>().add(
                      AuthenticationLogoutRequested(),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Ícono con mejor diseño
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      iconColor,
                      iconColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              // Textos mejorados
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
