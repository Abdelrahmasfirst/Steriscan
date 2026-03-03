import 'package:flutter/material.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// SteriScan Reconstruct — AI-powered surgical kit traceability
/// and reconstitution application.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SteriscanApp());
}

class SteriscanApp extends StatelessWidget {
  const SteriscanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SteriScan Reconstruct',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      locale: const Locale('fr', 'FR'),
    );
  }
}
