import '../models/models.dart';

/// Provides mock/demo data for the application when running offline
/// or without a backend connection.
class MockData {
  MockData._();

  // ── Reference Instruments ───────────────────────────────────────

  static const List<Instrument> referenceInstruments = [
    Instrument(
      id: 'INST-001',
      name: 'Ciseaux de Mayo',
      category: 'Ciseaux',
      status: InstrumentStatus.present,
      confidenceScore: 0.98,
      description: 'Ciseaux chirurgicaux courbes de Mayo, 17 cm',
    ),
    Instrument(
      id: 'INST-002',
      name: 'Pince Hémostatique Kocher',
      category: 'Pinces',
      status: InstrumentStatus.present,
      confidenceScore: 0.97,
      description: 'Pince hémostatique droite de Kocher, 14 cm',
    ),
    Instrument(
      id: 'INST-003',
      name: 'Scalpel #10',
      category: 'Scalpels',
      status: InstrumentStatus.present,
      confidenceScore: 0.99,
      description: 'Manche de scalpel n°3 avec lame #10',
    ),
    Instrument(
      id: 'INST-004',
      name: 'Pince Anatomique',
      category: 'Pinces',
      status: InstrumentStatus.present,
      confidenceScore: 0.96,
      description: 'Pince anatomique standard, 14 cm',
    ),
    Instrument(
      id: 'INST-005',
      name: 'Porte-aiguille de Hegar',
      category: 'Porte-aiguilles',
      status: InstrumentStatus.present,
      confidenceScore: 0.95,
      description: 'Porte-aiguille de Hegar-Mayo, 18 cm',
    ),
    Instrument(
      id: 'INST-006',
      name: 'Écarteur de Farabeuf',
      category: 'Écarteurs',
      status: InstrumentStatus.present,
      confidenceScore: 0.94,
      description: 'Écarteur de Farabeuf double, 15 cm',
    ),
    Instrument(
      id: 'INST-007',
      name: 'Pince de Backhaus',
      category: 'Pinces',
      status: InstrumentStatus.present,
      confidenceScore: 0.93,
      description: 'Pince à champs de Backhaus, 13 cm',
    ),
    Instrument(
      id: 'INST-008',
      name: 'Ciseaux de Metzenbaum',
      category: 'Ciseaux',
      status: InstrumentStatus.present,
      confidenceScore: 0.97,
      description: 'Ciseaux de Metzenbaum courbes, 18 cm',
    ),
  ];

  // ── Detected instruments (simulated scan with anomalies) ────────

  static const List<Instrument> detectedInstruments = [
    Instrument(
      id: 'INST-001',
      name: 'Ciseaux de Mayo',
      category: 'Ciseaux',
      status: InstrumentStatus.present,
      confidenceScore: 0.98,
    ),
    Instrument(
      id: 'INST-002',
      name: 'Pince Hémostatique Kocher',
      category: 'Pinces',
      status: InstrumentStatus.missing,
      confidenceScore: 0.0,
    ),
    Instrument(
      id: 'INST-003',
      name: 'Scalpel #10',
      category: 'Scalpels',
      status: InstrumentStatus.present,
      confidenceScore: 0.99,
    ),
    Instrument(
      id: 'INST-004',
      name: 'Pince Anatomique',
      category: 'Pinces',
      status: InstrumentStatus.extra,
      confidenceScore: 0.91,
    ),
    Instrument(
      id: 'INST-005',
      name: 'Porte-aiguille de Hegar',
      category: 'Porte-aiguilles',
      status: InstrumentStatus.present,
      confidenceScore: 0.95,
    ),
    Instrument(
      id: 'INST-006',
      name: 'Écarteur de Farabeuf',
      category: 'Écarteurs',
      status: InstrumentStatus.present,
      confidenceScore: 0.94,
    ),
    Instrument(
      id: 'INST-007',
      name: 'Pince de Backhaus',
      category: 'Pinces',
      status: InstrumentStatus.present,
      confidenceScore: 0.93,
    ),
    Instrument(
      id: 'INST-008',
      name: 'Ciseaux de Metzenbaum',
      category: 'Ciseaux',
      status: InstrumentStatus.present,
      confidenceScore: 0.97,
    ),
  ];

  // ── Kits ────────────────────────────────────────────────────────

  static final List<Kit> kits = [
    Kit(
      id: 'KIT-001',
      name: 'Kit Chirurgie Générale',
      department: 'Chirurgie',
      referenceInstruments: referenceInstruments,
      lastVerified: DateTime(2026, 2, 28),
    ),
    Kit(
      id: 'KIT-002',
      name: 'Kit Orthopédie',
      department: 'Orthopédie',
      referenceInstruments: referenceInstruments.sublist(0, 5),
      lastVerified: DateTime(2026, 3, 1),
    ),
    Kit(
      id: 'KIT-003',
      name: 'Kit Obstétrique',
      department: 'Maternité',
      referenceInstruments: referenceInstruments.sublist(0, 6),
      lastVerified: DateTime(2026, 2, 25),
    ),
  ];

  // ── Scan Results (history) ──────────────────────────────────────

  static final List<ScanResult> scanHistory = [
    ScanResult(
      id: 'SCAN-001',
      kitId: 'KIT-001',
      kitName: 'Kit Chirurgie Générale',
      timestamp: DateTime(2026, 3, 3, 8, 30),
      detectedInstruments: detectedInstruments,
      referenceInstruments: referenceInstruments,
      conformityScore: 75.0,
      isConformant: false,
      operatorName: 'Marie Dupont',
    ),
    ScanResult(
      id: 'SCAN-002',
      kitId: 'KIT-002',
      kitName: 'Kit Orthopédie',
      timestamp: DateTime(2026, 3, 2, 14, 15),
      detectedInstruments: referenceInstruments.sublist(0, 5),
      referenceInstruments: referenceInstruments.sublist(0, 5),
      conformityScore: 100.0,
      isConformant: true,
      operatorName: 'Jean Mbeki',
    ),
    ScanResult(
      id: 'SCAN-003',
      kitId: 'KIT-003',
      kitName: 'Kit Obstétrique',
      timestamp: DateTime(2026, 3, 1, 10, 45),
      detectedInstruments: referenceInstruments.sublist(0, 6),
      referenceInstruments: referenceInstruments.sublist(0, 6),
      conformityScore: 100.0,
      isConformant: true,
      operatorName: 'Amina Traoré',
    ),
    ScanResult(
      id: 'SCAN-004',
      kitId: 'KIT-001',
      kitName: 'Kit Chirurgie Générale',
      timestamp: DateTime(2026, 2, 28, 16, 0),
      detectedInstruments: detectedInstruments,
      referenceInstruments: referenceInstruments,
      conformityScore: 75.0,
      isConformant: false,
      operatorName: 'Marie Dupont',
      notes: 'Pince hémostatique manquante, à rechercher.',
    ),
  ];

  // ── Cycles ──────────────────────────────────────────────────────

  static final List<Cycle> cycles = [
    Cycle(
      id: 'CYC-001',
      timestamp: DateTime(2026, 3, 3, 7, 0),
      status: 'completed',
      kitId: 'KIT-001',
      operatorName: 'Marie Dupont',
    ),
    Cycle(
      id: 'CYC-002',
      timestamp: DateTime(2026, 3, 2, 13, 0),
      status: 'completed',
      kitId: 'KIT-002',
      operatorName: 'Jean Mbeki',
    ),
    Cycle(
      id: 'CYC-003',
      timestamp: DateTime(2026, 3, 1, 9, 30),
      status: 'in_progress',
      kitId: 'KIT-003',
      operatorName: 'Amina Traoré',
    ),
  ];

  // ── Reconstitution Steps ────────────────────────────────────────

  static const List<Map<String, String>> reconstitutionSteps = [
    {
      'step': '1',
      'title': 'Préparer le plateau',
      'description':
          'Placez le plateau de stérilisation propre sur la surface de travail. '
              'Vérifiez que le plateau est sec et exempt de résidus.',
    },
    {
      'step': '2',
      'title': 'Placer les ciseaux',
      'description':
          'Positionnez les Ciseaux de Mayo (INST-001) dans le compartiment supérieur gauche, '
              'pointes vers le bas.',
    },
    {
      'step': '3',
      'title': 'Placer les pinces hémostatiques',
      'description':
          'Positionnez la Pince Hémostatique Kocher (INST-002) à côté des ciseaux, '
              'mâchoires fermées.',
    },
    {
      'step': '4',
      'title': 'Placer le scalpel',
      'description':
          'Insérez le Scalpel #10 (INST-003) dans le support dédié, '
              'lame protégée vers le bas.',
    },
    {
      'step': '5',
      'title': 'Placer la pince anatomique',
      'description':
          'Positionnez la Pince Anatomique (INST-004) dans le compartiment central.',
    },
    {
      'step': '6',
      'title': 'Placer le porte-aiguille',
      'description':
          'Positionnez le Porte-aiguille de Hegar (INST-005) dans le compartiment inférieur.',
    },
    {
      'step': '7',
      'title': 'Vérification finale',
      'description':
          'Comptez tous les instruments et comparez avec la liste de référence. '
              'Effectuez un scan final pour valider la reconstitution.',
    },
  ];
}
