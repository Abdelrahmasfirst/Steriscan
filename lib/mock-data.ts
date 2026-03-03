import type {
  Instrument,
  KitReference,
  ScanResult,
  DetectedInstrument,
  ReconstitutionSession,
  ReconstitutionStep,
} from "./types"

// ─── Instruments Database ───────────────────────────────────────────────────

export const instrumentsDatabase: Instrument[] = [
  { id: "INS-001", name: "Ciseaux de Mayo droits", category: "Ciseaux", description: "Ciseaux chirurgicaux droits pour couper les tissus" },
  { id: "INS-002", name: "Ciseaux de Mayo courbes", category: "Ciseaux", description: "Ciseaux chirurgicaux courbes pour dissection" },
  { id: "INS-003", name: "Ciseaux de Metzenbaum", category: "Ciseaux", description: "Ciseaux fins pour dissection délicate" },
  { id: "INS-004", name: "Pince hémostatique Kocher", category: "Pinces", description: "Pince à griffes pour clampage vasculaire" },
  { id: "INS-005", name: "Pince hémostatique Kelly", category: "Pinces", description: "Pince courbe pour hémostase" },
  { id: "INS-006", name: "Pince anatomique standard", category: "Pinces", description: "Pince sans griffes pour manipulation tissulaire" },
  { id: "INS-007", name: "Pince chirurgicale à griffes", category: "Pinces", description: "Pince avec griffes pour préhension ferme" },
  { id: "INS-008", name: "Porte-aiguille de Hegar", category: "Porte-aiguilles", description: "Porte-aiguille standard pour sutures" },
  { id: "INS-009", name: "Porte-aiguille de Mathieu", category: "Porte-aiguilles", description: "Porte-aiguille à ressort" },
  { id: "INS-010", name: "Scalpel manche #3", category: "Scalpels", description: "Manche de scalpel pour lames 10-15" },
  { id: "INS-011", name: "Scalpel manche #4", category: "Scalpels", description: "Manche de scalpel pour lames 20-25" },
  { id: "INS-012", name: "Écarteur de Farabeuf", category: "Écarteurs", description: "Écarteur manuel double extrémité" },
  { id: "INS-013", name: "Écarteur de Langenbeck", category: "Écarteurs", description: "Écarteur à main étroit" },
  { id: "INS-014", name: "Écarteur autostatique Weitlaner", category: "Écarteurs", description: "Écarteur auto-rétentif à griffes" },
  { id: "INS-015", name: "Pince de Backhaus", category: "Pinces", description: "Pince à champs opératoires" },
  { id: "INS-016", name: "Cupule inox 250ml", category: "Accessoires", description: "Récipient pour solutions" },
  { id: "INS-017", name: "Haricot inox", category: "Accessoires", description: "Plateau en forme de haricot" },
  { id: "INS-018", name: "Canule d'aspiration Yankauer", category: "Aspiration", description: "Canule d'aspiration chirurgicale" },
  { id: "INS-019", name: "Pince de Allis", category: "Pinces", description: "Pince à préhension tissulaire" },
  { id: "INS-020", name: "Pince de Babcock", category: "Pinces", description: "Pince atraumatique pour organes creux" },
]

// ─── Kit References ─────────────────────────────────────────────────────────

export const kitReferences: KitReference[] = [
  {
    id: "KIT-001",
    name: "Kit Chirurgie Générale Standard",
    description: "Kit de base pour interventions de chirurgie générale",
    specialty: "Chirurgie Générale",
    instruments: [
      instrumentsDatabase[0], // Ciseaux Mayo droits
      instrumentsDatabase[1], // Ciseaux Mayo courbes
      instrumentsDatabase[2], // Ciseaux Metzenbaum
      instrumentsDatabase[3], // Pince Kocher
      instrumentsDatabase[4], // Pince Kelly
      instrumentsDatabase[5], // Pince anatomique
      instrumentsDatabase[6], // Pince chirurgicale
      instrumentsDatabase[7], // Porte-aiguille Hegar
      instrumentsDatabase[9], // Scalpel #3
      instrumentsDatabase[10], // Scalpel #4
      instrumentsDatabase[11], // Écarteur Farabeuf
      instrumentsDatabase[12], // Écarteur Langenbeck
      instrumentsDatabase[14], // Pince Backhaus x4
      instrumentsDatabase[15], // Cupule
      instrumentsDatabase[17], // Canule Yankauer
    ],
    createdAt: "2025-01-15T08:00:00Z",
    updatedAt: "2025-06-20T14:30:00Z",
  },
  {
    id: "KIT-002",
    name: "Kit Appendicectomie",
    description: "Kit spécialisé pour appendicectomie ouverte",
    specialty: "Chirurgie Digestive",
    instruments: [
      instrumentsDatabase[0],
      instrumentsDatabase[2],
      instrumentsDatabase[3],
      instrumentsDatabase[4],
      instrumentsDatabase[5],
      instrumentsDatabase[7],
      instrumentsDatabase[9],
      instrumentsDatabase[11],
      instrumentsDatabase[13], // Weitlaner
      instrumentsDatabase[14],
      instrumentsDatabase[15],
      instrumentsDatabase[17],
    ],
    createdAt: "2025-02-10T09:00:00Z",
    updatedAt: "2025-05-15T11:00:00Z",
  },
  {
    id: "KIT-003",
    name: "Kit Suture & Parage",
    description: "Kit pour sutures et parages de plaies",
    specialty: "Urgences",
    instruments: [
      instrumentsDatabase[2], // Metzenbaum
      instrumentsDatabase[5], // Pince anatomique
      instrumentsDatabase[6], // Pince chirurgicale
      instrumentsDatabase[7], // Porte-aiguille
      instrumentsDatabase[9], // Scalpel #3
      instrumentsDatabase[14], // Backhaus
      instrumentsDatabase[16], // Haricot
    ],
    createdAt: "2025-03-01T10:00:00Z",
    updatedAt: "2025-07-01T08:00:00Z",
  },
  {
    id: "KIT-004",
    name: "Kit Césarienne",
    description: "Kit complet pour césarienne",
    specialty: "Obstétrique",
    instruments: [
      instrumentsDatabase[0],
      instrumentsDatabase[1],
      instrumentsDatabase[2],
      instrumentsDatabase[3],
      instrumentsDatabase[4],
      instrumentsDatabase[5],
      instrumentsDatabase[6],
      instrumentsDatabase[7],
      instrumentsDatabase[8], // Porte-aiguille Mathieu
      instrumentsDatabase[9],
      instrumentsDatabase[11],
      instrumentsDatabase[12],
      instrumentsDatabase[13],
      instrumentsDatabase[14],
      instrumentsDatabase[15],
      instrumentsDatabase[17],
      instrumentsDatabase[18], // Allis
      instrumentsDatabase[19], // Babcock
    ],
    createdAt: "2025-01-20T07:00:00Z",
    updatedAt: "2025-06-30T16:00:00Z",
  },
]

// ─── Scan History ───────────────────────────────────────────────────────────

function makeDetected(kit: KitReference, overrides: Partial<Record<string, { status: "present" | "missing" | "extra"; confidence: number }>>): DetectedInstrument[] {
  const result: DetectedInstrument[] = kit.instruments.map((inst, idx) => {
    const override = overrides[inst.id]
    return {
      id: `DET-${kit.id}-${idx}`,
      instrumentId: inst.id,
      name: inst.name,
      status: override?.status ?? "present",
      confidence: override?.confidence ?? (92 + Math.random() * 7),
      position: { x: 50 + (idx % 5) * 120, y: 80 + Math.floor(idx / 5) * 100 },
    }
  })
  return result
}

const scan1Detected = makeDetected(kitReferences[0], {
  "INS-005": { status: "missing", confidence: 0 },
})
// Add an extra instrument
scan1Detected.push({
  id: "DET-KIT-001-EX",
  instrumentId: "INS-020",
  name: "Pince de Babcock",
  status: "extra",
  confidence: 94.2,
  position: { x: 530, y: 280 },
})

const scan2Detected = makeDetected(kitReferences[1], {})

const scan3Detected = makeDetected(kitReferences[2], {
  "INS-007": { status: "missing", confidence: 0 },
  "INS-010": { status: "missing", confidence: 0 },
})

const scan4Detected = makeDetected(kitReferences[3], {
  "INS-019": { status: "missing", confidence: 0 },
})
scan4Detected.push({
  id: "DET-KIT-004-EX",
  instrumentId: "INS-016",
  name: "Cupule inox 250ml (doublon)",
  status: "extra",
  confidence: 91.5,
  position: { x: 600, y: 180 },
})

const scan5Detected = makeDetected(kitReferences[0], {})

export const scanHistory: ScanResult[] = [
  {
    id: "SCAN-001",
    kitReferenceId: "KIT-001",
    kitReferenceName: "Kit Chirurgie Générale Standard",
    timestamp: "2025-07-08T14:32:00Z",
    status: "non-conforme",
    conformityScore: 87,
    detectedInstruments: scan1Detected,
    missingCount: 1,
    extraCount: 1,
    operator: "Aminata Diallo",
    notes: "Pince Kelly manquante, Babcock en surplus",
  },
  {
    id: "SCAN-002",
    kitReferenceId: "KIT-002",
    kitReferenceName: "Kit Appendicectomie",
    timestamp: "2025-07-08T11:15:00Z",
    status: "conforme",
    conformityScore: 100,
    detectedInstruments: scan2Detected,
    missingCount: 0,
    extraCount: 0,
    operator: "Jean-Pierre Mukendi",
  },
  {
    id: "SCAN-003",
    kitReferenceId: "KIT-003",
    kitReferenceName: "Kit Suture & Parage",
    timestamp: "2025-07-07T16:45:00Z",
    status: "non-conforme",
    conformityScore: 71,
    detectedInstruments: scan3Detected,
    missingCount: 2,
    extraCount: 0,
    operator: "Fatou Ndiaye",
    notes: "2 instruments manquants - vérifier stérilisation lot #2207",
  },
  {
    id: "SCAN-004",
    kitReferenceId: "KIT-004",
    kitReferenceName: "Kit Césarienne",
    timestamp: "2025-07-07T09:20:00Z",
    status: "partiel",
    conformityScore: 89,
    detectedInstruments: scan4Detected,
    missingCount: 1,
    extraCount: 1,
    operator: "Aminata Diallo",
    notes: "Allis manquante, cupule en doublon",
  },
  {
    id: "SCAN-005",
    kitReferenceId: "KIT-001",
    kitReferenceName: "Kit Chirurgie Générale Standard",
    timestamp: "2025-07-06T13:00:00Z",
    status: "conforme",
    conformityScore: 100,
    detectedInstruments: scan5Detected,
    missingCount: 0,
    extraCount: 0,
    operator: "Jean-Pierre Mukendi",
  },
  {
    id: "SCAN-006",
    kitReferenceId: "KIT-002",
    kitReferenceName: "Kit Appendicectomie",
    timestamp: "2025-07-05T10:30:00Z",
    status: "conforme",
    conformityScore: 98,
    detectedInstruments: makeDetected(kitReferences[1], {}),
    missingCount: 0,
    extraCount: 0,
    operator: "Fatou Ndiaye",
  },
  {
    id: "SCAN-007",
    kitReferenceId: "KIT-003",
    kitReferenceName: "Kit Suture & Parage",
    timestamp: "2025-07-04T15:10:00Z",
    status: "conforme",
    conformityScore: 100,
    detectedInstruments: makeDetected(kitReferences[2], {}),
    missingCount: 0,
    extraCount: 0,
    operator: "Aminata Diallo",
  },
  {
    id: "SCAN-008",
    kitReferenceId: "KIT-004",
    kitReferenceName: "Kit Césarienne",
    timestamp: "2025-07-03T08:45:00Z",
    status: "non-conforme",
    conformityScore: 78,
    detectedInstruments: makeDetected(kitReferences[3], {
      "INS-002": { status: "missing", confidence: 0 },
      "INS-008": { status: "missing", confidence: 0 },
      "INS-013": { status: "missing", confidence: 0 },
    }),
    missingCount: 3,
    extraCount: 0,
    operator: "Jean-Pierre Mukendi",
    notes: "3 instruments manquants après stérilisation",
  },
]

// ─── Reconstitution Sessions ────────────────────────────────────────────────

export const reconstitutionSessions: ReconstitutionSession[] = [
  {
    id: "RECON-001",
    kitReferenceId: "KIT-001",
    kitReferenceName: "Kit Chirurgie Générale Standard",
    scanResultId: "SCAN-001",
    startedAt: "2025-07-08T14:45:00Z",
    completedAt: "2025-07-08T15:10:00Z",
    status: "completed",
    steps: [
      { stepNumber: 1, instrumentId: "INS-005", instrumentName: "Pince hémostatique Kelly", instruction: "Récupérer la pince Kelly dans le bac de stérilisation lot #2207", position: "Rangée 2, Position 5", completed: true },
      { stepNumber: 2, instrumentId: "INS-020", instrumentName: "Pince de Babcock", instruction: "Retirer la pince de Babcock (en surplus) et la remettre dans le stock", position: "À retirer", completed: true },
      { stepNumber: 3, instrumentId: "VALIDATE", instrumentName: "Validation finale", instruction: "Scanner le kit reconstitué pour validation", position: "—", completed: true },
    ],
  },
]

// ─── Statistics helpers ─────────────────────────────────────────────────────

export function getConformityStats() {
  const total = scanHistory.length
  const conforme = scanHistory.filter((s) => s.status === "conforme").length
  const partiel = scanHistory.filter((s) => s.status === "partiel").length
  const nonConforme = scanHistory.filter((s) => s.status === "non-conforme").length
  const avgScore = Math.round(scanHistory.reduce((sum, s) => sum + s.conformityScore, 0) / total)

  return { total, conforme, partiel, nonConforme, avgScore }
}

export function getWeeklyScans() {
  return [
    { day: "Lun", scans: 4, conformes: 3 },
    { day: "Mar", scans: 6, conformes: 5 },
    { day: "Mer", scans: 3, conformes: 3 },
    { day: "Jeu", scans: 5, conformes: 4 },
    { day: "Ven", scans: 7, conformes: 6 },
    { day: "Sam", scans: 2, conformes: 2 },
    { day: "Dim", scans: 1, conformes: 1 },
  ]
}
