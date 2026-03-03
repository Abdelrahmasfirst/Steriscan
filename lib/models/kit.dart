import 'instrument.dart';

/// A surgical instrument kit with its reference composition.
class Kit {
  final String id;
  final String name;
  final String? department;
  final List<Instrument> referenceInstruments;
  final DateTime? lastVerified;
  final String? notes;

  const Kit({
    required this.id,
    required this.name,
    this.department,
    required this.referenceInstruments,
    this.lastVerified,
    this.notes,
  });

  factory Kit.fromJson(Map<String, dynamic> json) => Kit(
        id: json['id'] as String,
        name: json['name'] as String,
        department: json['department'] as String?,
        referenceInstruments: (json['referenceInstruments'] as List<dynamic>)
            .map((e) => Instrument.fromJson(e as Map<String, dynamic>))
            .toList(),
        lastVerified: json['lastVerified'] != null
            ? DateTime.parse(json['lastVerified'] as String)
            : null,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (department != null) 'department': department,
        'referenceInstruments':
            referenceInstruments.map((e) => e.toJson()).toList(),
        if (lastVerified != null)
          'lastVerified': lastVerified!.toIso8601String(),
        if (notes != null) 'notes': notes,
      };

  int get totalInstruments => referenceInstruments.length;
}
