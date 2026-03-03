# SteriScan Reconstruct

**Solution IA de traçabilité et reconstitution des kits d'instruments chirurgicaux**

A Flutter mobile application for AI-powered traceability and reconstitution of surgical instrument kits used in hospital sterilization departments.

## Features

- **Reconnaissance Intelligente** — Camera-based scanning with AI instrument identification (YOLOv7)
- **Comparaison & Validation** — Side-by-side reference vs actual kit comparison with anomaly alerts
- **Reconstitution Guidée** — Step-by-step visual instructions for kit reassembly
- **Historique & Rapports** — Complete scan journal with PDF/CSV export
- **Mode Hors-ligne** — 100% offline operation with local SQLite database
- **Multilingue** — French, Swahili, Haoussa support
- **Conformité** — ISO 13485, CE Mark, FDA Class II compliant

## Screens

| Screen | Route | Description |
|--------|-------|-------------|
| Accueil | `/` | Home with scan button, recent history, sync status |
| Scanner | `/scan` | Camera interface with AI scan trigger |
| Résultats | `/results` | Detected instruments with confidence scores |
| Comparaison | `/comparison` | Reference vs actual side-by-side view |
| Reconstitution | `/reconstitution` | Guided step-by-step kit reassembly |
| Historique | `/history` | Scan journal with filtering and export |
| Paramètres | `/settings` | Language, data management, alerts config |

## Tech Stack

- **Flutter** 3.x with Material Design 3
- **GoRouter** for declarative navigation
- **Dio** for HTTP API communication
- **intl** for date formatting and localization

## Project Structure

```
lib/
├── main.dart                  # App entry point
├── models/                    # Data models
│   ├── cycle.dart             # Sterilization cycle
│   ├── instrument.dart        # Surgical instrument
│   ├── kit.dart               # Instrument kit
│   └── scan_result.dart       # Scan result with conformity
├── services/                  # Business logic
│   ├── api_service.dart       # Dio-based REST API client
│   └── mock_data.dart         # Demo/offline mock data
├── screens/                   # App screens
│   ├── home_screen.dart       # Landing page
│   ├── scanner_screen.dart    # Camera & capture
│   ├── results_screen.dart    # Scan results
│   ├── comparison_screen.dart # Reference vs actual
│   ├── reconstitution_screen.dart # Guided reassembly
│   ├── history_screen.dart    # Scan history & reports
│   └── settings_screen.dart   # App settings
├── widgets/                   # Reusable components
│   ├── conformity_badge.dart  # Score badge
│   ├── instrument_tile.dart   # Instrument list item
│   ├── scan_history_card.dart # History card
│   └── status_chip.dart       # Status indicator
├── router/
│   └── app_router.dart        # GoRouter configuration
└── theme/
    └── app_theme.dart         # Material theme & colors
```

## Getting Started

```bash
flutter pub get
flutter run
```

## API

The app communicates with a REST backend at `http://localhost:3000/api` with endpoints:

- `POST /cycles` — Create sterilization cycle
- `GET /cycles` — List cycles
- `GET /kits` — List reference kits
- `POST /scans` — Submit scan for AI analysis
- `GET /scans` — Scan history
- `GET /scans/:id/export/pdf` — Export report

## License

Proprietary — Hospital use only.
