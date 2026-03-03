export type InstrumentStatus = "present" | "missing" | "extra" | "damaged"

export type ScanStatus = "conforme" | "partiel" | "non-conforme"

export type Language = "fr" | "sw" | "ha"

export interface Instrument {
  id: string
  name: string
  category: string
  description: string
  imageUrl?: string
}

export interface DetectedInstrument {
  id: string
  instrumentId: string
  name: string
  status: InstrumentStatus
  confidence: number
  position?: { x: number; y: number }
}

export interface KitReference {
  id: string
  name: string
  description: string
  specialty: string
  instruments: Instrument[]
  createdAt: string
  updatedAt: string
}

export interface ScanResult {
  id: string
  kitReferenceId: string
  kitReferenceName: string
  timestamp: string
  status: ScanStatus
  conformityScore: number
  detectedInstruments: DetectedInstrument[]
  missingCount: number
  extraCount: number
  operator: string
  notes?: string
  imageUrl?: string
}

export interface ReconstitutionStep {
  stepNumber: number
  instrumentId: string
  instrumentName: string
  instruction: string
  position: string
  completed: boolean
}

export interface ReconstitutionSession {
  id: string
  kitReferenceId: string
  kitReferenceName: string
  scanResultId: string
  steps: ReconstitutionStep[]
  startedAt: string
  completedAt?: string
  status: "in-progress" | "completed" | "cancelled"
}

export interface AppSettings {
  language: Language
  smsAlertsEnabled: boolean
  smsPhoneNumber: string
  offlineMode: boolean
  autoSync: boolean
  soundAlerts: boolean
  confidenceThreshold: number
}

export interface SyncStatus {
  lastSync: string | null
  pendingUploads: number
  isOnline: boolean
}
