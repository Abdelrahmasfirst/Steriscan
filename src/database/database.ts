import * as SQLite from 'expo-sqlite';
import { Kit, Instrument, ScanResult, Settings } from '../types';
import { DATABASE_NAME, DATABASE_VERSION } from '../constants';

export class DatabaseService {
  private db: SQLite.SQLiteDatabase | null = null;

  async init(): Promise<void> {
    try {
      this.db = await SQLite.openDatabaseAsync(DATABASE_NAME);
      await this.createTables();
      console.log('Database initialized successfully');
    } catch (error) {
      console.error('Database initialization error:', error);
      throw error;
    }
  }

  private async createTables(): Promise<void> {
    if (!this.db) throw new Error('Database not initialized');

    const createTablesSQL = `
      CREATE TABLE IF NOT EXISTS kits (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        instruments TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_reference INTEGER DEFAULT 0
      );

      CREATE TABLE IF NOT EXISTS scan_results (
        id TEXT PRIMARY KEY,
        kit_id TEXT NOT NULL,
        image_uri TEXT NOT NULL,
        detected_instruments TEXT NOT NULL,
        conformity_score REAL NOT NULL,
        timestamp TEXT NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (kit_id) REFERENCES kits (id)
      );

      CREATE TABLE IF NOT EXISTS settings (
        id INTEGER PRIMARY KEY,
        language TEXT DEFAULT 'fr',
        offline_mode INTEGER DEFAULT 1,
        sms_alerts INTEGER DEFAULT 0,
        phone_number TEXT,
        auto_save INTEGER DEFAULT 1,
        ai_confidence_threshold REAL DEFAULT 0.95
      );

      CREATE TABLE IF NOT EXISTS instruments_master (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL
      );
    `;

    await this.db.execAsync(createTablesSQL);
    await this.initDefaultData();
  }

  private async initDefaultData(): Promise<void> {
    if (!this.db) return;

    // Insert default settings if not exists
    const settingsCount = await this.db.getFirstAsync(
      'SELECT COUNT(*) as count FROM settings'
    ) as { count: number };

    if (settingsCount.count === 0) {
      await this.db.runAsync(
        'INSERT INTO settings (language, offline_mode, sms_alerts, auto_save, ai_confidence_threshold) VALUES (?, ?, ?, ?, ?)',
        ['fr', 1, 0, 1, 0.95]
      );
    }

    // Insert master instruments if not exists
    const instrumentsCount = await this.db.getFirstAsync(
      'SELECT COUNT(*) as count FROM instruments_master'
    ) as { count: number };

    if (instrumentsCount.count === 0) {
      const instruments = [
        { id: 'INST-001', name: 'Ciseaux de Mayo', type: 'scissors' },
        { id: 'INST-002', name: 'Pince Hémostatique', type: 'clamp' },
        { id: 'INST-003', name: 'Scalpel #10', type: 'scalpel' },
        { id: 'INST-004', name: 'Pince Anatomique', type: 'forceps' },
        { id: 'INST-005', name: 'Porte-aiguille', type: 'needle_holder' },
      ];

      for (const instrument of instruments) {
        await this.db.runAsync(
          'INSERT INTO instruments_master (id, name, type, description, created_at) VALUES (?, ?, ?, ?, ?)',
          [instrument.id, instrument.name, instrument.type, '', new Date().toISOString()]
        );
      }
    }
  }

  // Kit operations
  async saveKit(kit: Kit): Promise<void> {
    if (!this.db) throw new Error('Database not initialized');

    await this.db.runAsync(
      'INSERT OR REPLACE INTO kits (id, name, description, instruments, created_at, updated_at, is_reference) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        kit.id,
        kit.name,
        kit.description,
        JSON.stringify(kit.instruments),
        kit.createdAt,
        kit.updatedAt,
        kit.isReference ? 1 : 0
      ]
    );
  }

  async getKit(id: string): Promise<Kit | null> {
    if (!this.db) throw new Error('Database not initialized');

    const result = await this.db.getFirstAsync(
      'SELECT * FROM kits WHERE id = ?',
      [id]
    ) as any;

    if (!result) return null;

    return {
      id: result.id,
      name: result.name,
      description: result.description,
      instruments: JSON.parse(result.instruments),
      createdAt: result.created_at,
      updatedAt: result.updated_at,
      isReference: result.is_reference === 1
    };
  }

  async getAllKits(): Promise<Kit[]> {
    if (!this.db) throw new Error('Database not initialized');

    const results = await this.db.getAllAsync('SELECT * FROM kits ORDER BY updated_at DESC') as any[];

    return results.map(result => ({
      id: result.id,
      name: result.name,
      description: result.description,
      instruments: JSON.parse(result.instruments),
      createdAt: result.created_at,
      updatedAt: result.updated_at,
      isReference: result.is_reference === 1
    }));
  }

  // Scan results operations
  async saveScanResult(scanResult: ScanResult): Promise<void> {
    if (!this.db) throw new Error('Database not initialized');

    await this.db.runAsync(
      'INSERT OR REPLACE INTO scan_results (id, kit_id, image_uri, detected_instruments, conformity_score, timestamp, status) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        scanResult.id,
        scanResult.kitId,
        scanResult.imageUri,
        JSON.stringify(scanResult.detectedInstruments),
        scanResult.conformityScore,
        scanResult.timestamp,
        scanResult.status
      ]
    );
  }

  async getScanResult(id: string): Promise<ScanResult | null> {
    if (!this.db) throw new Error('Database not initialized');

    const result = await this.db.getFirstAsync(
      'SELECT * FROM scan_results WHERE id = ?',
      [id]
    ) as any;

    if (!result) return null;

    return {
      id: result.id,
      kitId: result.kit_id,
      imageUri: result.image_uri,
      detectedInstruments: JSON.parse(result.detected_instruments),
      conformityScore: result.conformity_score,
      timestamp: result.timestamp,
      status: result.status
    };
  }

  async getAllScanResults(): Promise<ScanResult[]> {
    if (!this.db) throw new Error('Database not initialized');

    const results = await this.db.getAllAsync(
      'SELECT * FROM scan_results ORDER BY timestamp DESC'
    ) as any[];

    return results.map(result => ({
      id: result.id,
      kitId: result.kit_id,
      imageUri: result.image_uri,
      detectedInstruments: JSON.parse(result.detected_instruments),
      conformityScore: result.conformity_score,
      timestamp: result.timestamp,
      status: result.status
    }));
  }

  // Settings operations
  async getSettings(): Promise<Settings> {
    if (!this.db) throw new Error('Database not initialized');

    const result = await this.db.getFirstAsync('SELECT * FROM settings LIMIT 1') as any;

    return {
      language: result.language || 'fr',
      offlineMode: result.offline_mode === 1,
      smsAlerts: result.sms_alerts === 1,
      phoneNumber: result.phone_number,
      autoSave: result.auto_save === 1,
      aiConfidenceThreshold: result.ai_confidence_threshold || 0.95
    };
  }

  async updateSettings(settings: Settings): Promise<void> {
    if (!this.db) throw new Error('Database not initialized');

    await this.db.runAsync(
      'UPDATE settings SET language = ?, offline_mode = ?, sms_alerts = ?, phone_number = ?, auto_save = ?, ai_confidence_threshold = ?',
      [
        settings.language,
        settings.offlineMode ? 1 : 0,
        settings.smsAlerts ? 1 : 0,
        settings.phoneNumber,
        settings.autoSave ? 1 : 0,
        settings.aiConfidenceThreshold
      ]
    );
  }
}

export const databaseService = new DatabaseService();