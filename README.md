# PeakHabit

Fitness-App für Android und iOS: Ernährung, Training und Körpergewicht tracken, plus
Auswertungen über den Verlauf. Alle Daten bleiben lokal auf dem Gerät.

## Stand

Navigationsgerüst mit vier Tabs (Start, Ernährung, Training, Statistik) und Platzhalter-Screens.
Die lokale Datenbank (Drift) ist eingerichtet, hat aber noch keine fachlichen Tabellen.
Noch keine Features.

## Entwicklung

```bash
flutter pub get
flutter run
```

Verfügbare Emulatoren/Simulatoren anzeigen:

```bash
flutter emulators
```

## Qualitätsprüfungen

```bash
dart format .
flutter analyze
flutter test
```

Dieselben Prüfungen laufen in der CI bei jedem Pull Request und Push auf `main`.

## Dokumentation

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — Ordnerstruktur, Technologieentscheidungen
  und ihre Begründung
- [`CLAUDE.md`](CLAUDE.md) — Hinweise für die Arbeit mit Claude Code
- `.claude/skills/` — Ticket-Workflow als Slash-Commands
