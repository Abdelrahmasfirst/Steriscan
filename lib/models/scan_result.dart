import 'instrument.dart';

/// The result of scanning a surgical kit.
class ScanResult {
  final String id;
  final String kitId;
  final String kitName;
  final DateTime timestamp;
  final List<Instrument> detectedInstruments;
  final List<Instrument> referenceInstruments;
  final double conformityScore;
  final bool isConformant;
  final String? operatorName;
  final String? notes;

  const ScanResult({
    required this.id,
    required this.kitId,
    required this.kitName,
    required this.timestamp,
    required this.detectedInstruments,
    required this.referenceInstruments,
    required this.conformityScore,
    required this.isConformant,
    this.operatorName,
    this.notes,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) => ScanResult(
        id: json['id'] as String,
        kitId: json['kitId'] as String,
        kitName: json['kitName'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        detectedInstruments: (json['detectedInstruments'] as List<dynamic>)
            .map((e) => Instrument.fromJson(e as Map<String, dynamic>))
            .toList(),
        referenceInstruments: (json['referenceInstruments'] as List<dynamic>)
            .map((e) => Instrument.fromJson(e as Map<String, dynamic>))
            .toList(),
        conformityScore:
            (json['conformityScore'] as num?)?.toDouble() ?? 0.0,
        isConformant: json['isConformant'] as bool? ?? false,
        operatorName: json['operatorName'] as String?,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'kitId': kitId,
        'kitName': kitName,
        'timestamp': timestamp.toIso8601String(),
        'detectedInstruments':
            detectedInstruments.map((e) => e.toJson()).toList(),
        'referenceInstruments':
            referenceInstruments.map((e) => e.toJson()).toList(),
        'conformityScore': conformityScore,
        'isConformant': isConformant,
        if (operatorName != null) 'operatorName': operatorName,
        if (notes != null) 'notes': notes,
      };

  /// Instruments that are in the reference but not detected.
  List<Instrument> get missingInstruments => detectedInstruments
      .where((i) => i.status == InstrumentStatus.missing)
      .toList();

  /// Instruments detected but not in the reference.
  List<Instrument> get extraInstruments => detectedInstruments
      .where((i) => i.status == InstrumentStatus.extra)
      .toList();

  /// Instruments correctly present.
  List<Instrument> get presentInstruments => detectedInstruments
      .where((i) => i.status == InstrumentStatus.present)
      .toList();
}
