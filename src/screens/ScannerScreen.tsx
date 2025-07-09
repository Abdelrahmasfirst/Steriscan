import React, { useState, useRef, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Alert,
  ActivityIndicator,
  Image,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useNavigation, useRoute } from '@react-navigation/native';
import { Camera, CameraType } from 'expo-camera';
import * as MediaLibrary from 'expo-media-library';
import { useLocalization } from '../utils/localization';
import { COLORS, SIZES } from '../constants';
import { aiService } from '../services/aiService';

const ScannerScreen: React.FC = () => {
  const navigation = useNavigation();
  const route = useRoute();
  const { t } = useLocalization();
  
  const [hasPermission, setHasPermission] = useState<boolean | null>(null);
  const [type, setType] = useState(CameraType.back);
  const [capturedImage, setCapturedImage] = useState<string | null>(null);
  const [isProcessing, setIsProcessing] = useState(false);
  const [flashMode, setFlashMode] = useState(false);
  
  const cameraRef = useRef<Camera>(null);

  useEffect(() => {
    (async () => {
      const { status } = await Camera.requestCameraPermissionsAsync();
      setHasPermission(status === 'granted');
      
      const mediaLibraryStatus = await MediaLibrary.requestPermissionsAsync();
      if (mediaLibraryStatus.status !== 'granted') {
        Alert.alert('Permission requise', 'Permission d\'accès à la galerie nécessaire');
      }
    })();
  }, []);

  const takePicture = async () => {
    if (cameraRef.current) {
      try {
        const photo = await cameraRef.current.takePictureAsync({
          quality: 0.8,
          base64: false,
        });
        
        setCapturedImage(photo.uri);
        
        // Sauvegarder dans la galerie
        await MediaLibrary.saveToLibraryAsync(photo.uri);
        
      } catch (error) {
        console.error('Error taking picture:', error);
        Alert.alert('Erreur', 'Impossible de prendre la photo');
      }
    }
  };

  const retakePicture = () => {
    setCapturedImage(null);
  };

  const analyzeImage = async () => {
    if (!capturedImage) return;
    
    setIsProcessing(true);
    
    try {
      // Analyser l'image avec l'IA
      const result = await aiService.detectInstruments(capturedImage);
      
      // Créer un résultat de scan
      const scanResult = {
        id: `scan-${Date.now()}`,
        kitId: (route.params as any)?.kitId || `kit-${Date.now()}`,
        imageUri: capturedImage,
        detectedInstruments: result.instruments,
        conformityScore: aiService.calculateConformityScore(result.instruments, []),
        timestamp: new Date().toISOString(),
        status: result.instruments.filter(i => i.status === 'present').length >= result.instruments.length * 0.9 
          ? 'conforming' 
          : result.instruments.filter(i => i.status === 'present').length >= result.instruments.length * 0.7
            ? 'partial'
            : 'non-conforming'
      };

      // Naviguer vers les résultats
      navigation.navigate('Results' as never, { scanResult } as never);
      
    } catch (error) {
      console.error('Error analyzing image:', error);
      Alert.alert('Erreur', 'Erreur lors de l\'analyse de l\'image');
    } finally {
      setIsProcessing(false);
    }
  };

  const toggleFlash = () => {
    setFlashMode(!flashMode);
  };

  if (hasPermission === null) {
    return (
      <View style={styles.container}>
        <Text>Demande de permission...</Text>
      </View>
    );
  }

  if (hasPermission === false) {
    return (
      <View style={styles.container}>
        <Text style={styles.noPermissionText}>
          Permission caméra refusée. Veuillez autoriser l'accès à la caméra dans les paramètres.
        </Text>
        <TouchableOpacity
          style={styles.button}
          onPress={() => navigation.goBack()}
        >
          <Text style={styles.buttonText}>Retour</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Text style={styles.backButtonText}>← Retour</Text>
        </TouchableOpacity>
        
        <Text style={styles.title}>{t('scanner', 'title')}</Text>
        
        <TouchableOpacity style={styles.flashButton} onPress={toggleFlash}>
          <Text style={styles.flashButtonText}>{flashMode ? '🔦' : '💡'}</Text>
        </TouchableOpacity>
      </View>

      {capturedImage ? (
        <View style={styles.previewContainer}>
          <Image source={{ uri: capturedImage }} style={styles.previewImage} />
          
          <View style={styles.previewActions}>
            <TouchableOpacity style={styles.retakeButton} onPress={retakePicture}>
              <Text style={styles.retakeButtonText}>Reprendre</Text>
            </TouchableOpacity>
            
            <TouchableOpacity 
              style={[styles.analyzeButton, isProcessing && styles.analyzeButtonDisabled]} 
              onPress={analyzeImage}
              disabled={isProcessing}
            >
              {isProcessing ? (
                <ActivityIndicator color={COLORS.surface} />
              ) : (
                <Text style={styles.analyzeButtonText}>{t('scanner', 'analyzePhoto')}</Text>
              )}
            </TouchableOpacity>
          </View>

          {isProcessing && (
            <View style={styles.processingOverlay}>
              <ActivityIndicator size="large" color={COLORS.primary} />
              <Text style={styles.processingText}>{t('scanner', 'processing')}</Text>
            </View>
          )}
        </View>
      ) : (
        <View style={styles.cameraContainer}>
          <Camera
            ref={cameraRef}
            style={styles.camera}
            type={type}
            flashMode={flashMode ? 'torch' : 'off'}
          >
            <View style={styles.cameraOverlay}>
              <View style={styles.guidanceContainer}>
                <Text style={styles.guidanceText}>{t('scanner', 'guidanceText')}</Text>
              </View>
              
              <View style={styles.scanFrame} />
              
              <View style={styles.cameraActions}>
                <TouchableOpacity
                  style={styles.flipButton}
                  onPress={() => setType(type === CameraType.back ? CameraType.front : CameraType.back)}
                >
                  <Text style={styles.flipButtonText}>🔄</Text>
                </TouchableOpacity>
                
                <TouchableOpacity style={styles.captureButton} onPress={takePicture}>
                  <View style={styles.captureButtonInner} />
                </TouchableOpacity>
                
                <View style={styles.placeholder} />
              </View>
            </View>
          </Camera>
        </View>
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
  flashButton: {
    padding: SIZES.sm,
  },
  flashButtonText: {
    fontSize: 20,
  },
  cameraContainer: {
    flex: 1,
  },
  camera: {
    flex: 1,
  },
  cameraOverlay: {
    flex: 1,
    backgroundColor: 'transparent',
    justifyContent: 'space-between',
  },
  guidanceContainer: {
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
    padding: SIZES.md,
    margin: SIZES.md,
    borderRadius: 8,
  },
  guidanceText: {
    color: COLORS.surface,
    fontSize: 16,
    textAlign: 'center',
  },
  scanFrame: {
    alignSelf: 'center',
    width: 300,
    height: 200,
    borderWidth: 2,
    borderColor: COLORS.primary,
    borderRadius: 8,
    backgroundColor: 'transparent',
  },
  cameraActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: SIZES.xl,
    paddingBottom: SIZES.xl,
  },
  flipButton: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  flipButtonText: {
    fontSize: 20,
  },
  captureButton: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: COLORS.surface,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 4,
    borderColor: COLORS.primary,
  },
  captureButtonInner: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: COLORS.primary,
  },
  placeholder: {
    width: 50,
  },
  previewContainer: {
    flex: 1,
    position: 'relative',
  },
  previewImage: {
    flex: 1,
    resizeMode: 'contain',
  },
  previewActions: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
    backgroundColor: COLORS.surface,
    padding: SIZES.md,
  },
  retakeButton: {
    backgroundColor: COLORS.textSecondary,
    paddingHorizontal: SIZES.lg,
    paddingVertical: SIZES.md,
    borderRadius: 8,
  },
  retakeButtonText: {
    color: COLORS.surface,
    fontSize: 16,
    fontWeight: '600',
  },
  analyzeButton: {
    backgroundColor: COLORS.primary,
    paddingHorizontal: SIZES.lg,
    paddingVertical: SIZES.md,
    borderRadius: 8,
    minWidth: 120,
    alignItems: 'center',
  },
  analyzeButtonDisabled: {
    opacity: 0.6,
  },
  analyzeButtonText: {
    color: COLORS.surface,
    fontSize: 16,
    fontWeight: '600',
  },
  processingOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.8)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  processingText: {
    color: COLORS.surface,
    fontSize: 18,
    marginTop: SIZES.md,
  },
  noPermissionText: {
    fontSize: 16,
    textAlign: 'center',
    margin: SIZES.lg,
    color: COLORS.text,
  },
  button: {
    backgroundColor: COLORS.primary,
    padding: SIZES.md,
    borderRadius: 8,
    margin: SIZES.md,
    alignItems: 'center',
  },
  buttonText: {
    color: COLORS.surface,
    fontSize: 16,
    fontWeight: '600',
  },
});

export default ScannerScreen;