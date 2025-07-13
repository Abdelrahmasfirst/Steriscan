import 'package:flutter/foundation.dart';
import 'dart:async';
import '../core/services/scan_service.dart';
import '../core/services/thermal_service.dart';
import '../core/services/permission_service.dart';
import '../core/models/scan_result.dart';
import '../core/models/instrument.dart';
import '../core/app_config.dart';

class ScanProvider extends ChangeNotifier {
  bool _isScanning = false;
  bool _isProcessing = false;
  bool _canScan = false;
  int _pointCount = 0;
  double _progress = 0.0;
  String _status = 'Prêt';
  ScanResult? _currentScanResult;
  Instrument? _identifiedInstrument;
  List<ScanResult> _scanHistory = [];
  StreamSubscription? _scanSubscription;
  Timer? _scanTimer;
  
  // Configuration de scan
  ScanSettings? _scanSettings;
  
  // Getters
  bool get isScanning => _isScanning;
  bool get isProcessing => _isProcessing;
  bool get canScan => _canScan;
  int get pointCount => _pointCount;
  double get progress => _progress;
  String get status => _status;
  ScanResult? get currentScanResult => _currentScanResult;
  Instrument? get identifiedInstrument => _identifiedInstrument;
  List<ScanResult> get scanHistory => List.unmodifiable(_scanHistory);
  
  double get confidenceThreshold => _scanSettings?.confidenceThreshold ?? 0.85;
  int get maxScanTime => _scanSettings?.maxScanTime ?? 30;
  
  ScanProvider() {
    _initialize();
  }
  
  Future<void> _initialize() async {
    try {
      // Charger les paramètres de scan
      _scanSettings = AppConfig.scanSettings;
      
      // Vérifier les permissions
      await _checkPermissions();
      
      // Écouter les changements de température
      ThermalService.temperatureStream.listen((temp) {
        _updateCanScan();
      });
      
    } catch (e) {
      debugPrint('Erreur initialisation ScanProvider: $e');
    }
  }
  
  Future<void> _checkPermissions() async {
    try {
      final result = await PermissionService.checkScanPermissions();
      _canScan = result.canScan && ThermalService.canPerformScan();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur vérification permissions: $e');
      _canScan = false;
    }
  }
  
  void _updateCanScan() {
    final previousCanScan = _canScan;
    _canScan = ThermalService.canPerformScan() && !_isScanning;
    
    if (previousCanScan != _canScan) {
      notifyListeners();
    }
  }
  
  Future<bool> startScan() async {
    if (_isScanning || !_canScan) return false;
    
    try {
      // Vérifier les permissions
      final permissionResult = await PermissionService.checkScanPermissions();
      if (!permissionResult.canScan) {
        _status = 'Permissions manquantes: ${permissionResult.missingPermissionsText}';
        notifyListeners();
        return false;
      }
      
      // Vérifier la température
      if (!ThermalService.canPerformScan()) {
        _status = 'Température trop élevée pour scanner';
        notifyListeners();
        return false;
      }
      
      // Démarrer le scan
      _isScanning = true;
      _isProcessing = false;
      _progress = 0.0;
      _pointCount = 0;
      _status = 'Scan en cours...';
      _currentScanResult = null;
      _identifiedInstrument = null;
      
      notifyListeners();
      
      // Démarrer le timer de progression
      _startProgressTimer();
      
      // Lancer le scan
      final result = await ScanService.startScan();
      
      if (result != null) {
        _currentScanResult = result;
        _status = 'Scan terminé - Identification...';
        _isProcessing = true;
        notifyListeners();
        
        // Identifier l'instrument
        await _identifyInstrument(result);
        
        // Ajouter à l'historique
        _scanHistory.insert(0, result);
        if (_scanHistory.length > 50) {
          _scanHistory.removeLast();
        }
        
        _status = 'Scan terminé avec succès';
        _isProcessing = false;
        
      } else {
        _status = 'Échec du scan';
      }
      
      return result != null;
      
    } catch (e) {
      debugPrint('Erreur lors du scan: $e');
      _status = 'Erreur lors du scan: ${e.toString()}';
      return false;
    } finally {
      _isScanning = false;
      _isProcessing = false;
      _scanTimer?.cancel();
      _updateCanScan();
      notifyListeners();
    }
  }
  
  void _startProgressTimer() {
    _scanTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (!_isScanning) {
        timer.cancel();
        return;
      }
      
      _pointCount = ScanService.pointCount;
      _progress = (_pointCount / (_scanSettings?.pointCloudTarget ?? 10000)).clamp(0.0, 1.0);
      
      // Mettre à jour le statut
      final target = _scanSettings?.pointCloudTarget ?? 10000;
      _status = 'Scan en cours... $_pointCount/$target points';
      
      notifyListeners();
    });
  }
  
  Future<void> _identifyInstrument(ScanResult scanResult) async {
    try {
      _identifiedInstrument = await ScanService.identifyInstrument(scanResult.scanData);
      
      if (_identifiedInstrument != null) {
        _status = 'Instrument identifié: ${_identifiedInstrument!.name}';
        
        // Mettre à jour le résultat avec l'ID de l'instrument
        _currentScanResult = ScanResult(
          id: scanResult.id,
          instrumentId: _identifiedInstrument!.id,
          scanData: scanResult.scanData,
          confidenceScore: scanResult.confidenceScore,
          processingTime: scanResult.processingTime,
          createdAt: scanResult.createdAt,
        );
      } else {
        _status = 'Instrument non identifié';
      }
    } catch (e) {
      debugPrint('Erreur identification instrument: $e');
      _status = 'Erreur lors de l\'identification';
    }
  }
  
  Future<void> stopScan() async {
    if (_isScanning) {
      await ScanService.stopScan();
      _isScanning = false;
      _isProcessing = false;
      _scanTimer?.cancel();
      _status = 'Scan arrêté';
      _updateCanScan();
      notifyListeners();
    }
  }
  
  Future<void> requestPermissions() async {
    try {
      final granted = await PermissionService.requestAllPermissions();
      if (granted) {
        await _checkPermissions();
        _status = 'Permissions accordées';
      } else {
        _status = 'Permissions refusées';
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur demande permissions: $e');
      _status = 'Erreur lors de la demande de permissions';
      notifyListeners();
    }
  }
  
  void clearCurrentScan() {
    _currentScanResult = null;
    _identifiedInstrument = null;
    _progress = 0.0;
    _pointCount = 0;
    _status = 'Prêt';
    notifyListeners();
  }
  
  void clearHistory() {
    _scanHistory.clear();
    notifyListeners();
  }
  
  ScanResult? getScanById(String id) {
    try {
      return _scanHistory.firstWhere((scan) => scan.id == id);
    } catch (e) {
      return null;
    }
  }
  
  List<ScanResult> getSuccessfulScans() {
    return _scanHistory.where((scan) => 
      scan.confidenceScore >= confidenceThreshold
    ).toList();
  }
  
  List<ScanResult> getFailedScans() {
    return _scanHistory.where((scan) => 
      scan.confidenceScore < confidenceThreshold
    ).toList();
  }
  
  double get averageConfidence {
    if (_scanHistory.isEmpty) return 0.0;
    final sum = _scanHistory.fold<double>(0, (sum, scan) => sum + scan.confidenceScore);
    return sum / _scanHistory.length;
  }
  
  int get totalScans => _scanHistory.length;
  int get successfulScans => getSuccessfulScans().length;
  int get failedScans => getFailedScans().length;
  
  double get successRate => totalScans > 0 ? successfulScans / totalScans : 0.0;
  
  // Méthodes de configuration
  Future<void> updateScanSettings(ScanSettings settings) async {
    _scanSettings = settings;
    await AppConfig.setScanQuality(settings.quality);
    await AppConfig.setConfidenceThreshold(settings.confidenceThreshold);
    await AppConfig.setMaxScanTime(settings.maxScanTime);
    notifyListeners();
  }
  
  // Diagnostic et debug
  Map<String, dynamic> get diagnosticInfo => {
    'isScanning': _isScanning,
    'isProcessing': _isProcessing,
    'canScan': _canScan,
    'pointCount': _pointCount,
    'progress': _progress,
    'status': _status,
    'currentScanResult': _currentScanResult?.toMap(),
    'identifiedInstrument': _identifiedInstrument?.toMap(),
    'scanHistoryCount': _scanHistory.length,
    'averageConfidence': averageConfidence,
    'successRate': successRate,
    'scanSettings': {
      'confidenceThreshold': confidenceThreshold,
      'maxScanTime': maxScanTime,
      'quality': _scanSettings?.quality.toString(),
    },
    'timestamp': DateTime.now().toIso8601String(),
  };
  
  void logDiagnostic() {
    debugPrint('=== DIAGNOSTIC SCAN PROVIDER ===');
    debugPrint(diagnosticInfo.toString());
    debugPrint('===============================');
  }
  
  @override
  void dispose() {
    _scanTimer?.cancel();
    _scanSubscription?.cancel();
    super.dispose();
  }
}