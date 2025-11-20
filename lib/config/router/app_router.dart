import 'package:go_router/go_router.dart';
import 'package:preparate_icfes_seminario/screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
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
      path: '/simulacros',
      builder: (context, state) => const SimulacrosScreen(),
    ),
    GoRoute(
      path: '/question',
      builder: (context, state) => const QuestionScreen(),
    ),
    GoRoute(
      path: '/results',
      builder: (context, state) => const ResultsScreen(),
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
