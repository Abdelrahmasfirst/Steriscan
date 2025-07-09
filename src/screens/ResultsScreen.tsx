import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Image,
  Share,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation, useRoute } from '@react-navigation/native';
import { useLocalization } from '../utils/localization';
import { COLORS, SIZES, CONFORMITY_THRESHOLDS } from '../constants';
import { ScanResult, Instrument } from '../types';

const ResultsScreen: React.FC = () => {
  const navigation = useNavigation();
  const route = useRoute();
  const { t } = useLocalization();
  
  const { scanResult } = (route.params as any) || {};

  const getConformityLevel = (score: number) => {
    if (score >= CONFORMITY_THRESHOLDS.HIGH) return 'high';
    if (score >= CONFORMITY_THRESHOLDS.MEDIUM) return 'medium';
    return 'low';
  };

  const getConformityColor = (score: number) => {
    const level = getConformityLevel(score);
    switch (level) {
      case 'high':
        return COLORS.success;
      case 'medium':
        return COLORS.warning;
      case 'low':
        return COLORS.error;
      default:
        return COLORS.textSecondary;
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'present':
        return '✅';
      case 'missing':
        return '❌';
      case 'extra':
        return '⚠️';
      default:
        return '❓';
    }
  };

  const getStatusText = (status: string) => {
    switch (status) {
      case 'present':
        return t('results', 'present');
      case 'missing':
        return t('results', 'missing');
      case 'extra':
        return t('results', 'extra');
      default:
        return status;
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'present':
        return COLORS.success;
      case 'missing':
        return COLORS.error;
      case 'extra':
        return COLORS.warning;
      default:
        return COLORS.textSecondary;
    }
  };

  const handleExportReport = async () => {
    try {
      const reportText = `
Rapport SteriScan - ${new Date(scanResult.timestamp).toLocaleDateString('fr-FR')}

Kit ID: ${scanResult.kitId}
Score de Conformité: ${scanResult.conformityScore}%
Statut: ${scanResult.status}

Instruments détectés:
${scanResult.detectedInstruments.map((inst: Instrument) => 
  `- ${inst.name}: ${getStatusText(inst.status)} (${Math.round(inst.confidence * 100)}%)`
).join('\n')}
      `;

      await Share.share({
        message: reportText,
        title: 'Rapport SteriScan',
      });
    } catch (error) {
      console.error('Error sharing report:', error);
    }
  };

  const handleSaveComposition = () => {
    // TODO: Implémenter la sauvegarde de composition
    console.log('Save composition');
  };

  const handleReconstruct = () => {
    // TODO: Naviguer vers l'écran de reconstitution
    console.log('Reconstruct kit');
  };

  if (!scanResult) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.errorContainer}>
          <Text style={styles.errorText}>Aucun résultat de scan disponible</Text>
          <TouchableOpacity
            style={styles.button}
            onPress={() => navigation.goBack()}
          >
            <Text style={styles.buttonText}>Retour</Text>
          </TouchableOpacity>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Text style={styles.backButtonText}>← Retour</Text>
        </TouchableOpacity>
        
        <Text style={styles.title}>{t('results', 'title')}</Text>
        
        <View style={styles.placeholder} />
      </View>

      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        {/* Image */}
        {scanResult.imageUri && (
          <View style={styles.imageContainer}>
            <Image source={{ uri: scanResult.imageUri }} style={styles.scanImage} />
          </View>
        )}

        {/* Conformity Score */}
        <View style={styles.scoreContainer}>
          <View style={[
            styles.scoreCircle,
            { backgroundColor: getConformityColor(scanResult.conformityScore) }
          ]}>
            <Text style={styles.scoreText}>{scanResult.conformityScore}%</Text>
          </View>
          <Text style={styles.scoreLabel}>{t('results', 'conformityScore')}</Text>
          <Text style={styles.scoreDescription}>
            {scanResult.conformityScore >= CONFORMITY_THRESHOLDS.HIGH
              ? 'Kit conforme ✅'
              : scanResult.conformityScore >= CONFORMITY_THRESHOLDS.MEDIUM
                ? 'Kit partiellement conforme ⚠️'
                : 'Kit non conforme ❌'}
          </Text>
        </View>

        {/* Instruments List */}
        <View style={styles.instrumentsContainer}>
          <Text style={styles.sectionTitle}>{t('results', 'instruments')}</Text>
          
          {scanResult.detectedInstruments.map((instrument: Instrument, index: number) => (
            <View key={index} style={styles.instrumentItem}>
              <View style={styles.instrumentInfo}>
                <View style={styles.instrumentHeader}>
                  <Text style={styles.instrumentIcon}>
                    {getStatusIcon(instrument.status)}
                  </Text>
                  <Text style={styles.instrumentName}>{instrument.name}</Text>
                </View>
                <Text style={styles.instrumentId}>ID: {instrument.id}</Text>
                {instrument.confidence > 0 && (
                  <Text style={styles.instrumentConfidence}>
                    Confiance: {Math.round(instrument.confidence * 100)}%
                  </Text>
                )}
              </View>
              
              <View style={[
                styles.statusBadge,
                { backgroundColor: getStatusColor(instrument.status) }
              ]}>
                <Text style={styles.statusBadgeText}>
                  {getStatusText(instrument.status)}
                </Text>
              </View>
            </View>
          ))}
        </View>

        {/* Summary */}
        <View style={styles.summaryContainer}>
          <Text style={styles.sectionTitle}>Résumé</Text>
          
          <View style={styles.summaryGrid}>
            <View style={styles.summaryItem}>
              <Text style={styles.summaryNumber}>
                {scanResult.detectedInstruments.filter((i: Instrument) => i.status === 'present').length}
              </Text>
              <Text style={styles.summaryLabel}>Présents</Text>
            </View>
            
            <View style={styles.summaryItem}>
              <Text style={[styles.summaryNumber, { color: COLORS.error }]}>
                {scanResult.detectedInstruments.filter((i: Instrument) => i.status === 'missing').length}
              </Text>
              <Text style={styles.summaryLabel}>Manquants</Text>
            </View>
            
            <View style={styles.summaryItem}>
              <Text style={[styles.summaryNumber, { color: COLORS.warning }]}>
                {scanResult.detectedInstruments.filter((i: Instrument) => i.status === 'extra').length}
              </Text>
              <Text style={styles.summaryLabel}>En surplus</Text>
            </View>
          </View>
        </View>

        {/* Actions */}
        <View style={styles.actionsContainer}>
          <TouchableOpacity style={styles.primaryButton} onPress={handleExportReport}>
            <Text style={styles.primaryButtonText}>{t('results', 'exportReport')}</Text>
          </TouchableOpacity>
          
          <View style={styles.secondaryActions}>
            <TouchableOpacity style={styles.secondaryButton} onPress={handleSaveComposition}>
              <Text style={styles.secondaryButtonText}>{t('results', 'saveComposition')}</Text>
            </TouchableOpacity>
            
            <TouchableOpacity style={styles.secondaryButton} onPress={handleReconstruct}>
              <Text style={styles.secondaryButtonText}>{t('results', 'reconstruct')}</Text>
            </TouchableOpacity>
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: SIZES.md,
    backgroundColor: COLORS.surface,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.border,
  },
  backButton: {
    padding: SIZES.sm,
  },
  backButtonText: {
    color: COLORS.primary,
    fontSize: 16,
    fontWeight: '600',
  },
  title: {
    fontSize: 18,
    fontWeight: 'bold',
    color: COLORS.text,
  },
  placeholder: {
    width: 60,
  },
  content: {
    flex: 1,
    padding: SIZES.md,
  },
  imageContainer: {
    backgroundColor: COLORS.surface,
    borderRadius: 12,
    padding: SIZES.md,
    marginBottom: SIZES.md,
  },
  scanImage: {
    width: '100%',
    height: 200,
    borderRadius: 8,
    resizeMode: 'contain',
  },
  scoreContainer: {
    backgroundColor: COLORS.surface,
    borderRadius: 12,
    padding: SIZES.lg,
    alignItems: 'center',
    marginBottom: SIZES.md,
  },
  scoreCircle: {
    width: 100,
    height: 100,
    borderRadius: 50,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: SIZES.md,
  },
  scoreText: {
    color: COLORS.surface,
    fontSize: 24,
    fontWeight: 'bold',
  },
  scoreLabel: {
    fontSize: 18,
    fontWeight: 'bold',
    color: COLORS.text,
    marginBottom: SIZES.xs,
  },
  scoreDescription: {
    fontSize: 16,
    color: COLORS.textSecondary,
    textAlign: 'center',
  },
  instrumentsContainer: {
    backgroundColor: COLORS.surface,
    borderRadius: 12,
    padding: SIZES.md,
    marginBottom: SIZES.md,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: COLORS.text,
    marginBottom: SIZES.md,
  },
  instrumentItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: SIZES.md,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.border,
  },
  instrumentInfo: {
    flex: 1,
  },
  instrumentHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: SIZES.xs,
  },
  instrumentIcon: {
    fontSize: 20,
    marginRight: SIZES.sm,
  },
  instrumentName: {
    fontSize: 16,
    fontWeight: '600',
    color: COLORS.text,
  },
  instrumentId: {
    fontSize: 14,
    color: COLORS.textSecondary,
    marginBottom: SIZES.xs,
  },
  instrumentConfidence: {
    fontSize: 12,
    color: COLORS.textSecondary,
  },
  statusBadge: {
    paddingHorizontal: SIZES.md,
    paddingVertical: SIZES.xs,
    borderRadius: 6,
  },
  statusBadgeText: {
    color: COLORS.surface,
    fontSize: 12,
    fontWeight: '600',
  },
  summaryContainer: {
    backgroundColor: COLORS.surface,
    borderRadius: 12,
    padding: SIZES.md,
    marginBottom: SIZES.md,
  },
  summaryGrid: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  summaryItem: {
    alignItems: 'center',
  },
  summaryNumber: {
    fontSize: 24,
    fontWeight: 'bold',
    color: COLORS.success,
    marginBottom: SIZES.xs,
  },
  summaryLabel: {
    fontSize: 14,
    color: COLORS.textSecondary,
  },
  actionsContainer: {
    marginBottom: SIZES.xl,
  },
  primaryButton: {
    backgroundColor: COLORS.primary,
    padding: SIZES.md,
    borderRadius: 8,
    alignItems: 'center',
    marginBottom: SIZES.md,
  },
  primaryButtonText: {
    color: COLORS.surface,
    fontSize: 16,
    fontWeight: '600',
  },
  secondaryActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  secondaryButton: {
    flex: 1,
    backgroundColor: COLORS.surface,
    padding: SIZES.md,
    borderRadius: 8,
    alignItems: 'center',
    marginHorizontal: SIZES.xs,
    borderWidth: 1,
    borderColor: COLORS.border,
  },
  secondaryButtonText: {
    color: COLORS.text,
    fontSize: 14,
    fontWeight: '600',
  },
  errorContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: SIZES.lg,
  },
  errorText: {
    fontSize: 16,
    color: COLORS.textSecondary,
    marginBottom: SIZES.lg,
    textAlign: 'center',
  },
  button: {
    backgroundColor: COLORS.primary,
    paddingHorizontal: SIZES.lg,
    paddingVertical: SIZES.md,
    borderRadius: 8,
  },
  buttonText: {
    color: COLORS.surface,
    fontSize: 16,
    fontWeight: '600',
  },
});

export default ResultsScreen;