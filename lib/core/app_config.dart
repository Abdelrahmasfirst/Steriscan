import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppConfig {
  static const String _keyLanguage = 'app_language';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyOfflineMode = 'offline_mode';
  static const String _keyAutoSync = 'auto_sync';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyVibration = 'vibration_enabled';
  static const String _keySound = 'sound_enabled';
  static const String _keyConfidenceThreshold = 'confidence_threshold';
  static const String _keyMaxScanTime = 'max_scan_time';
  static const String _keyScanQuality = 'scan_quality';
  
  static String _appName = 'SteriScan 3D';
  static String _appVersion = '1.0.0';
  static String _buildNumber = '1';
  static String _deviceModel = '';
  static String _deviceOS = '';
  static String _deviceId = '';
  
  static String _language = 'fr';
  static String _themeMode = 'system';
  static bool _isFirstLaunch = true;
  static bool _offlineMode = false;
  static bool _autoSync = true;
  static bool _notificationsEnabled = true;
  static bool _vibrationEnabled = true;
  static bool _soundEnabled = true;
  static double _confidenceThreshold = 0.85;
  static int _maxScanTime = 30;
  static ScanQuality _scanQuality = ScanQuality.medium;
  
  static Future<void> initialize() async {
    try {
      await _loadAppInfo();
      await _loadDeviceInfo();
      await _loadSettings();
    } catch (e) {
      debugPrint('Erreur initialisation AppConfig: $e');
    }
  }
  
  static Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appName = packageInfo.appName;
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    } catch (e) {
      debugPrint('Erreur chargement info app: $e');
    }
  }
  
  static Future<void> _loadDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
        _deviceOS = 'Android ${androidInfo.version.release}';
        _deviceId = androidInfo.id;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceModel = '${iosInfo.model} ${iosInfo.name}';
        _deviceOS = 'iOS ${iosInfo.systemVersion}';
        _deviceId = iosInfo.identifierForVendor ?? '';
      }
    } catch (e) {
      debugPrint('Erreur chargement info device: $e');
    }
  }
  
  static Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _language = prefs.getString(_keyLanguage) ?? 'fr';
      _themeMode = prefs.getString(_keyThemeMode) ?? 'system';
      _isFirstLaunch = prefs.getBool(_keyFirstLaunch) ?? true;
      _offlineMode = prefs.getBool(_keyOfflineMode) ?? false;
      _autoSync = prefs.getBool(_keyAutoSync) ?? true;
      _notificationsEnabled = prefs.getBool(_keyNotifications) ?? true;
      _vibrationEnabled = prefs.getBool(_keyVibration) ?? true;
      _soundEnabled = prefs.getBool(_keySound) ?? true;
      _confidenceThreshold = prefs.getDouble(_keyConfidenceThreshold) ?? 0.85;
      _maxScanTime = prefs.getInt(_keyMaxScanTime) ?? 30;
      
      final scanQualityString = prefs.getString(_keyScanQuality) ?? 'medium';
      _scanQuality = ScanQuality.values.firstWhere(
        (quality) => quality.toString().split('.').last == scanQualityString,
        orElse: () => ScanQuality.medium,
      );
      
    } catch (e) {
      debugPrint('Erreur chargement paramètres: $e');
    }
  }
  
  // Getters
  static String get appName => _appName;
  static String get appVersion => _appVersion;
  static String get buildNumber => _buildNumber;
  static String get fullVersion => '$_appVersion+$_buildNumber';
  static String get deviceModel => _deviceModel;
  static String get deviceOS => _deviceOS;
  static String get deviceId => _deviceId;
  
  static String get language => _language;
  static String get themeMode => _themeMode;
  static bool get isFirstLaunch => _isFirstLaunch;
  static bool get offlineMode => _offlineMode;
  static bool get autoSync => _autoSync;
  static bool get notificationsEnabled => _notificationsEnabled;
  static bool get vibrationEnabled => _vibrationEnabled;
  static bool get soundEnabled => _soundEnabled;
  static double get confidenceThreshold => _confidenceThreshold;
  static int get maxScanTime => _maxScanTime;
  static ScanQuality get scanQuality => _scanQuality;
  
  // Setters
  static Future<void> setLanguage(String language) async {
    _language = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, language);
  }
  
  static Future<void> setThemeMode(String themeMode) async {
    _themeMode = themeMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, themeMode);
  }
  
  static Future<void> setFirstLaunch(bool isFirst) async {
    _isFirstLaunch = isFirst;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstLaunch, isFirst);
  }
  
  static Future<void> setOfflineMode(bool enabled) async {
    _offlineMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOfflineMode, enabled);
  }
  
  static Future<void> setAutoSync(bool enabled) async {
    _autoSync = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoSync, enabled);
  }
  
  static Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, enabled);
  }
  
  static Future<void> setVibrationEnabled(bool enabled) async {
    _vibrationEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVibration, enabled);
  }
  
  static Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySound, enabled);
  }
  
  static Future<void> setConfidenceThreshold(double threshold) async {
    _confidenceThreshold = threshold;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyConfidenceThreshold, threshold);
  }
  
  static Future<void> setMaxScanTime(int seconds) async {
    _maxScanTime = seconds;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMaxScanTime, seconds);
  }
  
  static Future<void> setScanQuality(ScanQuality quality) async {
    _scanQuality = quality;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyScanQuality, quality.toString().split('.').last);
  }
  
  // Méthodes utilitaires
  static bool get isDebugMode => kDebugMode;
  
  static bool get isProductionMode => kReleaseMode;
  
  static Map<String, dynamic> get systemInfo => {
    'appName': _appName,
    'appVersion': _appVersion,
    'buildNumber': _buildNumber,
    'deviceModel': _deviceModel,
    'deviceOS': _deviceOS,
    'deviceId': _deviceId,
    'language': _language,
    'themeMode': _themeMode,
    'offlineMode': _offlineMode,
    'debugMode': isDebugMode,
  };
  
  static Map<String, dynamic> get userSettings => {
    'language': _language,
    'themeMode': _themeMode,
    'offlineMode': _offlineMode,
    'autoSync': _autoSync,
    'notificationsEnabled': _notificationsEnabled,
    'vibrationEnabled': _vibrationEnabled,
    'soundEnabled': _soundEnabled,
    'confidenceThreshold': _confidenceThreshold,
    'maxScanTime': _maxScanTime,
    'scanQuality': _scanQuality.toString().split('.').last,
  };
  
  static ScanSettings get scanSettings => ScanSettings(
    confidenceThreshold: _confidenceThreshold,
    maxScanTime: _maxScanTime,
    quality: _scanQuality,
    vibrationEnabled: _vibrationEnabled,
    soundEnabled: _soundEnabled,
  );
  
  static Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Réinitialiser tous les paramètres
    await prefs.remove(_keyLanguage);
    await prefs.remove(_keyThemeMode);
    await prefs.remove(_keyOfflineMode);
    await prefs.remove(_keyAutoSync);
    await prefs.remove(_keyNotifications);
    await prefs.remove(_keyVibration);
    await prefs.remove(_keySound);
    await prefs.remove(_keyConfidenceThreshold);
    await prefs.remove(_keyMaxScanTime);
    await prefs.remove(_keyScanQuality);
    
    // Recharger les paramètres
    await _loadSettings();
  }
}

enum ScanQuality {
  low,
  medium,
  high,
  ultra,
}

class ScanSettings {
  final double confidenceThreshold;
  final int maxScanTime;
  final ScanQuality quality;
  final bool vibrationEnabled;
  final bool soundEnabled;
  
  ScanSettings({
    required this.confidenceThreshold,
    required this.maxScanTime,
    required this.quality,
    required this.vibrationEnabled,
    required this.soundEnabled,
  });
  
  int get pointCloudTarget {
    switch (quality) {
      case ScanQuality.low:
        return 5000;
      case ScanQuality.medium:
        return 10000;
      case ScanQuality.high:
        return 15000;
      case ScanQuality.ultra:
        return 20000;
    }
  }
  
  String get qualityDisplayName {
    switch (quality) {
      case ScanQuality.low:
        return 'Faible';
      case ScanQuality.medium:
        return 'Moyenne';
      case ScanQuality.high:
        return 'Élevée';
      case ScanQuality.ultra:
        return 'Ultra';
    }
  }
}