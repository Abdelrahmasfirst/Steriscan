import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/scanner_screen.dart';
import '../screens/results_screen.dart';
import '../screens/comparison_screen.dart';
import '../screens/reconstitution_screen.dart';
import '../screens/history_screen.dart';
import '../screens/settings_screen.dart';

/// Application route configuration using GoRouter.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/scan',
        name: 'scan',
        builder: (context, state) => const ScannerScreen(),
      ),
      GoRoute(
        path: '/results',
        name: 'results',
        builder: (context, state) {
          final scanId = state.uri.queryParameters['scanId'];
          return ResultsScreen(scanId: scanId);
        },
      ),
      GoRoute(
        path: '/comparison',
        name: 'comparison',
        builder: (context, state) {
          final scanId = state.uri.queryParameters['scanId'];
          return ComparisonScreen(scanId: scanId);
        },
      ),
      GoRoute(
        path: '/reconstitution',
        name: 'reconstitution',
        builder: (context, state) {
          final kitId = state.uri.queryParameters['kitId'];
          return ReconstitutionScreen(kitId: kitId);
        },
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page introuvable',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );
}
