export const COLORS = {
  primary: '#4F46E5',
  secondary: '#06B6D4',
  success: '#10B981',
  warning: '#F59E0B',
  error: '#EF4444',
  background: '#F8FAFC',
  surface: '#FFFFFF',
  text: '#1F2937',
  textSecondary: '#6B7280',
  border: '#E5E7EB',
};

export const SIZES = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
};

export const INSTRUMENT_TYPES = [
  'Ciseaux de Mayo',
  'Pince Hémostatique',
  'Scalpel #10',
  'Pince Anatomique',
  'Porte-aiguille',
  'Écarteur',
  'Sonde cannelée',
  'Pince à dissection',
  'Clamp',
  'Bistouri',
];

export const CONFORMITY_THRESHOLDS = {
  HIGH: 95,
  MEDIUM: 80,
  LOW: 60,
};

export const AI_CONFIG = {
  MIN_CONFIDENCE: 0.7,
  MODEL_VERSION: '1.0',
  MAX_DETECTION_TIME: 5000, // 5 seconds
};

export const DATABASE_NAME = 'steriscan.db';
export const DATABASE_VERSION = 1;