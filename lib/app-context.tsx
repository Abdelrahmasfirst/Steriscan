"use client"

import React, { createContext, useContext, useState, useCallback, type ReactNode } from "react"
import type { ScanResult, AppSettings, SyncStatus, ReconstitutionSession } from "./types"
import { scanHistory as initialHistory, reconstitutionSessions as initialRecon } from "./mock-data"

interface AppContextType {
  // Scan state
  scanHistory: ScanResult[]
  addScanResult: (result: ScanResult) => void
  currentScan: ScanResult | null
  setCurrentScan: (scan: ScanResult | null) => void

  // Reconstitution
  reconstitutionSessions: ReconstitutionSession[]
  addReconstitutionSession: (session: ReconstitutionSession) => void
  currentReconstitution: ReconstitutionSession | null
  setCurrentReconstitution: (session: ReconstitutionSession | null) => void

  // Settings
  settings: AppSettings
  updateSettings: (settings: Partial<AppSettings>) => void

  // Sync
  syncStatus: SyncStatus
}

const defaultSettings: AppSettings = {
  language: "fr",
  smsAlertsEnabled: false,
  smsPhoneNumber: "",
  offlineMode: true,
  autoSync: false,
  soundAlerts: true,
  confidenceThreshold: 90,
}

const defaultSync: SyncStatus = {
  lastSync: "2025-07-08T14:00:00Z",
  pendingUploads: 2,
  isOnline: true,
}

const AppContext = createContext<AppContextType | undefined>(undefined)

export function AppProvider({ children }: { children: ReactNode }) {
  const [scanHistoryState, setScanHistory] = useState<ScanResult[]>(initialHistory)
  const [currentScan, setCurrentScan] = useState<ScanResult | null>(null)
  const [reconSessions, setReconSessions] = useState<ReconstitutionSession[]>(initialRecon)
  const [currentReconstitution, setCurrentReconstitution] = useState<ReconstitutionSession | null>(null)
  const [settings, setSettings] = useState<AppSettings>(defaultSettings)
  const [syncStatus] = useState<SyncStatus>(defaultSync)

  const addScanResult = useCallback((result: ScanResult) => {
    setScanHistory((prev) => [result, ...prev])
  }, [])

  const addReconstitutionSession = useCallback((session: ReconstitutionSession) => {
    setReconSessions((prev) => [session, ...prev])
  }, [])

  const updateSettings = useCallback((partial: Partial<AppSettings>) => {
    setSettings((prev) => ({ ...prev, ...partial }))
  }, [])

  return (
    <AppContext.Provider
      value={{
        scanHistory: scanHistoryState,
        addScanResult,
        currentScan,
        setCurrentScan,
        reconstitutionSessions: reconSessions,
        addReconstitutionSession,
        currentReconstitution,
        setCurrentReconstitution,
        settings,
        updateSettings,
        syncStatus,
      }}
    >
      {children}
    </AppContext.Provider>
  )
}

export function useAppContext() {
  const ctx = useContext(AppContext)
  if (!ctx) throw new Error("useAppContext must be used within AppProvider")
  return ctx
}
