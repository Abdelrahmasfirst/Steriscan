export interface Instrument {
  id: string;
  name: string;
  type: string;
  status: 'present' | 'missing' | 'extra';
  confidence: number;
  position?: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
}

export interface Kit {
  id: string;
  name: string;
  description: string;
  instruments: Instrument[];
  createdAt: string;
  updatedAt: string;
  isReference: boolean;
}

export interface ScanResult {
  id: string;
  kitId: string;
  imageUri: string;
  detectedInstruments: Instrument[];
  conformityScore: number;
  timestamp: string;
  status: 'conforming' | 'partial' | 'non-conforming';
}

export interface User {
  id: string;
  name: string;
  role: 'agent' | 'technician' | 'quality' | 'surgeon';
  language: 'fr' | 'sw' | 'ha';
}

export interface Settings {
  language: 'fr' | 'sw' | 'ha';
  offlineMode: boolean;
  smsAlerts: boolean;
  phoneNumber?: string;
  autoSave: boolean;
  aiConfidenceThreshold: number;
}

export type NavigationParamList = {
  Home: undefined;
  Scanner: { kitId?: string };
  Results: { scanId: string };
  History: undefined;
  Settings: undefined;
  KitDetail: { kitId: string };
  Reconstruction: { kitId: string; scanId: string };
};