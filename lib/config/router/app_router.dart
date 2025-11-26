import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:preparate_icfes_seminario/screens/admin/admin_dashboard_screen.dart';
import 'package:preparate_icfes_seminario/screens/admin/create_question_screen.dart';
import 'package:preparate_icfes_seminario/screens/admin/create_simulacro_screen.dart';
import 'package:preparate_icfes_seminario/screens/login/bloc/authentication_bloc.dart';
import 'package:preparate_icfes_seminario/screens/screens.dart';
import 'package:preparate_icfes_seminario/models/exam_result_model.dart';

GoRouter createRouter(AuthenticationBloc authBloc) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/splash';

      if (authState.status == AuthenticationStatus.unknown) {
        return '/splash';
      }

      if (authState.status == AuthenticationStatus.unauthenticated) {
        if (isLoggingIn || isSplash) return null;
        return '/login';
      }

      if (authState.status == AuthenticationStatus.authenticated) {
        if (authState.user?.rol == 'ADMIN') {
          if (state.matchedLocation.startsWith('/admin')) return null;
          return '/admin';
        }
        
        if (isLoggingIn || isSplash) return '/';
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'create-simulacro',
            builder: (context, state) => const CreateSimulacroScreen(),
          ),
          GoRoute(
            path: 'create-question',
            builder: (context, state) => const CreateQuestionScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/simulacros',
        builder: (context, state) => const SimulacrosScreen(),
      ),
      GoRoute(
        path: '/question',
        builder: (context, state) => const QuestionScreen(),
      ),
      GoRoute(
        path: '/results',
        builder: (context, state) {
          final result = state.extra as ExamResult?;
          return ResultsScreen(result: result);
        },
      ),
      GoRoute(
        path: '/statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: '/question-bank',
        builder: (context, state) => const QuestionBankScreen(),
      ),
      GoRoute(
        path: '/question-detail',
        builder: (context, state) => const QuestionDetailScreen(),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
