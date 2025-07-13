import 'package:flutter/material.dart';

// Placeholder screens - these would be replaced by actual screen implementations
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.scanner, size: 64, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'SteriScan 3D',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Chargement...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bienvenue')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Écran d\'accueil'),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, Routes.dashboard),
              child: Text('Commencer'),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tableau de bord')),
      body: Center(child: Text('Dashboard')),
    );
  }
}

class ScanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scanner')),
      body: Center(child: Text('Scan Screen')),
    );
  }
}

class CatalogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Catalogue')),
      body: Center(child: Text('Catalog Screen')),
    );
  }
}

class KitScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kits')),
      body: Center(child: Text('Kit Screen')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Paramètres')),
      body: Center(child: Text('Settings Screen')),
    );
  }
}

class IdentificationResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Résultats')),
      body: Center(child: Text('Results Screen')),
    );
  }
}

class Routes {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String scan = '/scan';
  static const String catalog = '/catalog';
  static const String kit = '/kit';
  static const String settings = '/settings';
  static const String identificationResults = '/identification-results';
  
  // Route arguments
  static const String argInstrumentId = 'instrument_id';
  static const String argKitId = 'kit_id';
  static const String argScanResultId = 'scan_result_id';
  
  // Private constructor
  Routes._();
}

class AppRoutes {
  // Static route map
  static final Map<String, WidgetBuilder> routes = {
    Routes.splash: (context) => SplashScreen(),
    Routes.onboarding: (context) => OnboardingScreen(),
    Routes.dashboard: (context) => DashboardScreen(),
    Routes.scan: (context) => ScanScreen(),
    Routes.catalog: (context) => CatalogScreen(),
    Routes.kit: (context) => KitScreen(),
    Routes.settings: (context) => SettingsScreen(),
    Routes.identificationResults: (context) => IdentificationResultsScreen(),
  };
  
  // Route generator for dynamic routes
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? '';
    final Map<String, dynamic> arguments = 
        settings.arguments as Map<String, dynamic>? ?? {};
    
    switch (routeName) {
      case Routes.identificationResults:
        return MaterialPageRoute(
          builder: (context) => IdentificationResultsScreen(),
          settings: settings,
        );
      
      default:
        return MaterialPageRoute(
          builder: (context) => _buildErrorScreen(routeName),
          settings: settings,
        );
    }
  }
  
  // Error screen for unknown routes
  static Widget _buildErrorScreen(String routeName) {
    return Scaffold(
      appBar: AppBar(title: Text('Erreur')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Route non trouvée',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Route: $routeName'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _navigateToHome(),
              child: Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
  
  static void _navigateToHome() {
    // Cette méthode devrait être implémentée avec un contexte approprié
    // ou utiliser un navigateur global
  }
}

// Navigation helpers
class NavigationHelper {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static NavigatorState? get navigator => navigatorKey.currentState;
  
  static Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return navigator!.pushNamed<T>(routeName, arguments: arguments);
  }
  
  static Future<T?> pushReplacementNamed<T>(String routeName, {Object? arguments}) {
    return navigator!.pushReplacementNamed<T>(routeName, arguments: arguments);
  }
  
  static Future<T?> pushNamedAndClearStack<T>(String routeName, {Object? arguments}) {
    return navigator!.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
  
  static void pop<T>([T? result]) {
    navigator!.pop<T>(result);
  }
  
  static bool canPop() {
    return navigator!.canPop();
  }
  
  static Future<bool> maybePop<T>([T? result]) {
    return navigator!.maybePop<T>(result);
  }
  
  // Navigation methods with specific routes
  static Future<void> goToSplash() {
    return pushNamedAndClearStack(Routes.splash);
  }
  
  static Future<void> goToOnboarding() {
    return pushReplacementNamed(Routes.onboarding);
  }
  
  static Future<void> goToDashboard() {
    return pushReplacementNamed(Routes.dashboard);
  }
  
  static Future<void> goToScan() {
    return pushNamed(Routes.scan);
  }
  
  static Future<void> goToCatalog() {
    return pushNamed(Routes.catalog);
  }
  
  static Future<void> goToKit({String? kitId}) {
    return pushNamed(
      Routes.kit,
      arguments: kitId != null ? {Routes.argKitId: kitId} : null,
    );
  }
  
  static Future<void> goToSettings() {
    return pushNamed(Routes.settings);
  }
  
  static Future<void> goToIdentificationResults({
    String? instrumentId,
    String? scanResultId,
  }) {
    final arguments = <String, dynamic>{};
    if (instrumentId != null) arguments[Routes.argInstrumentId] = instrumentId;
    if (scanResultId != null) arguments[Routes.argScanResultId] = scanResultId;
    
    return pushNamed(
      Routes.identificationResults,
      arguments: arguments.isNotEmpty ? arguments : null,
    );
  }
  
  // Utility methods
  static String getCurrentRoute() {
    String? currentRoute;
    navigator!.popUntil((route) {
      currentRoute = route.settings.name;
      return true;
    });
    return currentRoute ?? Routes.splash;
  }
  
  static bool isCurrentRoute(String routeName) {
    return getCurrentRoute() == routeName;
  }
  
  static Map<String, dynamic> getRouteArguments() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is Map<String, dynamic>) {
        return arguments;
      }
    }
    return {};
  }
  
  static T? getRouteArgument<T>(String key) {
    final arguments = getRouteArguments();
    return arguments[key] as T?;
  }
}

// Route transition animations
class RouteTransitions {
  static PageRouteBuilder<T> slideFromRight<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
  
  static PageRouteBuilder<T> slideFromBottom<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
  
  static PageRouteBuilder<T> fadeIn<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}