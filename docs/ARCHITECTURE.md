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
    logging/                    AppLogger, Lifecycle- und Fehler-Hooks
    router/app_router.dart      go_router-Konfiguration
    theme/app_theme.dart        Farbschema, Light/Dark
  features/
    shell/                      Bottom-Navigation-Gerüst
    home/                       Startseite (u.a. Körpergewicht-Widget)
    nutrition/                  Ernährungstracking
    training/                   Trainingspläne und Workouts
    stats/                      Auswertungen und Diagramme
    profile/                    Nutzerprofil, Kalorien- und Makroziele
    settings/                   Einstellungen, Theme-Auswahl
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
| `date_only_converter.dart` | `DateOnlyConverter` für reine Kalenderdaten |

Reine Kalenderdaten (Geburtstag, Tag eines Eintrags) laufen über `DateOnlyConverter` und
liegen als `yyyy-MM-dd` in einer Textspalte. Eine `dateTime()`-Spalte hält einen Zeitpunkt;
der verschiebt sich zwischen Zeitzonen um Stunden und landet dann auf dem Nachbartag.

Die Datei heißt `peakhabit.sqlite` und liegt im App-Support-Verzeichnis
(`getApplicationSupportDirectory()`), nicht im Dokumentenverzeichnis: Letzteres ist für
Dateien gedacht, die der Nutzer selbst sieht, und taucht in der Files-App auf, sobald File
Sharing aktiviert wird. Geöffnet wird die Datei über `warmUp()` (`lib/core/startup.dart`) vor
dem ersten Frame, damit Migrationen an einer definierten Stelle laufen und nicht bei der
ersten Query, die zufällig zuerst kommt. Schlägt das Öffnen fehl — oder hängt es —, greift
der Recovery-Screen aus § Fehlerbehandlung und Logging statt eines leeren Bildschirms.
Fremdschlüssel sind per `PRAGMA foreign_keys = ON` eingeschaltet — SQLite ignoriert sie sonst.

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

Vorhandene Tabellen:

| Tabelle | Ab Version | Wo |
| --- | --- | --- |
| `user_profiles` | 2 | `lib/features/profile/data/user_profile_table.dart` |
| `app_settings` | 3 | `lib/features/settings/data/app_settings_table.dart` |

`app_settings` ist wie `user_profiles` eine Ein-Zeilen-Tabelle. Weitere Einstellungen kommen
als weitere Spalten dazu, nicht als eigene Tabellen. Bewusst hier statt in
`shared_preferences`: Der Theme-Modus wäre der einzige Wert dort, und ein zweiter
Speicherort kostet mehr als die Spalte einspart.

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

Seed-Farbe `#38BDF8`. Dark ist der Standard: Solange nichts gespeichert ist, läuft die App
dunkel. Im Einstellungen-Tab lässt sich zwischen Dark, Light und der Systemeinstellung
wählen; die Auswahl liegt als `AppThemeMode` in der Datenbank.

`app.dart` beobachtet dafür `themeModeProvider` und übersetzt den Wert nach `ThemeMode`.
Warum ein eigenes Enum statt Flutters `ThemeMode`: Die Namen landen als Text in der
Datenbank und sollen nicht an einem Framework-Typ hängen.

`main.dart` liest den gespeicherten Wert vor dem ersten Frame, damit die App nicht sichtbar
von einem Theme ins andere springt.

### Fehlerbehandlung und Logging

Ein zentraler `AppLogger` unter `lib/core/logging/app_logger.dart` macht den Zustand der App
während der Entwicklung nachvollziehbar — statt verstreuter `print`-Aufrufe oder gar keiner
Diagnoseausgabe. **Rein lokal:** Es ist kein Analytik-, Tracking- oder Crash-Reporting-Dienst,
nichts verlässt das Gerät.

| Datei | Inhalt |
| --- | --- |
| `app_logger.dart` | `AppLogger`, Log-Level, `LogEntry`, austauschbare Ausgabe (`AppLogger.output`) |
| `app_lifecycle_logger.dart` | Widget, das Vordergrund-/Hintergrund-/Inaktiv-Wechsel loggt |
| `error_logging.dart` | `installGlobalErrorLogging()` für unbehandelte Fehler |

`AppLogger` trägt ein `component`-Tag (z.B. `lifecycle`, `database`, `routing`, `app`) und kennt
vier Level (`debug`, `info`, `warning`, `error`). Ausgegeben wird über `dart:developer`s `log()`
auf die Konsole; `AppLogger.minLevel` filtert davor (`debug` im Debug-Build, `warning` sonst),
`AppLogger.output` lässt sich in Tests durch eine sammelnde Funktion ersetzen, statt echte
Konsolenausgabe zu erzeugen.

Bereits angebunden:

- **Lifecycle:** `AppLifecycleLogger` umschließt den Router-Inhalt in `app.dart` (`builder:` von
  `MaterialApp.router`) und loggt jeden `AppLifecycleState`-Wechsel über `AppLogger.lifecycle`.
- **Datenbank:** `AppDatabase` loggt Öffnen, Schließen sowie `onCreate`/`onUpgrade` (mit
  Ausgangs- und Zielversion) über `AppLogger.database` — siehe `open()`, `close()` und
  `migration` in `app_database.dart`.
- **Routing:** `app_router.dart` hängt einen Listener an `appRouter.routerDelegate`, der bei
  jedem Tab- oder Routenwechsel die neue URI über `AppLogger.routing` loggt. Ein
  `NavigatorObserver` reicht hier nicht: `StatefulShellRoute.indexedStack` gibt jedem Tab einen
  eigenen, verschachtelten Navigator, den der Root-Navigator nicht sieht.
- **Unbehandelte Fehler:** `installGlobalErrorLogging()` wird in `main.dart` vor `runApp`
  aufgerufen, verkettet sich vor `FlutterError.onError` und `PlatformDispatcher.instance.onError`
  und loggt über `AppLogger.app`, ohne das bisherige Verhalten (roter Fehlerbildschirm im Debug,
  Weiterreichen an die Plattform) zu verändern.
- **Datenbank-Öffnen beim Start:** `main.dart` startet nicht mehr direkt `PeakHabitApp`,
  sondern `StartupGate` (`lib/core/startup_gate.dart`). Das ruft `warmUp()` auf — nicht nur
  `database.open()`, sondern den gesamten Startpfad inklusive Theme-Provider, siehe #19 — und
  zeigt bei Erfolg die App, bei einem Fehler den blockierenden `StartupErrorScreen`
  (`lib/core/startup_error_screen.dart`) statt eines leeren Bildschirms. Der Screen bietet
  zwei Aktionen: „Erneut versuchen" für transiente Ursachen (z.B. kurzzeitig volle Platte) und
  „App-Daten zurücksetzen", das die Datenbankdatei über `deleteDatabaseFile()`
  (`database_connection.dart`) löscht und mit einer frischen Datenbank neu startet — nur nach
  expliziter Bestätigung in einem Dialog, nie automatisch. Begründung: Die lokale Datenbank ist
  die einzige Kopie der Nutzerdaten, ein automatisches Verwerfen könnte stillschweigend
  Monate an Tracking-Historie löschen; ein reiner „nur melden"-Screen wäre dagegen eine
  Sackgasse für Nutzer ohne Dateisystemzugriff. Kein Degraded-Mode: Die Datenbank ist praktisch
  die gesamte Datenschicht, ein eingeschränkter Betrieb ohne sie könnte kaum etwas sinnvoll
  anzeigen. Ein `warmUp()`, das gar nicht erst zurückkehrt (gesperrte Datenbankdatei, nie
  erfüllter Provider), landet nach `startupTimeout` = **15 Sekunden** auf demselben Screen,
  nur mit eigenem Text („Die Datenbank antwortet nicht.") und einer Warnung statt eines
  Fehlers im Log — sonst wäre der leere Bildschirm über einen anderen Weg zurück (#28). Die
  Wartezeit **bricht nichts ab**: `Future.timeout` kündigt nicht, eine bloß langsame Migration
  über viele Datensätze läuft zu Ende, und ihr Container wird erst danach freigegeben statt
  die Verbindung mitten in der Migration zu schließen. Genau deshalb darf die Grenze großzügig
  sein. Ein verspätet doch noch erfolgreicher Start wird geloggt, aber nicht mehr angezeigt:
  Der Nutzer steht dann längst auf dem Recovery-Screen, womöglich im Bestätigungsdialog, und
  „Erneut versuchen" ist danach ohnehin schnell. Einzige Ausnahme ist „App-Daten
  zurücksetzen": Bevor die Datei gelöscht wird, schließt der Gate einen noch laufenden Start
  doch — sonst schriebe der weiter in eine bereits entfernte Datei, während der nächste
  Versuch am selben Pfad eine neue anlegt, und die Journal-Dateien daneben hängen am Pfad,
  nicht an der Datei. Zu schützen gibt es dort nichts mehr, der Nutzer verwirft die Daten ja
  gerade. Jeder Versuch bekommt einen frischen `ProviderContainer` — ein erneuter Versuch
  über dieselbe bereits fehlgeschlagene Datenbankverbindung ist nicht garantiert erfolgreich.

Neue Features nutzen `AppLogger` statt eigener Ad-hoc-Ausgaben — entweder einen der bestehenden
Komponenten-Logger oder einen neuen `const AppLogger('...')` für einen neuen Bereich.
Riverpod-Provider-Übergänge und einzelne Datenbank-Statements werden bewusst nicht geloggt, um
das Debug-Log nicht mit Rauschen zu überfrachten; das lässt sich bei Bedarf gezielt nachrüsten.

## Navigation

Fünf Tabs in der Bottom-Navigation:

| Tab | Route | Inhalt |
| --- | --- | --- |
| Start | `/home` | Übersicht, Körpergewicht eintragen |
| Ernährung | `/nutrition` | Mahlzeiten und Nährwerte tracken |
| Training | `/training` | Trainingspläne erstellen, Workouts starten |
| Statistik | `/stats` | Trainingsfortschritt, Gewichtsverlauf, Auswertungen |
| Optionen | `/settings` | Darstellung, Zugang zum Profil |

Unterseiten eines Tabs sind verschachtelte Routen seines Branches, damit die Bottom-Navigation
stehen bleibt und der Tab seine Position behält — `/settings/profile` ist das erste Beispiel.
