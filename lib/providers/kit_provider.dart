import 'package:flutter/foundation.dart';
import '../core/models/kit.dart';
import '../core/models/instrument.dart';
import '../core/services/database_service.dart';
import '../core/services/auth_service.dart';

class KitProvider extends ChangeNotifier {
  List<Kit> _kits = [];
  List<Kit> _filteredKits = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _sortBy = 'name';
  bool _sortAscending = true;
  
  // Cache pour les instruments des kits
  Map<String, List<Instrument>> _kitInstruments = {};
  
  // Getters
  List<Kit> get kits => List.unmodifiable(_filteredKits);
  List<Kit> get allKits => List.unmodifiable(_kits);
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  
  int get totalKits => _kits.length;
  int get filteredCount => _filteredKits.length;
  
  KitProvider() {
    _initialize();
  }
  
  Future<void> _initialize() async {
    await loadKits();
  }
  
  Future<void> loadKits() async {
    _setLoading(true);
    
    try {
      _kits = await DatabaseService.getKits();
      _applyFilters();
    } catch (e) {
      debugPrint('Erreur chargement kits: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
  
  void _applyFilters() {
    List<Kit> filtered = List.from(_kits);
    
    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((kit) {
        final query = _searchQuery.toLowerCase();
        return kit.name.toLowerCase().contains(query) ||
               (kit.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    
    // Trier
    filtered.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'created':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'updated':
          comparison = a.updatedAt.compareTo(b.updatedAt);
          break;
        case 'instruments':
          comparison = a.instrumentIds.length.compareTo(b.instrumentIds.length);
          break;
      }
      
      return _sortAscending ? comparison : -comparison;
    });
    
    _filteredKits = filtered;
    notifyListeners();
  }
  
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }
  
  void sortBy(String field, {bool? ascending}) {
    _sortBy = field;
    if (ascending != null) {
      _sortAscending = ascending;
    } else {
      // Toggle si même field
      if (_sortBy == field) {
        _sortAscending = !_sortAscending;
      } else {
        _sortAscending = true;
      }
    }
    _applyFilters();
  }
  
  void clearFilters() {
    _searchQuery = '';
    _sortBy = 'name';
    _sortAscending = true;
    _applyFilters();
  }
  
  Kit? getKitById(String id) {
    try {
      return _kits.firstWhere((kit) => kit.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Future<List<Instrument>> getKitInstruments(String kitId) async {
    // Vérifier le cache
    if (_kitInstruments.containsKey(kitId)) {
      return _kitInstruments[kitId]!;
    }
    
    try {
      final kit = getKitById(kitId);
      if (kit == null) return [];
      
      final instruments = <Instrument>[];
      for (final instrumentId in kit.instrumentIds) {
        final instrument = await DatabaseService.getInstrument(instrumentId);
        if (instrument != null) {
          instruments.add(instrument);
        }
      }
      
      // Mettre en cache
      _kitInstruments[kitId] = instruments;
      return instruments;
    } catch (e) {
      debugPrint('Erreur chargement instruments du kit: $e');
      return [];
    }
  }
  
  Future<bool> addKit(Kit kit) async {
    // Vérifier les permissions
    if (!AuthService.hasPermission(Permission.manageKits)) {
      debugPrint('Permission refusée pour ajouter un kit');
      return false;
    }
    
    _setLoading(true);
    
    try {
      await DatabaseService.insertKit(kit);
      _kits.add(kit);
      _applyFilters();
      return true;
    } catch (e) {
      debugPrint('Erreur ajout kit: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> updateKit(Kit kit) async {
    // Vérifier les permissions
    if (!AuthService.hasPermission(Permission.manageKits)) {
      debugPrint('Permission refusée pour modifier un kit');
      return false;
    }
    
    _setLoading(true);
    
    try {
      final updatedKit = kit.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await DatabaseService.updateKit(updatedKit);
      
      final index = _kits.indexWhere((k) => k.id == kit.id);
      if (index != -1) {
        _kits[index] = updatedKit;
        _applyFilters();
        
        // Invalider le cache
        _kitInstruments.remove(kit.id);
      }
      
      return true;
    } catch (e) {
      debugPrint('Erreur mise à jour kit: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> deleteKit(String id) async {
    // Vérifier les permissions
    if (!AuthService.hasPermission(Permission.manageKits)) {
      debugPrint('Permission refusée pour supprimer un kit');
      return false;
    }
    
    _setLoading(true);
    
    try {
      await DatabaseService.deleteKit(id);
      _kits.removeWhere((kit) => kit.id == id);
      _applyFilters();
      
      // Nettoyer le cache
      _kitInstruments.remove(id);
      
      return true;
    } catch (e) {
      debugPrint('Erreur suppression kit: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> duplicateKit(String id) async {
    // Vérifier les permissions
    if (!AuthService.hasPermission(Permission.manageKits)) {
      debugPrint('Permission refusée pour dupliquer un kit');
      return false;
    }
    
    final original = getKitById(id);
    if (original == null) return false;
    
    final duplicate = Kit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${original.name} (Copie)',
      description: original.description,
      instrumentIds: List.from(original.instrumentIds),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    return await addKit(duplicate);
  }
  
  Future<bool> addInstrumentToKit(String kitId, String instrumentId) async {
    final kit = getKitById(kitId);
    if (kit == null) return false;
    
    if (kit.instrumentIds.contains(instrumentId)) {
      return false; // Déjà présent
    }
    
    final updatedKit = Kit(
      id: kit.id,
      name: kit.name,
      description: kit.description,
      instrumentIds: [...kit.instrumentIds, instrumentId],
      createdAt: kit.createdAt,
      updatedAt: DateTime.now(),
    );
    
    return await updateKit(updatedKit);
  }
  
  Future<bool> removeInstrumentFromKit(String kitId, String instrumentId) async {
    final kit = getKitById(kitId);
    if (kit == null) return false;
    
    if (!kit.instrumentIds.contains(instrumentId)) {
      return false; // Pas présent
    }
    
    final updatedInstruments = List<String>.from(kit.instrumentIds);
    updatedInstruments.remove(instrumentId);
    
    final updatedKit = Kit(
      id: kit.id,
      name: kit.name,
      description: kit.description,
      instrumentIds: updatedInstruments,
      createdAt: kit.createdAt,
      updatedAt: DateTime.now(),
    );
    
    return await updateKit(updatedKit);
  }
  
  Future<Kit?> createKitFromInstruments(
    String name, 
    String? description, 
    List<String> instrumentIds
  ) async {
    if (instrumentIds.isEmpty) return null;
    
    final kit = Kit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      instrumentIds: instrumentIds,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    final success = await addKit(kit);
    return success ? kit : null;
  }
  
  Future<List<Kit>> findKitsContainingInstrument(String instrumentId) async {
    return _kits.where((kit) => 
      kit.instrumentIds.contains(instrumentId)
    ).toList();
  }
  
  Future<List<Kit>> findSimilarKits(Kit kit) async {
    return _kits.where((k) => 
      k.id != kit.id &&
      k.name.toLowerCase().contains(kit.name.toLowerCase())
    ).toList();
  }
  
  Future<KitCompleteness> checkKitCompleteness(
    String kitId, 
    List<String> scannedInstrumentIds
  ) async {
    final kit = getKitById(kitId);
    if (kit == null) {
      return KitCompleteness(
        isComplete: false,
        missingInstruments: [],
        extraInstruments: [],
        completenessPercentage: 0.0,
      );
    }
    
    final expected = Set<String>.from(kit.instrumentIds);
    final scanned = Set<String>.from(scannedInstrumentIds);
    
    final missing = expected.difference(scanned).toList();
    final extra = scanned.difference(expected).toList();
    
    final completeness = expected.isEmpty ? 1.0 : 
      scanned.intersection(expected).length / expected.length;
    
    return KitCompleteness(
      isComplete: missing.isEmpty && extra.isEmpty,
      missingInstruments: missing,
      extraInstruments: extra,
      completenessPercentage: completeness,
    );
  }
  
  Future<void> refresh() async {
    await loadKits();
    _kitInstruments.clear(); // Nettoyer le cache
  }
  
  // Statistiques
  Map<String, dynamic> get statistics => {
    'totalKits': totalKits,
    'filteredCount': filteredCount,
    'averageInstrumentsPerKit': _kits.isEmpty ? 0.0 : 
      _kits.fold<int>(0, (sum, kit) => sum + kit.instrumentIds.length) / _kits.length,
    'searchActive': _searchQuery.isNotEmpty,
  };
  
  // Diagnostic
  Map<String, dynamic> get diagnosticInfo => {
    'totalKits': totalKits,
    'filteredCount': filteredCount,
    'isLoading': _isLoading,
    'searchQuery': _searchQuery,
    'sortBy': _sortBy,
    'sortAscending': _sortAscending,
    'cacheSize': _kitInstruments.length,
    'statistics': statistics,
    'timestamp': DateTime.now().toIso8601String(),
  };
  
  void logDiagnostic() {
    debugPrint('=== DIAGNOSTIC KIT PROVIDER ===');
    debugPrint(diagnosticInfo.toString());
    debugPrint('==============================');
  }
}

// Extension pour Kit
extension KitExtension on Kit {
  Kit copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? instrumentIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Kit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      instrumentIds: instrumentIds ?? this.instrumentIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Classe pour vérifier la complétude d'un kit
class KitCompleteness {
  final bool isComplete;
  final List<String> missingInstruments;
  final List<String> extraInstruments;
  final double completenessPercentage;
  
  KitCompleteness({
    required this.isComplete,
    required this.missingInstruments,
    required this.extraInstruments,
    required this.completenessPercentage,
  });
  
  String get statusText {
    if (isComplete) {
      return 'Kit complet';
    } else if (missingInstruments.isNotEmpty && extraInstruments.isNotEmpty) {
      return 'Instruments manquants et en trop';
    } else if (missingInstruments.isNotEmpty) {
      return 'Instruments manquants';
    } else if (extraInstruments.isNotEmpty) {
      return 'Instruments en trop';
    }
    return 'Statut inconnu';
  }
  
  String get completenessText => 
    '${(completenessPercentage * 100).toStringAsFixed(1)}%';
}