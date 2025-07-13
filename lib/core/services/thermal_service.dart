import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:battery_plus/battery_plus.dart';

class ThermalService {
  static Battery? _battery;
  static double _currentTemperature = 25.0;
  static Timer? _temperatureTimer;
  static final StreamController<double> _temperatureController = StreamController<double>.broadcast();
  static bool _isInitialized = false;
  
  // Thermal thresholds
  static const double NORMAL_TEMP = 30.0;
  static const double WARNING_TEMP = 40.0;
  static const double CRITICAL_TEMP = 45.0;
  
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _battery = Battery();
      _startTemperatureMonitoring();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Erreur initialisation ThermalService: $e');
    }
  }
  
  static void _startTemperatureMonitoring() {
    _temperatureTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _updateTemperature();
    });
  }
  
  static void _updateTemperature() async {
    try {
      // Simulation de la température basée sur l'utilisation
      final baseTemp = 25.0;
      final usage = DateTime.now().millisecondsSinceEpoch % 1000 / 1000;
      
      // Facteur d'utilisation de la batterie
      final batteryLevel = await _battery?.batteryLevel ?? 100;
      final batteryFactor = (100 - batteryLevel) / 100 * 5; // Max 5° d'augmentation
      
      _currentTemperature = baseTemp + (usage * 15) + batteryFactor; // 25-45°C
      
      // Notifier les listeners
      _temperatureController.add(_currentTemperature);
      
      // Vérifier les seuils critiques
      _checkThermalThresholds();
      
    } catch (e) {
      debugPrint('Erreur mise à jour température: $e');
    }
  }
  
  static void _checkThermalThresholds() {
    if (_currentTemperature >= CRITICAL_TEMP) {
      debugPrint('⚠️ TEMPÉRATURE CRITIQUE: ${_currentTemperature.toStringAsFixed(1)}°C');
      // Déclencher des mesures de protection
    } else if (_currentTemperature >= WARNING_TEMP) {
      debugPrint('⚠️ Température élevée: ${_currentTemperature.toStringAsFixed(1)}°C');
    }
  }
  
  static Future<double> getCurrentTemperature() async {
    return _currentTemperature;
  }
  
  static Stream<double> get temperatureStream => _temperatureController.stream;
  
  static ThermalState getThermalState() {
    if (_currentTemperature >= CRITICAL_TEMP) {
      return ThermalState.critical;
    } else if (_currentTemperature >= WARNING_TEMP) {
      return ThermalState.warning;
    } else if (_currentTemperature >= NORMAL_TEMP) {
      return ThermalState.normal;
    }
    return ThermalState.cool;
  }
  
  static bool canPerformScan() {
    return _currentTemperature < CRITICAL_TEMP;
  }
  
  static Future<void> coolDown() async {
    // Simulation du refroidissement
    final completer = Completer<void>();
    
    Timer.periodic(Duration(seconds: 2), (timer) {
      if (_currentTemperature > NORMAL_TEMP) {
        _currentTemperature -= 1.0;
        _temperatureController.add(_currentTemperature);
      } else {
        timer.cancel();
        completer.complete();
      }
    });
    
    return completer.future;
  }
  
  static Future<void> dispose() async {
    _temperatureTimer?.cancel();
    await _temperatureController.close();
    _isInitialized = false;
  }
}

enum ThermalState {
  cool,
  normal,
  warning,
  critical,
}