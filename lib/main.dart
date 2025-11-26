import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:preparate_icfes_seminario/config/environment.dart';
import 'package:preparate_icfes_seminario/config/router/app_router.dart';
import 'package:preparate_icfes_seminario/config/theme/app_theme.dart';
import 'package:preparate_icfes_seminario/repositories/api_auth_repository.dart';
import 'package:preparate_icfes_seminario/repositories/api_simulacro_repository.dart';
import 'package:preparate_icfes_seminario/repositories/auth_repository.dart';
import 'package:preparate_icfes_seminario/repositories/simulacro_repository.dart';
import 'package:preparate_icfes_seminario/screens/login/bloc/authentication_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.init();

  final AuthRepository authRepository;
  final SimulacroRepository simulacroRepository;

  if (Environment.isMock) {
    authRepository = MockAuthRepository();
    simulacroRepository = MockSimulacroRepository();
  } else {
    authRepository = ApiAuthRepository(apiUrl: Environment.apiUrl);
    simulacroRepository = ApiSimulacroRepository(apiUrl: Environment.apiUrl);
  }

  runApp(MainApp(
    authRepository: authRepository,
    simulacroRepository: simulacroRepository,
  ));
}

class MainApp extends StatelessWidget {
  final AuthRepository authRepository;
  final SimulacroRepository simulacroRepository;

  const MainApp({
    super.key,
    required this.authRepository,
    required this.simulacroRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: simulacroRepository),
      ],
      child: BlocProvider(
        create: (_) => AuthenticationBloc(authRepository: authRepository)
          ..add(AuthenticationSubscriptionRequested()),
        child: const _AppView(),
      ),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthenticationBloc>();
    return MaterialApp.router(
      routerConfig: createRouter(authBloc),
      theme: AppTheme().getTheme(),
      debugShowCheckedModeBanner: false,
    );
  }
}
