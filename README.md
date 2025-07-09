# 📱 SteriScan Reconstruct - Application Mobile

## Description

**SteriScan Reconstruct** est une application mobile développée avec React Native pour la traçabilité et reconstitution des kits d'instruments chirurgicaux utilisant l'intelligence artificielle.

### Caractéristiques principales

- 🔍 **Reconnaissance IA** - Scanner photo/vidéo avec détection automatique d'instruments
- 📱 **Mobile-first** - Optimisé pour smartphones Android/iOS
- 🌍 **Multilingue** - Support Français, Swahili, Haoussa
- 💾 **Mode offline** - Base de données SQLite locale
- 📊 **Traçabilité complète** - Historique et rapports de conformité
- ⚙️ **Paramétrable** - Seuils IA, alertes SMS, langues

## Structure du projet

```
SteriscanApp/
├── App.tsx                     # Point d'entrée principal
├── src/
│   ├── screens/               # Écrans de l'application
│   │   ├── HomeScreen.tsx     # Écran d'accueil
│   │   ├── ScannerScreen.tsx  # Scanner caméra
│   │   ├── ResultsScreen.tsx  # Résultats de scan
│   │   ├── HistoryScreen.tsx  # Historique des scans
│   │   └── SettingsScreen.tsx # Paramètres
│   ├── components/            # Composants réutilisables
│   ├── services/              # Services métier
│   │   └── aiService.ts       # Service IA reconnaissance
│   ├── database/              # Base de données SQLite
│   │   └── database.ts        # Service base de données
│   ├── utils/                 # Utilitaires
│   │   └── localization.ts    # Gestion multilingue
│   ├── types/                 # Types TypeScript
│   │   └── index.ts           # Interfaces principales
│   ├── constants/             # Constantes
│   │   └── index.ts           # Couleurs, tailles, config
│   └── locales/               # Traductions
│       └── index.ts           # FR/SW/HA translations
├── package.json               # Dépendances
└── README.md                  # Ce fichier
```

## Installation

### Prérequis

- Node.js (v16+)
- npm ou yarn
- Expo CLI
- Android Studio (pour Android)
- Xcode (pour iOS, sur macOS uniquement)

### Étapes d'installation

1. **Cloner le projet**
```bash
git clone [URL_DU_REPO]
cd SteriscanApp
```

2. **Installer les dépendances**
```bash
npm install
```

3. **Installer Expo CLI** (si pas déjà fait)
```bash
npm install -g @expo/cli
```

4. **Démarrer le serveur de développement**
```bash
npm start
# ou
expo start
```

5. **Lancer sur un appareil**
   - **Android**: `npm run android` ou scanner le QR code avec Expo Go
   - **iOS**: `npm run ios` ou scanner le QR code avec Expo Go
   - **Web**: `npm run web`

## Fonctionnalités

### 🏠 Écran d'Accueil
- Vue d'ensemble des derniers scans
- Accès rapide au scanner
- Statut de synchronisation offline/online

### 📷 Scanner IA
- Interface caméra avec guidage visuel
- Prise de photo optimisée pour instruments
- Analyse IA en temps réel
- Support flash et rotation

### 📊 Résultats de Scan
- Score de conformité en temps réel
- Liste détaillée des instruments détectés
- Status: Présent/Manquant/En surplus
- Export de rapports PDF/SMS

### 📋 Historique
- Journal complet des scans précédents
- Filtrage par date et conformité
- Recherche par kit ID

### ⚙️ Paramètres
- **Langues**: Français, Swahili, Haoussa
- **Mode offline**: Fonctionnement sans internet
- **Alertes SMS**: Notifications en cas d'anomalie
- **Seuils IA**: Configuration de la confiance minimum

## Technologies utilisées

### Framework et UI
- **React Native** avec Expo
- **TypeScript** pour la sécurité des types
- **React Navigation** pour la navigation
- **Expo Camera** pour la capture d'images

### Base de données et stockage
- **SQLite** (expo-sqlite) pour le stockage offline
- **AsyncStorage** pour les préférences utilisateur
- **Expo File System** pour la gestion de fichiers

### Services IA et analyses
- **Service IA simulé** (prêt pour TensorFlow Lite/YOLOv7)
- **Reconnaissance d'instruments** configurable
- **Algorithmes de comparaison** et scoring

### Fonctionnalités natives
- **Expo Media Library** pour sauvegarder photos
- **Expo Notifications** pour alertes locales
- **React Native Share** pour export de rapports

## Configuration

### Variables d'environnement

Créer un fichier `.env` à la racine:

```env
# Configuration IA
AI_MODEL_VERSION=1.0
AI_CONFIDENCE_THRESHOLD=0.95

# Configuration SMS (optionnel)
SMS_API_KEY=your_sms_api_key
SMS_SENDER_ID=SteriScan

# Configuration base de données
DB_NAME=steriscan.db
DB_VERSION=1
```

### Personnalisation

1. **Instruments supportés**: Modifier `INSTRUMENT_TYPES` dans `src/constants/index.ts`

2. **Langues**: Ajouter de nouvelles traductions dans `src/locales/index.ts`

3. **Couleurs et thème**: Personnaliser `COLORS` dans `src/constants/index.ts`

4. **Seuils de conformité**: Ajuster `CONFORMITY_THRESHOLDS`

## API et Services

### Service IA (`aiService.ts`)

```typescript
// Détecter instruments dans une image
const result = await aiService.detectInstruments(imageUri);

// Calculer score de conformité
const score = aiService.calculateConformityScore(detected, reference);

// Comparer avec référence
const comparison = aiService.compareWithReference(detected, reference);
```

### Service Base de données (`database.ts`)

```typescript
// Sauvegarder un kit
await databaseService.saveKit(kit);

// Récupérer historique des scans
const scans = await databaseService.getAllScanResults();

// Gérer les paramètres
const settings = await databaseService.getSettings();
await databaseService.updateSettings(newSettings);
```

## Déploiement

### Build de production

1. **Android APK**
```bash
expo build:android
```

2. **iOS IPA** (sur macOS)
```bash
expo build:ios
```

3. **Web**
```bash
npm run build
```

### Publication

1. **Google Play Store**
```bash
expo upload:android
```

2. **Apple App Store**
```bash
expo upload:ios
```

## Tests

```bash
# Tests unitaires
npm test

# Tests d'intégration
npm run test:integration

# Tests E2E avec Detox
npm run test:e2e
```

## Conformité et Sécurité

### Normes respectées
- **ISO 13485** - Systèmes de management de la qualité pour dispositifs médicaux
- **CE Mark** - Conformité européenne
- **FDA Class II** - Réglementation américaine

### Sécurité des données
- Chiffrement AES-256 pour données sensibles
- Authentification biométrique (optionnelle)
- Journalisation d'audit complète
- Mode offline pour éviter transfert de données

## Support et maintenance

### Logs et debugging

```typescript
// Activer les logs détaillés
console.log('AI Detection:', result);
console.log('Database Operation:', operation);
```

### Monitoring

- Performance de l'IA trackée
- Statistiques d'usage collectées
- Rapports d'erreurs automatiques

## Roadmap

### Version 1.1
- [ ] Intégration TensorFlow Lite réelle
- [ ] Support NFC pour identification kits
- [ ] Synchronisation cloud optionnelle

### Version 1.2
- [ ] Mode collaboratif multi-utilisateurs
- [ ] Intégration avec ERP hospitaliers
- [ ] Analytics avancées et tableaux de bord

### Version 2.0
- [ ] Réalité augmentée pour guidage
- [ ] Blockchain pour traçabilité
- [ ] API REST pour intégrations tierces

## Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commit les changements (`git commit -am 'Ajout nouvelle fonctionnalité'`)
4. Push sur la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Créer une Pull Request

## Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## Contact

- **Email**: support@steriscan.com
- **Documentation**: https://docs.steriscan.com
- **Issues**: https://github.com/steriscan/app/issues

---

**SteriScan Reconstruct** - Révolutionner la traçabilité chirurgicale avec l'IA 🏥🤖