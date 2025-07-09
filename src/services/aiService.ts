import { Instrument } from '../types';
import { AI_CONFIG, INSTRUMENT_TYPES } from '../constants';

export interface DetectionResult {
  instruments: Instrument[];
  processingTime: number;
  confidence: number;
}

export class AIService {
  private isModelLoaded = false;

  async initializeModel(): Promise<void> {
    try {
      // Simulation du chargement du modèle IA
      // En production, ici on chargerait TensorFlow Lite ou YOLOv7
      console.log('Loading AI model...');
      await new Promise(resolve => setTimeout(resolve, 1000));
      this.isModelLoaded = true;
      console.log('AI model loaded successfully');
    } catch (error) {
      console.error('Error loading AI model:', error);
      throw error;
    }
  }

  async detectInstruments(imageUri: string): Promise<DetectionResult> {
    if (!this.isModelLoaded) {
      await this.initializeModel();
    }

    const startTime = Date.now();

    try {
      // Simulation de la détection d'instruments
      // En production, ici on utiliserait le modèle IA pour analyser l'image
      const detectedInstruments = await this.simulateDetection(imageUri);
      
      const processingTime = Date.now() - startTime;
      const averageConfidence = detectedInstruments.reduce((sum, inst) => sum + inst.confidence, 0) / detectedInstruments.length;

      return {
        instruments: detectedInstruments,
        processingTime,
        confidence: averageConfidence
      };
    } catch (error) {
      console.error('Error during instrument detection:', error);
      throw error;
    }
  }

  private async simulateDetection(imageUri: string): Promise<Instrument[]> {
    // Simulation - En production, remplacer par l'analyse IA réelle
    await new Promise(resolve => setTimeout(resolve, 2000));

    const simulatedInstruments: Instrument[] = [
      {
        id: 'INST-001',
        name: 'Ciseaux de Mayo',
        type: 'scissors',
        status: 'present',
        confidence: 0.95,
        position: { x: 100, y: 150, width: 80, height: 120 }
      },
      {
        id: 'INST-002',
        name: 'Pince Hémostatique',
        type: 'clamp',
        status: 'missing',
        confidence: 0.0,
      },
      {
        id: 'INST-003',
        name: 'Scalpel #10',
        type: 'scalpel',
        status: 'present',
        confidence: 0.88,
        position: { x: 200, y: 100, width: 60, height: 100 }
      },
      {
        id: 'INST-004',
        name: 'Pince Anatomique',
        type: 'forceps',
        status: 'extra',
        confidence: 0.92,
        position: { x: 150, y: 250, width: 70, height: 110 }
      },
      {
        id: 'INST-005',
        name: 'Porte-aiguille',
        type: 'needle_holder',
        status: 'present',
        confidence: 0.91,
        position: { x: 300, y: 200, width: 85, height: 130 }
      }
    ];

    return simulatedInstruments.filter(inst => 
      inst.confidence >= AI_CONFIG.MIN_CONFIDENCE || inst.status === 'missing'
    );
  }

  calculateConformityScore(detectedInstruments: Instrument[], referenceInstruments: Instrument[]): number {
    if (referenceInstruments.length === 0) return 100;

    const presentCount = detectedInstruments.filter(inst => inst.status === 'present').length;
    const expectedCount = referenceInstruments.length;
    
    return Math.round((presentCount / expectedCount) * 100);
  }

  compareWithReference(detected: Instrument[], reference: Instrument[]): Instrument[] {
    const result: Instrument[] = [];
    
    // Marquer les instruments de référence
    for (const refInst of reference) {
      const detectedInst = detected.find(d => d.type === refInst.type || d.name === refInst.name);
      
      if (detectedInst) {
        result.push({
          ...detectedInst,
          status: 'present'
        });
      } else {
        result.push({
          ...refInst,
          status: 'missing',
          confidence: 0
        });
      }
    }

    // Marquer les instruments en surplus
    for (const detectedInst of detected) {
      const isInReference = reference.some(r => r.type === detectedInst.type || r.name === detectedInst.name);
      
      if (!isInReference) {
        result.push({
          ...detectedInst,
          status: 'extra'
        });
      }
    }

    return result;
  }

  async preprocessImage(imageUri: string): Promise<string> {
    // Simulation du préprocessing d'image
    // En production: redimensionnement, normalisation, etc.
    return imageUri;
  }

  getModelInfo() {
    return {
      version: AI_CONFIG.MODEL_VERSION,
      isLoaded: this.isModelLoaded,
      supportedInstruments: INSTRUMENT_TYPES.length,
      minConfidence: AI_CONFIG.MIN_CONFIDENCE
    };
  }
}

export const aiService = new AIService();