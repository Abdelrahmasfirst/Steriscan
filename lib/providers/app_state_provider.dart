import 'package:flutter/foundation.dart';
import '../core/app_config.dart';
import '../core/services/auth_service.dart';
import '../core/services/thermal_service.dart';
import '../core/services/permission_service.dart';

class AppStateProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isConnected = false;
  String _currentLanguage = 'fr';
  String _themeMode = 'system';
  double _currentTemperature = 25.0;
  ThermalState _thermalState = ThermalState.normal;
  AuthState _authState = AuthState.unauthenticated;
  Map<String, dynamic> _permissions = {};
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  String get currentLanguage => _currentLanguage;
  String get themeMode => _themeMode;
  double get currentTemperature => _currentTemperature;
  ThermalState get thermalState => _thermalState;
  AuthState get authState => _authState;
  Map<String, dynamic> get permissions => _permissions;
  
  bool get canScan => _thermalState != ThermalState.critical && 
                     _authState == AuthState.authenticated;
  
  String get statusMessage {
    if (_thermalState == ThermalState.critical) {
      return 'Température critique - Refroidissement nécessaire';
    } else if (_thermalState == ThermalState.warning) {
      return 'Température élevée - Surveillance requise';
    } else if (_authState == AuthState.unauthenticated) {
      return 'Authentification requise';
    } else if (!_isConnected) {
      return 'Mode hors ligne';
    }
    return 'Prêt pour le scan';
  }
  
  AppStateProvider() {
    _initialize();
  }
  
  Future<void> _initialize() async {
    setLoading(true);
    
    try {
      // Charger les paramètres de configuration
      _currentLanguage = AppConfig.language;
      _themeMode = AppConfig.themeMode;
      
      // Écouter les changements d'état d'authentification
      AuthService.authStateStream.listen((state) {
        _authState = state;
        notifyListeners();
      });
      
      // Écouter les changements de température
      ThermalService.temperatureStream.listen((temp) {
        _currentTemperature = temp;
        _thermalState = ThermalService.getThermalState();
        notifyListeners();
      });
      
      // Charger les permissions
      await _loadPermissions();
      
    } catch (e) {
      debugPrint('Erreur initialisation AppStateProvider: $e');
    } finally {
      setLoading(false);
    }
  }
  
  Future<void> _loadPermissions() async {
    try {
      _permissions = await PermissionService.getPermissionStatus();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur chargement permissions: $e');
    }
  }
  
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
  
  void setConnected(bool connected) {
    if (_isConnected != connected) {
      _isConnected = connected;
      notifyListeners();
    }
  }
  
  Future<void> changeLanguage(String language) async {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      await AppConfig.setLanguage(language);
      notifyListeners();
    }
  }
  
  Future<void> changeThemeMode(String themeMode) async {
    if (_themeMode != themeMode) {
      _themeMode = themeMode;
      await AppConfig.setThemeMode(themeMode);
      notifyListeners();
    }
  }
  
  Future<void> refreshPermissions() async {
    await _loadPermissions();
  }
  
  Future<void> requestAllPermissions() async {
    setLoading(true);
    try {
      await PermissionService.requestAllPermissions();
      await _loadPermissions();
    } catch (e) {
      debugPrint('Erreur demande permissions: $e');
    } finally {
      setLoading(false);
    }
  }
  
  Future<void> coolDownDevice() async {
    if (_thermalState == ThermalState.critical) {
      setLoading(true);
      try {
        await ThermalService.coolDown();
      } catch (e) {
        debugPrint('Erreur refroidissement: $e');
      } finally {
        setLoading(false);
      }
    }
  }
  
  Future<void> refresh() async {
    setLoading(true);
    try {
      await _loadPermissions();
      _currentTemperature = await ThermalService.getCurrentTemperature();
      _thermalState = ThermalService.getThermalState();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur actualisation: $e');
    } finally {
      setLoading(false);
    }
  }
  
  // Méthodes de diagnostic
  Map<String, dynamic> get diagnosticInfo => {
    'isLoading': _isLoading,
    'isConnected': _isConnected,
    'currentLanguage': _currentLanguage,
    'themeMode': _themeMode,
    'currentTemperature': _currentTemperature,
    'thermalState': _thermalState.toString(),
    'authState': _authState.toString(),
    'canScan': canScan,
    'statusMessage': statusMessage,
    'permissions': _permissions,
    'timestamp': DateTime.now().toIso8601String(),
  };
  
  void logDiagnostic() {
    debugPrint('=== DIAGNOSTIC APP STATE ===');
    debugPrint(diagnosticInfo.toString());
    debugPrint('===========================');
  }
}

// Extensions pour faciliter l'utilisation
extension ThermalStateExtension on ThermalState {
  String get displayName {
    switch (this) {
      case ThermalState.cool:
        return 'Froid';
      case ThermalState.normal:
        return 'Normal';
      case ThermalState.warning:
        return 'Chaud';
      case ThermalState.critical:
        return 'Critique';
    }
  }
  
  bool get isOperational => this != ThermalState.critical;
}

extension AuthStateExtension on AuthState {
  String get displayName {
    switch (this) {
      case AuthState.authenticated:
        return 'Connecté';
      case AuthState.unauthenticated:
        return 'Non connecté';
      case AuthState.checking:
        return 'Vérification...';
    }
  }
}