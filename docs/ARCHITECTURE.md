# Architektur

## Überblick

PeakHabit ist eine Fitness-App zum Tracken von Ernährung, Training und Körpergewicht.
Alle Daten liegen lokal auf dem Gerät; es gibt keinen Account und kein Backend.

Zielplattformen: Android und iOS.

## Ordnerstruktur

Feature-first. Jedes Feature besitzt seinen eigenen Ordner unter `lib/features/`; alles,
was mehrere Features teilen, liegt unter `lib/core/`.

```
lib/
  main.dart                     Einstiegspunkt, setzt ProviderScope
  app.dart                      MaterialApp.router, Theme- und Router-Bindung
  core/
    database/                   Drift-Datenbank, Verbindung, Provider
    router/app_router.dart      go_router-Konfiguration
    theme/app_theme.dart        Farbschema, Light/Dark
  features/
    shell/                      Bottom-Navigation-Gerüst
    home/                       Startseite (u.a. Körpergewicht-Widget)
    nutrition/                  Ernährungstracking
    training/                   Trainingspläne und Workouts
    stats/                      Auswertungen und Diagramme
```

Innerhalb eines Features wird nach Bedarf in `presentation/`, `domain/` und `data/`
unterteilt. Solange ein Feature nur UI hat, existiert nur `presentation/` — Schichten
werden erst angelegt, wenn sie tatsächlich gebraucht werden.

## Entscheidungen

### State Management: Riverpod

`flutter_riverpod`, weil es ohne BuildContext testbar ist, Compile-Time-sicher arbeitet und
für ein lokal-first Datenmodell gut mit asynchronen Quellen (Datenbank-Streams) zusammenspielt.
`ProviderScope` sitzt in `main.dart`.

### Routing: go_router mit StatefulShellRoute

`StatefulShellRoute.indexedStack` gibt jedem der vier Tabs einen eigenen Navigations-Stack.
Ein Wechsel zwischen Tabs verliert damit nicht die Position im jeweiligen Tab — wichtig, weil
z.B. ein laufendes Workout im Training-Tab erhalten bleiben muss, wenn kurz in die Statistik
gewechselt wird.

### Persistenz: Drift (SQLite), lokal

Drift, weil es typsichere Queries, echte Migrationen und Streams bietet, die sich direkt an
Riverpod anbinden lassen.

Die Teile liegen in `lib/core/database/`:

| Datei | Inhalt |
| --- | --- |
| `app_database.dart` | `AppDatabase`, Schema-Version, `MigrationStrategy` |
| `database_connection.dart` | Verbindung zur Datei bzw. In-Memory-Verbindung für Tests |
| `database_provider.dart` | `databaseProvider` — die eine Instanz der App |

Die Datei heißt `peakhabit.sqlite` und liegt im App-Support-Verzeichnis
(`getApplicationSupportDirectory()`), nicht im Dokumentenverzeichnis: Letzteres ist für
Dateien gedacht, die der Nutzer selbst sieht, und taucht in der Files-App auf, sobald File
Sharing aktiviert wird. Geöffnet wird die Datei in `main.dart` vor dem ersten Frame, damit
Migrationen an einer definierten Stelle laufen und nicht bei der ersten Query, die zufällig
zuerst kommt. Fremdschlüssel sind per `PRAGMA foreign_keys = ON` eingeschaltet — SQLite
ignoriert sie sonst.

#### Backups

Die Aussage „alle Daten bleiben lokal" gilt auch gegenüber den Backup-Mechanismen der
Plattform:

- **Android:** `android:allowBackup="false"` im Manifest. Ohne das kopiert Auto Backup die
  Datenbank in die Google Drive des Nutzers, und auf Android 11 und älter ließe sie sich per
  `adb backup` vom Gerät ziehen. Die Geräte-zu-Geräte-Übertragung auf ein neues Telefon
  bleibt davon unberührt.
- **iOS:** offen. Das App-Support-Verzeichnis liegt weiterhin im iCloud-Backup; das
  auszuschließen braucht `NSURLIsExcludedFromBackupKey`, was `path_provider` nicht anbietet.
  Ob das überhaupt gewollt ist, ist eine Produktentscheidung — ein iCloud-Backup ist
  verschlüsselt und gehört dem Nutzer selbst.

**Das Schema wächst pro Feature, nicht vorab.** Das Fundament enthält selbst keine fachlichen
Tabellen. Jede Tabelle entsteht in dem Feature-Ticket, das sie tatsächlich braucht, zusammen
mit ihrer Migration.

Der Grund: Ein vorab entworfenes Gesamtschema müsste beim Anbinden der einzelnen Features
ohnehin wieder geändert werden, und ungenutzte Tabellen lassen sich nicht sinnvoll testen.

Das Datenmodell wird so entworfen, dass eine spätere Cloud-Synchronisation nachrüstbar bleibt
(stabile IDs, Zeitstempel), ohne dass jetzt Sync-Code entsteht.

#### Eine neue Tabelle ergänzen

1. Tabellenklasse im Feature anlegen, z.B. `lib/features/home/data/body_weight_table.dart`.
2. In `app_database.dart` bei `@DriftDatabase(tables: [...])` eintragen.
3. `schemaVersion` um eins erhöhen.
4. In `onUpgrade` einen Block für die neue Version ergänzen:

   ```dart
   if (from < 2) {
     await m.createTable(bodyWeightEntries);
   }
   ```

5. Code generieren: `dart run build_runner build`.
6. Testen: gegen `AppDatabase.inMemory()` schreiben und lesen. Wer eine bestehende Datenbank
   simulieren will, prüft den Schritt zusätzlich über `onUpgrade`.

Schritt 3 und 4 gehören zusammen: Ohne Migration bekommt die Tabelle nur, wer die App neu
installiert. Bestehende Installationen laufen sonst gegen eine fehlende Tabelle.

#### Generierte Dateien

Die `.g.dart`-Dateien werden **eingecheckt**. Damit bleibt die CI ein einziger Job aus
Format-, Analyse- und Testschritt; ein frischer Klon lässt sich ohne Codegenerierung bauen.
Der Preis ist ein größerer Diff, wenn sich das Schema ändert. Der Analyzer schließt
`**/*.g.dart` aus (siehe `analysis_options.yaml`) — generierter Code folgt nicht unseren
Lints, echte Fehler darin fallen trotzdem beim Kompilieren auf.

Nach jeder Schemaänderung `dart run build_runner build` laufen lassen und das Ergebnis
mit committen.

### Design: dark-first mit hellblauem Akzent

Seed-Farbe `#38BDF8`. `themeMode` steht fest auf `ThemeMode.dark`; ein Light-Theme ist
vorhanden und gepflegt, wird aktuell aber nicht angesteuert.

### Fehlerbehandlung und Logging

Noch nicht festgelegt. Wird entschieden, sobald der erste echte I/O-Pfad (Datenbank) existiert —
vorher gäbe es nichts zu behandeln.

## Navigation

Vier Tabs in der Bottom-Navigation:

| Tab | Route | Inhalt |
| --- | --- | --- |
| Start | `/home` | Übersicht, Körpergewicht eintragen |
| Ernährung | `/nutrition` | Mahlzeiten und Nährwerte tracken |
| Training | `/training` | Trainingspläne erstellen, Workouts starten |
| Statistik | `/stats` | Trainingsfortschritt, Gewichtsverlauf, Auswertungen |
