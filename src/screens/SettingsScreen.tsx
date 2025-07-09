import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Switch,
  TextInput,
  Alert,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useLocalization } from '../utils/localization';
import { COLORS, SIZES } from '../constants';
import { Settings, Language } from '../types';

const SettingsScreen: React.FC = () => {
  const { t, currentLanguage, changeLanguage } = useLocalization();
  const [settings, setSettings] = useState<Settings>({
    language: 'fr',
    offlineMode: true,
    smsAlerts: false,
    phoneNumber: '',
    autoSave: true,
    aiConfidenceThreshold: 0.95,
  });

  useEffect(() => {
    loadSettings();
  }, []);

  const loadSettings = async () => {
    try {
      // TODO: Charger depuis la base de données
      setSettings(prev => ({
        ...prev,
        language: currentLanguage,
      }));
    } catch (error) {
      console.error('Error loading settings:', error);
    }
  };

  const saveSettings = async (newSettings: Settings) => {
    try {
      // TODO: Sauvegarder dans la base de données
      setSettings(newSettings);
      console.log('Settings saved:', newSettings);
    } catch (error) {
      console.error('Error saving settings:', error);
      Alert.alert('Erreur', 'Impossible de sauvegarder les paramètres');
    }
  };

  const handleLanguageChange = async (language: Language) => {
    await changeLanguage(language);
    const newSettings = { ...settings, language };
    await saveSettings(newSettings);
  };

  const handleToggle = async (key: keyof Settings, value: boolean) => {
    const newSettings = { ...settings, [key]: value };
    await saveSettings(newSettings);
  };

  const handlePhoneNumberChange = async (phoneNumber: string) => {
    const newSettings = { ...settings, phoneNumber };
    await saveSettings(newSettings);
  };

  const handleThresholdChange = async (threshold: number) => {
    const newSettings = { ...settings, aiConfidenceThreshold: threshold };
    await saveSettings(newSettings);
  };

  const getLanguageName = (lang: Language) => {
    switch (lang) {
      case 'fr':
        return 'Français';
      case 'sw':
        return 'Kiswahili';
      case 'ha':
        return 'Hausa';
      default:
        return lang;
    }
  };

  const SettingItem: React.FC<{
    title: string;
    subtitle?: string;
    children: React.ReactNode;
  }> = ({ title, subtitle, children }) => (
    <View style={styles.settingItem}>
      <View style={styles.settingInfo}>
        <Text style={styles.settingTitle}>{title}</Text>
        {subtitle && (
          <Text style={styles.settingSubtitle}>{subtitle}</Text>
        )}
      </View>
      <View style={styles.settingControl}>
        {children}
      </View>
    </View>
  );

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>{t('settings', 'title')}</Text>
      </View>

      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        {/* Language Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>{t('settings', 'language')}</Text>
          
          {(['fr', 'sw', 'ha'] as Language[]).map((lang) => (
            <TouchableOpacity
              key={lang}
              style={[
                styles.languageOption,
                currentLanguage === lang && styles.languageOptionSelected
              ]}
              onPress={() => handleLanguageChange(lang)}
            >
              <Text style={[
                styles.languageText,
                currentLanguage === lang && styles.languageTextSelected
              ]}>
                {getLanguageName(lang)}
              </Text>
              {currentLanguage === lang && (
                <Text style={styles.checkmark}>✓</Text>
              )}
            </TouchableOpacity>
          ))}
        </View>

        {/* App Settings */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Configuration</Text>
          
          <SettingItem
            title={t('settings', 'offlineMode')}
            subtitle="Fonctionner sans connexion internet"
          >
            <Switch
              value={settings.offlineMode}
              onValueChange={(value) => handleToggle('offlineMode', value)}
              trackColor={{ false: COLORS.border, true: COLORS.primary }}
              thumbColor={COLORS.surface}
            />
          </SettingItem>

          <SettingItem
            title={t('settings', 'autoSave')}
            subtitle="Sauvegarder automatiquement les scans"
          >
            <Switch
              value={settings.autoSave}
              onValueChange={(value) => handleToggle('autoSave', value)}
              trackColor={{ false: COLORS.border, true: COLORS.primary }}
              thumbColor={COLORS.surface}
            />
          </SettingItem>
        </View>

        {/* SMS Alerts */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Alertes SMS</Text>
          
          <SettingItem
            title={t('settings', 'smsAlerts')}
            subtitle="Recevoir des alertes par SMS"
          >
            <Switch
              value={settings.smsAlerts}
              onValueChange={(value) => handleToggle('smsAlerts', value)}
              trackColor={{ false: COLORS.border, true: COLORS.primary }}
              thumbColor={COLORS.surface}
            />
          </SettingItem>

          {settings.smsAlerts && (
            <SettingItem
              title={t('settings', 'phoneNumber')}
              subtitle="Numéro pour les alertes SMS"
            >
              <TextInput
                style={styles.textInput}
                value={settings.phoneNumber}
                onChangeText={handlePhoneNumberChange}
                placeholder="+33 6 12 34 56 78"
                keyboardType="phone-pad"
              />
            </SettingItem>
          )}
        </View>

        {/* AI Settings */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Intelligence Artificielle</Text>
          
          <SettingItem
            title={t('settings', 'aiThreshold')}
            subtitle={`Seuil de confiance: ${Math.round(settings.aiConfidenceThreshold * 100)}%`}
          >
            <View style={styles.thresholdContainer}>
              <TouchableOpacity
                style={styles.thresholdButton}
                onPress={() => handleThresholdChange(Math.max(0.5, settings.aiConfidenceThreshold - 0.05))}
              >
                <Text style={styles.thresholdButtonText}>-</Text>
              </TouchableOpacity>
              
              <Text style={styles.thresholdValue}>
                {Math.round(settings.aiConfidenceThreshold * 100)}%
              </Text>
              
              <TouchableOpacity
                style={styles.thresholdButton}
                onPress={() => handleThresholdChange(Math.min(1.0, settings.aiConfidenceThreshold + 0.05))}
              >
                <Text style={styles.thresholdButtonText}>+</Text>
              </TouchableOpacity>
            </View>
          </SettingItem>
        </View>

        {/* App Info */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Information</Text>
          
          <View style={styles.infoContainer}>
            <Text style={styles.appName}>SteriScan Reconstruct</Text>
            <Text style={styles.appVersion}>Version 1.0.0</Text>
            <Text style={styles.appDescription}>
              Solution IA de traçabilité et reconstitution des kits d'instruments chirurgicaux
            </Text>
            <Text style={styles.compliance}>
              Conformité ISO 13485 | CE Mark | FDA Class II
            </Text>
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
  content: {
    flex: 1,
    padding: SIZES.md,
  },
  section: {
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
  settingItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: SIZES.md,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.border,
  },
  settingInfo: {
    flex: 1,
    marginRight: SIZES.md,
  },
  settingTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: COLORS.text,
  },
  settingSubtitle: {
    fontSize: 14,
    color: COLORS.textSecondary,
    marginTop: SIZES.xs,
  },
  settingControl: {
    alignItems: 'center',
  },
  languageOption: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: SIZES.md,
    paddingHorizontal: SIZES.md,
    marginVertical: SIZES.xs,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: COLORS.border,
  },
  languageOptionSelected: {
    borderColor: COLORS.primary,
    backgroundColor: `${COLORS.primary}10`,
  },
  languageText: {
    fontSize: 16,
    color: COLORS.text,
  },
  languageTextSelected: {
    color: COLORS.primary,
    fontWeight: '600',
  },
  checkmark: {
    fontSize: 16,
    color: COLORS.primary,
    fontWeight: 'bold',
  },
  textInput: {
    borderWidth: 1,
    borderColor: COLORS.border,
    borderRadius: 6,
    paddingHorizontal: SIZES.md,
    paddingVertical: SIZES.sm,
    fontSize: 16,
    color: COLORS.text,
    backgroundColor: COLORS.background,
    minWidth: 150,
  },
  thresholdContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  thresholdButton: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: COLORS.primary,
    alignItems: 'center',
    justifyContent: 'center',
  },
  thresholdButtonText: {
    color: COLORS.surface,
    fontSize: 18,
    fontWeight: 'bold',
  },
  thresholdValue: {
    marginHorizontal: SIZES.md,
    fontSize: 16,
    fontWeight: '600',
    color: COLORS.text,
    minWidth: 50,
    textAlign: 'center',
  },
  infoContainer: {
    alignItems: 'center',
    paddingVertical: SIZES.md,
  },
  appName: {
    fontSize: 20,
    fontWeight: 'bold',
    color: COLORS.primary,
    marginBottom: SIZES.xs,
  },
  appVersion: {
    fontSize: 14,
    color: COLORS.textSecondary,
    marginBottom: SIZES.md,
  },
  appDescription: {
    fontSize: 14,
    color: COLORS.text,
    textAlign: 'center',
    marginBottom: SIZES.md,
    lineHeight: 20,
  },
  compliance: {
    fontSize: 12,
    color: COLORS.textSecondary,
    textAlign: 'center',
    fontStyle: 'italic',
  },
});

export default SettingsScreen;