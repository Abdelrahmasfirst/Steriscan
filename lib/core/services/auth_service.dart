import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../security/security_manager.dart';
import 'database_service.dart';

class AuthService {
  static const String _keyUserId = 'user_id';
  static const String _keySessionToken = 'session_token';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserName = 'user_name';
  
  static String? _currentUserId;
  static String? _currentSessionToken;
  static UserRole _currentUserRole = UserRole.technician;
  static String? _currentUserName;
  
  static final StreamController<AuthState> _authStateController = 
      StreamController<AuthState>.broadcast();
  
  static Stream<AuthState> get authStateStream => _authStateController.stream;
  
  static Future<void> initialize() async {
    await _loadUserSession();
  }
  
  static Future<void> _loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      if (isLoggedIn) {
        _currentUserId = prefs.getString(_keyUserId);
        _currentSessionToken = prefs.getString(_keySessionToken);
        _currentUserName = prefs.getString(_keyUserName);
        
        final roleString = prefs.getString(_keyUserRole) ?? 'technician';
        _currentUserRole = UserRole.values.firstWhere(
          (role) => role.toString().split('.').last == roleString,
          orElse: () => UserRole.technician,
        );
        
        // Vérifier la validité de la session
        if (_currentSessionToken != null) {
          final isValid = await DatabaseService.validateSession(_currentSessionToken!);
          if (!isValid) {
            await logout();
            return;
          }
        }
        
        _authStateController.add(AuthState.authenticated);
      } else {
        _authStateController.add(AuthState.unauthenticated);
      }
    } catch (e) {
      debugPrint('Erreur chargement session: $e');
      _authStateController.add(AuthState.unauthenticated);
    }
  }
  
  static Future<AuthResult> login(String username, String password) async {
    try {
      // Validation des entrées
      if (!SecurityManager.validateInput(username) || 
          !SecurityManager.validateInput(password)) {
        return AuthResult(
          success: false,
          message: 'Données d\'entrée invalides',
        );
      }
      
      // Simulation de l'authentification
      // Dans un vrai système, cela ferait appel à une API
      final isValid = await _validateCredentials(username, password);
      
      if (isValid) {
        // Génération d'un token de session
        final sessionToken = _generateSessionToken();
        _currentUserId = const Uuid().v4();
        _currentSessionToken = sessionToken;
        _currentUserName = username;
        _currentUserRole = _getUserRole(username);
        
        // Sauvegarde de la session
        await _saveUserSession();
        await DatabaseService.saveUserSession(_currentUserId!, sessionToken);
        
        _authStateController.add(AuthState.authenticated);
        
        return AuthResult(
          success: true,
          message: 'Connexion réussie',
          user: AuthUser(
            id: _currentUserId!,
            username: username,
            role: _currentUserRole,
          ),
        );
      } else {
        return AuthResult(
          success: false,
          message: 'Nom d\'utilisateur ou mot de passe incorrect',
        );
      }
    } catch (e) {
      debugPrint('Erreur authentification: $e');
      return AuthResult(
        success: false,
        message: 'Erreur de connexion',
      );
    }
  }
  
  static Future<bool> _validateCredentials(String username, String password) async {
    // Simulation de base de données utilisateurs
    final users = {
      'admin': {'password': 'admin123', 'role': UserRole.admin},
      'technician': {'password': 'tech123', 'role': UserRole.technician},
      'operator': {'password': 'op123', 'role': UserRole.operator},
      'supervisor': {'password': 'super123', 'role': UserRole.supervisor},
    };
    
    if (users.containsKey(username)) {
      final user = users[username]!;
      final salt = 'steriscan_salt';
      final hashedPassword = SecurityManager.hashPassword(password, salt);
      final expectedHash = SecurityManager.hashPassword(user['password'] as String, salt);
      
      return hashedPassword == expectedHash;
    }
    
    return false;
  }
  
  static UserRole _getUserRole(String username) {
    final roles = {
      'admin': UserRole.admin,
      'technician': UserRole.technician,
      'operator': UserRole.operator,
      'supervisor': UserRole.supervisor,
    };
    
    return roles[username] ?? UserRole.technician;
  }
  
  static String _generateSessionToken() {
    final uuid = const Uuid();
    return uuid.v4();
  }
  
  static Future<void> _saveUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_keyUserId, _currentUserId ?? '');
    await prefs.setString(_keySessionToken, _currentSessionToken ?? '');
    await prefs.setString(_keyUserName, _currentUserName ?? '');
    await prefs.setString(_keyUserRole, _currentUserRole.toString().split('.').last);
    await prefs.setBool(_keyIsLoggedIn, true);
  }
  
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Effacer les données de session
      await prefs.remove(_keyUserId);
      await prefs.remove(_keySessionToken);
      await prefs.remove(_keyUserName);
      await prefs.remove(_keyUserRole);
      await prefs.setBool(_keyIsLoggedIn, false);
      
      // Nettoyer les sessions expirées
      await DatabaseService.clearExpiredSessions();
      
      // Réinitialiser les variables
      _currentUserId = null;
      _currentSessionToken = null;
      _currentUserName = null;
      _currentUserRole = UserRole.technician;
      
      _authStateController.add(AuthState.unauthenticated);
    } catch (e) {
      debugPrint('Erreur déconnexion: $e');
    }
  }
  
  static bool get isLoggedIn => _currentUserId != null && _currentSessionToken != null;
  
  static String? get currentUserId => _currentUserId;
  static String? get currentUserName => _currentUserName;
  static UserRole get currentUserRole => _currentUserRole;
  
  static AuthUser? get currentUser {
    if (_currentUserId != null && _currentUserName != null) {
      return AuthUser(
        id: _currentUserId!,
        username: _currentUserName!,
        role: _currentUserRole,
      );
    }
    return null;
  }
  
  static bool hasPermission(Permission permission) {
    switch (permission) {
      case Permission.scanInstruments:
        return true; // Tous les utilisateurs peuvent scanner
      case Permission.manageInstruments:
        return _currentUserRole == UserRole.admin || 
               _currentUserRole == UserRole.supervisor;
      case Permission.manageKits:
        return _currentUserRole == UserRole.admin || 
               _currentUserRole == UserRole.supervisor;
      case Permission.viewReports:
        return _currentUserRole == UserRole.admin || 
               _currentUserRole == UserRole.supervisor;
      case Permission.manageUsers:
        return _currentUserRole == UserRole.admin;
      case Permission.systemSettings:
        return _currentUserRole == UserRole.admin;
    }
  }
  
  static Future<void> dispose() async {
    await _authStateController.close();
  }
}

class AuthResult {
  final bool success;
  final String message;
  final AuthUser? user;
  
  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}

class AuthUser {
  final String id;
  final String username;
  final UserRole role;
  
  AuthUser({
    required this.id,
    required this.username,
    required this.role,
  });
  
  String get roleDisplayName {
    switch (role) {
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.supervisor:
        return 'Superviseur';
      case UserRole.technician:
        return 'Technicien';
      case UserRole.operator:
        return 'Opérateur';
    }
  }
}

enum AuthState {
  authenticated,
  unauthenticated,
  checking,
}

enum UserRole {
  admin,
  supervisor,
  technician,
  operator,
}

enum Permission {
  scanInstruments,
  manageInstruments,
  manageKits,
  viewReports,
  manageUsers,
  systemSettings,
}