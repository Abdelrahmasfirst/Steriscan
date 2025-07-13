import 'package:flutter/foundation.dart';
import '../core/models/instrument.dart';
import '../core/services/database_service.dart';
import '../core/services/auth_service.dart';

class InstrumentProvider extends ChangeNotifier {
  List<Instrument> _instruments = [];
  List<Instrument> _filteredInstruments = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedType = 'all';
  String _sortBy = 'name';
  bool _sortAscending = true;
  
  // Getters
  List<Instrument> get instruments => List.unmodifiable(_filteredInstruments);
  List<Instrument> get allInstruments => List.unmodifiable(_instruments);
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedType => _selectedType;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  
  int get totalInstruments => _instruments.length;
  int get filteredCount => _filteredInstruments.length;
  
  List<String> get availableTypes {
    final types = _instruments.map((i) => i.type).toSet().toList();
    types.sort();
    return ['all', ...types];
  }
  
  Map<String, int> get typeDistribution {
    final distribution = <String, int>{};
    for (final instrument in _instruments) {
      distribution[instrument.type] = (distribution[instrument.type] ?? 0) + 1;
    }
    return distribution;
  }
  
  InstrumentProvider() {
    _initialize();
  }
  
  Future<void> _initialize() async {
    await loadInstruments();
  }
  
  Future<void> loadInstruments() async {
    _setLoading(true);
    
    try {
      _instruments = await DatabaseService.getInstruments();
      _applyFilters();
    } catch (e) {
      debugPrint('Erreur chargement instruments: $e');
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
    List<Instrument> filtered = List.from(_instruments);
    
    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((instrument) {
        final query = _searchQuery.toLowerCase();
        return instrument.name.toLowerCase().contains(query) ||
               instrument.type.toLowerCase().contains(query) ||
               (instrument.manufacturer?.toLowerCase().contains(query) ?? false) ||
               (instrument.model?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    
    // Filtrer par type
    if (_selectedType != 'all') {
      filtered = filtered.where((instrument) => 
        instrument.type == _selectedType
      ).toList();
    }
    
    // Trier
    filtered.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'type':
          comparison = a.type.compareTo(b.type);
          break;
        case 'manufacturer':
          comparison = (a.manufacturer ?? '').compareTo(b.manufacturer ?? '');
          break;
        case 'created':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'updated':
          comparison = a.updatedAt.compareTo(b.updatedAt);
          break;
      }
      
      return _sortAscending ? comparison : -comparison;
    });
    
    _filteredInstruments = filtered;
    notifyListeners();
  }
  
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }
  
  void filterByType(String type) {
    _selectedType = type;
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
    _selectedType = 'all';
    _sortBy = 'name';
    _sortAscending = true;
    _applyFilters();
  }
  
  Instrument? getInstrumentById(String id) {
    try {
      return _instruments.firstWhere((instrument) => instrument.id == id);
    } catch (e) {
      return null;
    }
  }
  
  List<Instrument> getInstrumentsByType(String type) {
    return _instruments.where((instrument) => instrument.type == type).toList();
  }
  
  List<Instrument> getInstrumentsByManufacturer(String manufacturer) {
    return _instruments.where((instrument) => 
      instrument.manufacturer == manufacturer
    ).toList();
  }
  
  Future<bool> addInstrument(Instrument instrument) async {
    // Vérifier les permissions
    if (!AuthService.hasPermission(Permission.manageInstruments)) {
      debugPrint('Permission refusée pour ajouter un instrument');
      return false;
    }
    
    _setLoading(true);
    
    try {
      await DatabaseService.insertInstrument(instrument);
      _instruments.add(instrument);
      _applyFilters();
      return true;
    } catch (e) {
      debugPrint('Erreur ajout instrument: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> updateInstrument(Instrument instrument) async {
    // Vérifier les permissions
    if (!AuthService.hasPermission(Permission.manageInstruments)) {
      debugPrint('Permission refusée pour modifier un instrument');
      return false;
    }
    
    _setLoading(true);
    
    try {
      final updatedInstrument = instrument.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await DatabaseService.updateInstrument(updatedInstrument);
      
      final index = _instruments.indexWhere((i) => i.id == instrument.id);
      if (index != -1) {
        _instruments[index] = updatedInstrument;
        _applyFilters();
      }
      
      return true;
    } catch (e) {
      debugPrint('Erreur mise à jour instrument: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> deleteInstrument(String id) async {
    // Vérifier les permissions
    if (!AuthService.hasPermission(Permission.manageInstruments)) {
      debugPrint('Permission refusée pour supprimer un instrument');
      return false;
    }
    
    _setLoading(true);
    
    try {
      await DatabaseService.deleteInstrument(id);
      _instruments.removeWhere((instrument) => instrument.id == id);
      _applyFilters();
      return true;
    } catch (e) {
      debugPrint('Erreur suppression instrument: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> duplicateInstrument(String id) async {
    // Vérifier les permissions
    if (!AuthService.hasPermission(Permission.manageInstruments)) {
      debugPrint('Permission refusée pour dupliquer un instrument');
      return false;
    }
    
    final original = getInstrumentById(id);
    if (original == null) return false;
    
    final duplicate = original.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${original.name} (Copie)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    return await addInstrument(duplicate);
  }
  
  Future<void> refresh() async {
    await loadInstruments();
  }
  
  // Statistiques
  Map<String, dynamic> get statistics => {
    'totalInstruments': totalInstruments,
    'filteredCount': filteredCount,
    'typeDistribution': typeDistribution,
    'availableTypes': availableTypes.length - 1, // -1 pour exclure 'all'
    'searchActive': _searchQuery.isNotEmpty,
    'filterActive': _selectedType != 'all',
  };
  
  // Méthodes de recherche avancée
  List<Instrument> findSimilarInstruments(Instrument instrument) {
    return _instruments.where((i) => 
      i.id != instrument.id &&
      (i.type == instrument.type || 
       i.manufacturer == instrument.manufacturer ||
       i.name.toLowerCase().contains(instrument.name.toLowerCase()))
    ).toList();
  }
  
  List<Instrument> searchInstruments({
    String? name,
    String? type,
    String? manufacturer,
    String? model,
  }) {
    return _instruments.where((instrument) {
      if (name != null && !instrument.name.toLowerCase().contains(name.toLowerCase())) {
        return false;
      }
      if (type != null && instrument.type != type) {
        return false;
      }
      if (manufacturer != null && instrument.manufacturer != manufacturer) {
        return false;
      }
      if (model != null && instrument.model != model) {
        return false;
      }
      return true;
    }).toList();
  }
  
  // Diagnostic
  Map<String, dynamic> get diagnosticInfo => {
    'totalInstruments': totalInstruments,
    'filteredCount': filteredCount,
    'isLoading': _isLoading,
    'searchQuery': _searchQuery,
    'selectedType': _selectedType,
    'sortBy': _sortBy,
    'sortAscending': _sortAscending,
    'typeDistribution': typeDistribution,
    'statistics': statistics,
    'timestamp': DateTime.now().toIso8601String(),
  };
  
  void logDiagnostic() {
    debugPrint('=== DIAGNOSTIC INSTRUMENT PROVIDER ===');
    debugPrint(diagnosticInfo.toString());
    debugPrint('=====================================');
  }
}