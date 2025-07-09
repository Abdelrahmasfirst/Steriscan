import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { useLocalization } from '../utils/localization';
import { COLORS, SIZES } from '../constants';
import { ScanResult } from '../types';

const HistoryScreen: React.FC = () => {
  const navigation = useNavigation();
  const { t } = useLocalization();
  const [scanHistory, setScanHistory] = useState<ScanResult[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    loadScanHistory();
  }, []);

  const loadScanHistory = async () => {
    try {
      // TODO: Charger depuis la base de données
      const mockHistory: ScanResult[] = [
        {
          id: 'scan-1',
          kitId: 'kit-001',
          imageUri: '',
          detectedInstruments: [],
          conformityScore: 95,
          timestamp: new Date().toISOString(),
          status: 'conforming'
        },
        {
          id: 'scan-2',
          kitId: 'kit-002',
          imageUri: '',
          detectedInstruments: [],
          conformityScore: 78,
          timestamp: new Date(Date.now() - 3600000).toISOString(),
          status: 'partial'
        },
        {
          id: 'scan-3',
          kitId: 'kit-003',
          imageUri: '',
          detectedInstruments: [],
          conformityScore: 45,
          timestamp: new Date(Date.now() - 7200000).toISOString(),
          status: 'non-conforming'
        }
      ];
      
      setScanHistory(mockHistory);
    } catch (error) {
      console.error('Error loading scan history:', error);
      Alert.alert('Erreur', 'Impossible de charger l\'historique');
    } finally {
      setIsLoading(false);
    }
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
        return 'Conforme';
      case 'partial':
        return 'Partiel';
      case 'non-conforming':
        return 'Non conforme';
      default:
        return status;
    }
  };

  const formatDate = (timestamp: string) => {
    const date = new Date(timestamp);
    return date.toLocaleDateString('fr-FR') + ' ' + date.toLocaleTimeString('fr-FR', { 
      hour: '2-digit', 
      minute: '2-digit' 
    });
  };

  const handleScanPress = (scan: ScanResult) => {
    navigation.navigate('Results' as never, { scanResult: scan } as never);
  };

  const renderScanItem = ({ item }: { item: ScanResult }) => (
    <TouchableOpacity 
      style={styles.scanItem}
      onPress={() => handleScanPress(item)}
    >
      <View style={styles.scanInfo}>
        <Text style={styles.scanTitle}>Kit {item.kitId}</Text>
        <Text style={styles.scanDate}>{formatDate(item.timestamp)}</Text>
        <Text style={styles.scanScore}>{item.conformityScore}% de conformité</Text>
      </View>
      
      <View style={styles.scanStatus}>
        <View style={[
          styles.statusBadge,
          { backgroundColor: getStatusColor(item.status) }
        ]}>
          <Text style={styles.statusBadgeText}>{getStatusText(item.status)}</Text>
        </View>
        <Text style={styles.arrowText}>→</Text>
      </View>
    </TouchableOpacity>
  );

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>{t('home', 'history')}</Text>
      </View>

      {isLoading ? (
        <View style={styles.centerContainer}>
          <Text style={styles.loadingText}>{t('common', 'loading')}</Text>
        </View>
      ) : scanHistory.length === 0 ? (
        <View style={styles.centerContainer}>
          <Text style={styles.emptyText}>Aucun scan dans l'historique</Text>
          <Text style={styles.emptySubtext}>
            Commencez par scanner votre premier kit
          </Text>
          <TouchableOpacity
            style={styles.scanButton}
            onPress={() => navigation.navigate('Scanner' as never)}
          >
            <Text style={styles.scanButtonText}>Scanner un kit</Text>
          </TouchableOpacity>
        </View>
      ) : (
        <FlatList
          data={scanHistory}
          renderItem={renderScanItem}
          keyExtractor={(item) => item.id}
          style={styles.list}
          contentContainerStyle={styles.listContent}
          showsVerticalScrollIndicator={false}
        />
      )}
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
    fontSize: 24,
    fontWeight: 'bold',
    color: COLORS.text,
    textAlign: 'center',
  },
  centerContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: SIZES.lg,
  },
  loadingText: {
    fontSize: 16,
    color: COLORS.textSecondary,
  },
  emptyText: {
    fontSize: 18,
    color: COLORS.textSecondary,
    marginBottom: SIZES.sm,
    textAlign: 'center',
  },
  emptySubtext: {
    fontSize: 14,
    color: COLORS.textSecondary,
    textAlign: 'center',
    marginBottom: SIZES.lg,
  },
  scanButton: {
    backgroundColor: COLORS.primary,
    paddingHorizontal: SIZES.lg,
    paddingVertical: SIZES.md,
    borderRadius: 8,
  },
  scanButtonText: {
    color: COLORS.surface,
    fontSize: 16,
    fontWeight: '600',
  },
  list: {
    flex: 1,
  },
  listContent: {
    padding: SIZES.md,
  },
  scanItem: {
    backgroundColor: COLORS.surface,
    borderRadius: 12,
    padding: SIZES.md,
    marginBottom: SIZES.md,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
  },
  scanInfo: {
    flex: 1,
  },
  scanTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: COLORS.text,
    marginBottom: SIZES.xs,
  },
  scanDate: {
    fontSize: 14,
    color: COLORS.textSecondary,
    marginBottom: SIZES.xs,
  },
  scanScore: {
    fontSize: 14,
    color: COLORS.text,
    fontWeight: '600',
  },
  scanStatus: {
    alignItems: 'flex-end',
  },
  statusBadge: {
    paddingHorizontal: SIZES.md,
    paddingVertical: SIZES.xs,
    borderRadius: 6,
    marginBottom: SIZES.xs,
  },
  statusBadgeText: {
    color: COLORS.surface,
    fontSize: 12,
    fontWeight: '600',
  },
  arrowText: {
    fontSize: 16,
    color: COLORS.textSecondary,
  },
});

export default HistoryScreen;