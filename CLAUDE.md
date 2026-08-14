# CLAUDE.md

Hinweise für Claude Code in diesem Repository.

## Stand

Frisches Flutter-Projekt (Standard-`flutter create`-Grundgerüst, kein Custom-Code, keine
Architekturentscheidung getroffen). Ziel ist eine Habit-Tracking-App namens PeakHabit für
Android und iOS.

- Package/App-Name: `peakhabit`
- Android-Applikations-ID / iOS-Bundle-Prefix: `com.devarchitecteng.peakhabit`
- Zielplattformen: Android, iOS (siehe `pubspec.yaml`, `android/`, `ios/`)

Bevor Features, Architektur (State Management, Routing, Datenhaltung), CI oder ein
Ticket-Workflow aufgesetzt werden, müssen Produktumfang und ein paar Policy-Fragen geklärt sein
(Zweck/Zielgruppe, Screens, Design, Login/Speicherung, Merge-/Review-Policy). Bis dahin nichts
davon vorab erfinden.

## Befehle

```bash
flutter pub get       # Dependencies installieren
flutter run           # App auf verbundenem Gerät/Emulator starten
dart format .          # Formatieren
flutter analyze       # Statische Analyse (analysis_options.yaml: flutter_lints)
flutter test          # Tests ausführen
```

## Emulatoren/Simulatoren

Lokal verfügbar (siehe `flutter emulators`): `apple_ios_simulator`, `Medium_Phone_API_36.0`,
`Medium_Tablet`. Vor UI-Änderungen einen Emulator/Simulator starten und die App darauf prüfen.
