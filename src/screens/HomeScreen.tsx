import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Alert,
  StatusBar,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { useLocalization } from '../utils/localization';
import { COLORS, SIZES } from '../constants';
import { ScanResult } from '../types';

const HomeScreen: React.FC = () => {
  const navigation = useNavigation();
  const { t } = useLocalization();
  const [lastScans, setLastScans] = useState<ScanResult[]>([]);
  const [isOnline, setIsOnline] = useState(false);

  useEffect(() => {
    loadLastScans();
  }, []);

  const loadLastScans = async () => {
    try {
      // Charger les derniers scans depuis la base de données
      // TODO: Implémenter avec databaseService.getAllScanResults()
      const mockScans: ScanResult[] = [
        {
          id: 'scan-1',
          kitId: 'kit-1',
          imageUri: '',
          detectedInstruments: [],
          conformityScore: 95,
          timestamp: new Date().toISOString(),
          status: 'conforming'
        },
        {
          id: 'scan-2',
          kitId: 'kit-2',
          imageUri: '',
          detectedInstruments: [],
          conformityScore: 78,
          timestamp: new Date(Date.now() - 3600000).toISOString(),
          status: 'partial'
        }
      ];
      setLastScans(mockScans);
    } catch (error) {
      console.error('Error loading last scans:', error);
    }
  };

  const handleScanKit = () => {
    navigation.navigate('Scanner' as never);
  };

  const handleViewHistory = () => {
    navigation.navigate('History' as never);
  };

  const handleSettings = () => {
    navigation.navigate('Settings' as never);
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'conforming':
        return COLORS.success;
      case 'partial':
        return COLORS.warning;
      case 'non-conforming':
        return COLORS.error;
      default:
        return COLORS.textSecondary;
    }
  };

  const getStatusText = (status: string) => {
    switch (status) {
      case 'conforming':
        return t('results', 'conforming');
      case 'partial':
        return t('results', 'partial');
      case 'non-conforming':
        return t('results', 'nonConforming');
      default:
        return status;
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor={COLORS.background} />
      
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.title}>{t('home', 'title')}</Text>
        <Text style={styles.subtitle}>{t('home', 'subtitle')}</Text>
        
        {/* Sync Status */}
        <View style={styles.syncStatus}>
          <View style={[styles.syncIndicator, { backgroundColor: isOnline ? COLORS.success : COLORS.warning }]} />
          <Text style={styles.syncText}>
            {isOnline ? 'En ligne' : 'Mode hors-ligne'}
          </Text>
        </View>
      </View>

      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        {/* Main Actions */}
        <View style={styles.actionsContainer}>
          <TouchableOpacity style={styles.primaryButton} onPress={handleScanKit}>
            <View style={styles.buttonIcon}>
              <Text style={styles.buttonIconText}>📷</Text>
            </View>
            <Text style={styles.primaryButtonText}>{t('home', 'scanKit')}</Text>
          </TouchableOpacity>

          <View style={styles.secondaryActions}>
            <TouchableOpacity style={styles.secondaryButton} onPress={handleViewHistory}>
              <Text style={styles.secondaryButtonIcon}>📋</Text>
              <Text style={styles.secondaryButtonText}>{t('home', 'history')}</Text>
            </TouchableOpacity>

            <TouchableOpacity style={styles.secondaryButton} onPress={handleSettings}>
              <Text style={styles.secondaryButtonIcon}>⚙️</Text>
              <Text style={styles.secondaryButtonText}>{t('home', 'settings')}</Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* Recent Scans */}
        <View style={styles.recentScans}>
          <Text style={styles.sectionTitle}>{t('home', 'lastScans')}</Text>
          
          {lastScans.length === 0 ? (
            <View style={styles.emptyState}>
              <Text style={styles.emptyStateText}>Aucun scan récent</Text>
              <Text style={styles.emptyStateSubtext}>Commencez par scanner votre premier kit</Text>
            </View>
          ) : (
            lastScans.map((scan) => (
              <TouchableOpacity
                key={scan.id}
                style={styles.scanItem}
                onPress={() => navigation.navigate('Results' as never, { scanId: scan.id } as never)}
              >
                <View style={styles.scanInfo}>
                  <Text style={styles.scanTitle}>Kit {scan.kitId}</Text>
                  <Text style={styles.scanDate}>
                    {new Date(scan.timestamp).toLocaleDateString('fr-FR')}
                  </Text>
                </View>
                
                <View style={styles.scanStatus}>
                  <Text style={styles.scanScore}>{scan.conformityScore}%</Text>
                  <View style={[styles.statusBadge, { backgroundColor: getStatusColor(scan.status) }]}>
                    <Text style={styles.statusBadgeText}>{getStatusText(scan.status)}</Text>
                  </View>
                </View>
              </TouchableOpacity>
            ))
          )}
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
    padding: SIZES.md,
    backgroundColor: COLORS.surface,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.border,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: COLORS.primary,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 16,
    color: COLORS.textSecondary,
    textAlign: 'center',
    marginTop: SIZES.xs,
  },
  syncStatus: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: SIZES.md,
  },
  syncIndicator: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: SIZES.xs,
  },
  syncText: {
    fontSize: 14,
    color: COLORS.textSecondary,
  },
  content: {
    flex: 1,
    padding: SIZES.md,
  },
  actionsContainer: {
    marginBottom: SIZES.xl,
  },
  primaryButton: {
    backgroundColor: COLORS.primary,
    padding: SIZES.lg,
    borderRadius: 16,
    alignItems: 'center',
    marginBottom: SIZES.md,
    elevation: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  buttonIcon: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: SIZES.md,
  },
  buttonIconText: {
    fontSize: 30,
  },
  primaryButtonText: {
    color: COLORS.surface,
    fontSize: 18,
    fontWeight: 'bold',
  },
  secondaryActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  secondaryButton: {
    flex: 1,
    backgroundColor: COLORS.surface,
    padding: SIZES.md,
    borderRadius: 12,
    alignItems: 'center',
    marginHorizontal: SIZES.xs,
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
  },
  secondaryButtonIcon: {
    fontSize: 24,
    marginBottom: SIZES.xs,
  },
  secondaryButtonText: {
    color: COLORS.text,
    fontSize: 14,
    fontWeight: '600',
  },
  recentScans: {
    backgroundColor: COLORS.surface,
    borderRadius: 12,
    padding: SIZES.md,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: COLORS.text,
    marginBottom: SIZES.md,
  },
  emptyState: {
    alignItems: 'center',
    padding: SIZES.xl,
  },
  emptyStateText: {
    fontSize: 16,
    color: COLORS.textSecondary,
    marginBottom: SIZES.xs,
  },
  emptyStateSubtext: {
    fontSize: 14,
    color: COLORS.textSecondary,
    textAlign: 'center',
  },
  scanItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: SIZES.md,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.border,
  },
  scanInfo: {
    flex: 1,
  },
  scanTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: COLORS.text,
  },
  scanDate: {
    fontSize: 14,
    color: COLORS.textSecondary,
    marginTop: SIZES.xs,
  },
  scanStatus: {
    alignItems: 'flex-end',
  },
  scanScore: {
    fontSize: 18,
    fontWeight: 'bold',
    color: COLORS.text,
    marginBottom: SIZES.xs,
  },
  statusBadge: {
    paddingHorizontal: SIZES.sm,
    paddingVertical: SIZES.xs,
    borderRadius: 6,
  },
  statusBadgeText: {
    color: COLORS.surface,
    fontSize: 12,
    fontWeight: '600',
  },
});

export default HomeScreen;