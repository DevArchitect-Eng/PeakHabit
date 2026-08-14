# CLAUDE.md

Hinweise für Claude Code in diesem Repository.

## Produkt

PeakHabit ist eine Fitness-App für Android und iOS. Getrackt werden Ernährung, Training und
Körpergewicht, dazu Auswertungen über den Verlauf.

Vier Tabs in der Bottom-Navigation:

| Tab | Route | Inhalt |
| --- | --- | --- |
| Start | `/home` | Übersicht, Körpergewicht eintragen |
| Ernährung | `/nutrition` | Mahlzeiten und Nährwerte |
| Training | `/training` | Trainingspläne erstellen, Workouts starten |
| Statistik | `/stats` | Trainingsfortschritt, Gewichtsverlauf |

Aktueller Stand: Navigationsgerüst mit Platzhalter-Screens. Noch keine Features, keine
Datenhaltung.

## Technisches

Entscheidungen und Begründungen stehen in `docs/ARCHITECTURE.md` — dort nachlesen, nicht hier
duplizieren. Kurzfassung:

- Feature-first unter `lib/features/`, Geteiltes unter `lib/core/`
- State Management: Riverpod
- Routing: go_router mit `StatefulShellRoute` (eigener Stack je Tab)
- Persistenz: lokal, kein Account, kein Backend. Drift ist vorgesehen, aber noch nicht
  eingebaut
- Design: dark-first, hellblauer Akzent (`#38BDF8`), `themeMode` fest auf dark

Package-Strategie: zurückhaltend. Neue Abhängigkeiten nur, wenn sie ein echtes Problem lösen.
Cloud-Dienste, Bezahlservices, Analytik, Werbung oder Tracking **nie ohne Freigabe** einbauen.

## Befehle

```bash
flutter pub get
flutter run
dart format .
flutter analyze
flutter test
```

Diese drei Prüfungen nach jeder inhaltlichen Änderung ausführen. Die CI
(`.github/workflows/ci.yml`) prüft dasselbe bei PRs und Pushes auf `main`.

## UI prüfen

Verfügbar: `apple_ios_simulator`, `Medium_Phone_API_36.0`, `Medium_Tablet`.

Die native Simulator-Integration braucht einmalig
`sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` durch den Nutzer. Schlägt
sie fehl, ersatzweise über `xcrun simctl` bauen/installieren/screenshotten — und das im
Bericht offenlegen, nicht stillschweigend wechseln.

## Ticket-Workflow

Neun Skills unter `.claude/skills/`. Die geteilten Referenzen liegen in
`.claude/skills/ticket-workflow-shared/references/` — dort nachschlagen statt Werte neu zu
ermitteln:

| Datei | Inhalt |
| --- | --- |
| `board.md` | Project- und Feld-IDs (Status, Priority, Size, Quelle), Labels |
| `ticket-format.md` | Issue-Body-Formate, Feld-Heuristiken, Abhängigkeits-Formulierungen |
| `conventions.md` | Branch-, Commit-, PR-, CI- und Merge-Konventionen |
| `log-format.md` | Log-Datei für den Loop-Modus |

Das Board hat **kein** Blocker-Feld: Abhängigkeiten müssen als Text im Issue stehen
(„braucht #49", „nach #49"). Fehlt so eine Formulierung, gilt ein Ticket als unabhängig.

**Merge-Policy ist konservativ:** Code Review vor jedem Merge, Security Review zusätzlich bei
sicherheits-/datenrelevanten Änderungen, und **niemals selbst mergen** — Merge braucht immer
die ausdrückliche Freigabe des Nutzers. Details in
`.claude/skills/ticket-workflow-shared/references/conventions.md`.

## Geplant, aber nicht umgesetzt

Lokale Push-Erinnerungen, Apple Health / Google Fit, Achievements/Streaks. Eine
Store-Veröffentlichung ist perspektivisch geplant — App-Icons, Berechtigungstexte und
Datenschutzanforderungen früh mitdenken.
