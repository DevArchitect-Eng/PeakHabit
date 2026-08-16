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

Aktueller Stand: Navigationsgerüst mit Platzhalter-Screens. Die Drift-Datenbank ist
eingerichtet; als erste fachliche Tabelle liegt das Nutzerprofil darin (Datenschicht ohne
UI). Ansonsten noch keine Features.

## Technisches

Entscheidungen und Begründungen stehen in `docs/ARCHITECTURE.md` — dort nachlesen, nicht hier
duplizieren. Kurzfassung:

- Feature-first unter `lib/features/`, Geteiltes unter `lib/core/`
- State Management: Riverpod
- Routing: go_router mit `StatefulShellRoute` (eigener Stack je Tab)
- Persistenz: Drift (SQLite) unter `lib/core/database/`, lokal, kein Account, kein Backend.
  **Tabellen entstehen pro Feature**, nicht als vorab entworfenes Gesamtschema — jedes Ticket
  bringt die Tabelle mit, die es braucht, samt Migration. Die Schritte dafür stehen in
  `docs/ARCHITECTURE.md`
- Logging: zentraler `AppLogger` unter `lib/core/logging/`, rein lokal — kein Analytik- oder
  Crash-Reporting-Dienst. Details in `docs/ARCHITECTURE.md`
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
dart run build_runner build   # nach Änderungen am Datenbankschema
```

Die drei Prüfungen `dart format .`, `flutter analyze` und `flutter test` nach jeder
inhaltlichen Änderung ausführen. Die CI
(`.github/workflows/ci.yml`) prüft dasselbe bei PRs und Pushes auf `main`.

## Commits

Gilt für **jeden** Commit — Ticket-Arbeit, Setup-Änderungen, Doku, alles.

### Format

```
<prefix>: <kurz, worum es geht>

- einzelne Änderung
- noch eine, wenn sie eigenständig erklärungswürdig ist
```

Betreff imperativ, englisch, kleingeschrieben nach dem Doppelpunkt, kein Punkt am Ende,
möglichst unter 72 Zeichen. Die `-`-Punkte sind optional: Bei einem Einzeiler-Commit weglassen,
statt Selbstverständliches aufzuzählen. Wo das *Warum* nicht offensichtlich ist, gehört es in
einen Absatz unter die Liste.

### Prefixe

| Prefix | Wofür |
| --- | --- |
| `feature` | neue Funktionalität |
| `fix` | Fehlerbehebung |
| `refactor` | Umbau ohne Verhaltensänderung |
| `test` | nur Tests |
| `doc` | nur Dokumentation |
| `ci` | Workflows, Build-Pipeline |
| `chore` | Abhängigkeiten, Konfiguration, Aufräumen |

Passt nichts eindeutig, entscheidet der Hauptzweck der Änderung — nicht die Mehrheit der
Zeilen.

### Zuschnitt

**Kleine Commits, nicht ein großer am Ende.** Ein Commit umfasst eine abgeschlossene,
nachvollziehbare Einheit — auch innerhalb eines einzelnen Features. Sobald ein Teilschritt
für sich funktioniert und die Prüfungen grün sind: committen.

Konkret heißt das:

- Datenmodell, UI und Tests eines Features werden getrennt committet, wenn sie je für sich
  Sinn ergeben.
- Braucht der Betreff ein „und", ist es vermutlich mehr als ein Commit.
- Mischt ein Commit mehrere Prefixe (z.B. Feature *und* CI-Änderung), aufteilen.
- Reines Formatieren oder Umbenennen kommt in einen eigenen `refactor`/`chore`-Commit, damit
  die inhaltliche Änderung im Diff sichtbar bleibt.

Jeder Commit soll für sich lauffähig sein — `flutter analyze` und `flutter test` grün. Keine
absichtlich kaputten Zwischenstände.

### Beispiel

```
feature: add body weight entry to the home screen

- add BodyWeightEntry model and Drift table
- add repository with insert and latest-value query
- wire the home screen widget to the repository
```

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

## Boards

| Board | Zweck |
| --- | --- |
| [Kanban](https://github.com/users/DevArchitect-Eng/projects/2) | echte Tickets, von den Skills gepflegt |
| [Ideen](https://github.com/users/DevArchitect-Eng/projects/1) | Vormerkungen, die noch keine Tickets sind |

Das Ideen-Board enthält Draft-Items, die sich per Klick in Issues umwandeln lassen — dort
stehen unter anderem Push-Erinnerungen, Health-Integration, Achievements, Cloud-Sync und die
Store-Veröffentlichung. Die Ticket-Skills fassen dieses Board nicht an.

Eine Store-Veröffentlichung ist perspektivisch geplant — App-Icons, Berechtigungstexte und
Datenschutzanforderungen daher früh mitdenken.
