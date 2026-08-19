# PeakHabit

Fitness-App für Android und iOS: Ernährung, Training und Körpergewicht tracken, plus
Auswertungen über den Verlauf. Alle Daten bleiben lokal auf dem Gerät.

## Stand

Fünf Tabs in der Bottom-Navigation: Start, Ernährung, Training, Statistik und Optionen.

Vorhanden:

- **Erststart-Onboarding** mit Benutzername, Ziel, Größe, Gewicht und Kalorienziel. Es ist
  verpflichtend und lässt sich nicht überspringen, weil die App auf diesen Werten aufbaut.
- **Optionen** mit Theme-Auswahl (Dark, Light oder Systemeinstellung, gespeichert) und dem
  Nutzerprofil unter `/settings/profile`, das das Kalorienziel auf Wunsch aus Gewicht, Größe,
  Alter, Geschlecht, Aktivität und Ziel berechnet.
- **Start** mit einer Begrüßung, die den hinterlegten Benutzernamen verwendet.

Platzhalter-Screens sind noch Ernährung, Training und Statistik.

Die lokale Datenbank (Drift) hält die Tabellen `user_profiles`, `app_settings` und
`body_weight_entries`. Für Gewichtseinträge gibt es bereits Repository und Provider, aber noch
keine eigenen Screens — gefüllt wird die Tabelle bisher nur vom Onboarding.

## Ordnerstruktur

Feature-first: Was mehrere Features teilen, liegt unter `lib/core/`, alles Fachliche in
seinem eigenen Ordner unter `lib/features/`.

```
lib/
  main.dart      Einstiegspunkt
  app.dart       MaterialApp, Theme- und Router-Bindung
  core/          Geteiltes: database/, logging/, router/, theme/, Startup-Pfad
  features/      je Feature ein Ordner, z.B. onboarding/, profile/, settings/
test/            spiegelt lib/, dazu support/ mit den Fakes für Widget-Tests
docs/            Architektur-Dokumentation
```

Innerhalb eines Features wird nach Bedarf in `presentation/` (Screens und Widgets), `domain/`
(Modelle und Regeln) und `data/` (Drift-Tabelle, Repository, Provider) unterteilt. Die
Schichten entstehen erst, wenn sie gebraucht werden.

Die Begründung dahinter und der vollständige Baum stehen in
[`docs/ARCHITECTURE.md § Ordnerstruktur`](docs/ARCHITECTURE.md#ordnerstruktur).

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
