import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static bool _isInitialized = false;
  
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _checkEssentialPermissions();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Erreur initialisation PermissionService: $e');
    }
  }
  
  static Future<void> _checkEssentialPermissions() async {
    // Vérifier les permissions essentielles au démarrage
    final permissions = [
      Permission.camera,
      Permission.storage,
    ];
    
    for (final permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        debugPrint('Permission ${permission.toString()} non accordée');
      }
    }
  }
  
  static Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Erreur demande permission caméra: $e');
      return false;
    }
  }
  
  static Future<bool> requestStoragePermission() async {
    try {
      final status = await Permission.storage.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Erreur demande permission stockage: $e');
      return false;
    }
  }
  
  static Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Erreur demande permission localisation: $e');
      return false;
    }
  }
  
  static Future<bool> requestSensorsPermission() async {
    try {
      final status = await Permission.sensors.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Erreur demande permission capteurs: $e');
      return false;
    }
  }
  
  static Future<bool> requestAllPermissions() async {
    try {
      final permissions = [
        Permission.camera,
        Permission.storage,
        Permission.location,
        Permission.sensors,
      ];
      
      final statuses = await permissions.request();
      
      bool allGranted = true;
      for (final permission in permissions) {
        if (!statuses[permission]!.isGranted) {
          allGranted = false;
          debugPrint('Permission ${permission.toString()} refusée');
        }
      }
      
      return allGranted;
    } catch (e) {
      debugPrint('Erreur demande permissions: $e');
      return false;
    }
  }
  
  static Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }
  
  static Future<bool> isStoragePermissionGranted() async {
    final status = await Permission.storage.status;
    return status.isGranted;
  }
  
  static Future<bool> isLocationPermissionGranted() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }
  
  static Future<bool> isSensorsPermissionGranted() async {
    final status = await Permission.sensors.status;
    return status.isGranted;
  }
  
  static Future<Map<Permission, bool>> getPermissionStatus() async {
    final permissions = [
      Permission.camera,
      Permission.storage,
      Permission.location,
      Permission.sensors,
    ];
    
    final Map<Permission, bool> result = {};
    
    for (final permission in permissions) {
      final status = await permission.status;
      result[permission] = status.isGranted;
    }
    
    return result;
  }
  
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
  
  static Future<bool> shouldShowRequestRationale(Permission permission) async {
    return await permission.shouldShowRequestRationale;
  }
  
  static Future<bool> canScanInstruments() async {
    final cameraGranted = await isCameraPermissionGranted();
    final storageGranted = await isStoragePermissionGranted();
    
    return cameraGranted && storageGranted;
  }
  
  static Future<PermissionCheckResult> checkScanPermissions() async {
    final cameraGranted = await isCameraPermissionGranted();
    final storageGranted = await isStoragePermissionGranted();
    final sensorsGranted = await isSensorsPermissionGranted();
    
    final missingPermissions = <Permission>[];
    
    if (!cameraGranted) missingPermissions.add(Permission.camera);
    if (!storageGranted) missingPermissions.add(Permission.storage);
    if (!sensorsGranted) missingPermissions.add(Permission.sensors);
    
    return PermissionCheckResult(
      canScan: missingPermissions.isEmpty,
      missingPermissions: missingPermissions,
    );
  }
}

class PermissionCheckResult {
  final bool canScan;
  final List<Permission> missingPermissions;
  
  PermissionCheckResult({
    required this.canScan,
    required this.missingPermissions,
  });
  
  String get missingPermissionsText {
    return missingPermissions
        .map((p) => _getPermissionName(p))
        .join(', ');
  }
  
  String _getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Caméra';
      case Permission.storage:
        return 'Stockage';
      case Permission.location:
        return 'Localisation';
      case Permission.sensors:
        return 'Capteurs';
      default:
        return permission.toString();
    }
  }
}