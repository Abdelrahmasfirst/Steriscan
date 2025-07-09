import { useState, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { translations, Language } from '../locales';

const LANGUAGE_KEY = 'app_language';

export const useLocalization = () => {
  const [currentLanguage, setCurrentLanguage] = useState<Language>('fr');
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    loadSavedLanguage();
  }, []);

  const loadSavedLanguage = async () => {
    try {
      const savedLanguage = await AsyncStorage.getItem(LANGUAGE_KEY);
      if (savedLanguage && (savedLanguage === 'fr' || savedLanguage === 'sw' || savedLanguage === 'ha')) {
        setCurrentLanguage(savedLanguage as Language);
      }
    } catch (error) {
      console.error('Error loading saved language:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const changeLanguage = async (language: Language) => {
    try {
      await AsyncStorage.setItem(LANGUAGE_KEY, language);
      setCurrentLanguage(language);
    } catch (error) {
      console.error('Error saving language:', error);
    }
  };

  const t = (section: string, key: string): string => {
    const sectionTranslations = translations[currentLanguage][section as keyof typeof translations.fr];
    if (sectionTranslations && typeof sectionTranslations === 'object') {
      return (sectionTranslations as any)[key] || key;
    }
    return key;
  };

  return {
    currentLanguage,
    changeLanguage,
    t,
    isLoading
  };
};