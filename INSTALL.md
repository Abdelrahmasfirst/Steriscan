# 🚀 Guide d'Installation Rapide - SteriScan Reconstruct

## Démarrage Express (5 minutes)

### 1. Prérequis

Assurez-vous d'avoir installé :
- **Node.js** 16+ ([télécharger](https://nodejs.org))
- **Git** ([télécharger](https://git-scm.com))

### 2. Installation

```bash
# Cloner le projet
git clone [URL_DU_REPO]
cd SteriscanApp

# Installer les dépendances
npm install

# Installer Expo CLI globalement
npm install -g @expo/cli
```

### 3. Lancement

```bash
# Démarrer l'application
npm start
```

Un QR code apparaîtra dans votre terminal et navigateur.

### 4. Tester sur votre téléphone

#### Option A : Avec l'app Expo Go (Recommandé)
1. Téléchargez **Expo Go** sur votre téléphone :
   - [Android - Google Play](https://play.google.com/store/apps/details?id=host.exp.exponent)
   - [iOS - App Store](https://apps.apple.com/app/expo-go/id982107779)

2. Ouvrez Expo Go et scannez le QR code affiché

#### Option B : Simulateur/Émulateur
- **Android** : `npm run android` (nécessite Android Studio)
- **iOS** : `npm run ios` (nécessite Xcode sur macOS)
- **Web** : `npm run web`

## ✅ Test rapide

Une fois l'app lancée, vous devriez voir :

1. 🏠 **Écran d'accueil** avec le titre "SteriScan Reconstruct"
2. 📷 **Bouton "Scanner un Kit"** - teste la navigation
3. 📋 **Onglets** en bas : Accueil, Historique, Paramètres
4. ⚙️ **Paramètres** - teste le changement de langue

## 🔧 Résolution de problèmes

### Erreur "Metro bundler"
```bash
npx expo start --clear
```

### Erreur de permissions caméra
- Autorisez l'accès caméra dans les paramètres de votre téléphone
- Relancez l'application

### Erreur SQLite
```bash
npm install expo-sqlite@latest
expo install --fix
```

### QR Code non reconnu
- Vérifiez que votre téléphone et ordinateur sont sur le même WiFi
- Essayez de redémarrer avec `expo start --tunnel`

## 📱 Fonctionnalités à tester

1. **Scanner** : Prenez une photo (simulation IA)
2. **Résultats** : Visualisez les instruments détectés
3. **Historique** : Consultez les scans précédents
4. **Langues** : Changez entre Français/Swahili/Haoussa
5. **Mode offline** : Fonctionne sans internet

## 🔄 Mise à jour

```bash
# Mettre à jour les dépendances
npm update

# Mettre à jour Expo
expo upgrade
```

## 📧 Support

- **Problème technique** : Créez une issue GitHub
- **Question** : Consultez le README.md détaillé
- **Demo** : L'app fonctionne en mode simulation par défaut

---

🎉 **Félicitations !** Vous avez SteriScan Reconstruct qui fonctionne sur votre appareil !