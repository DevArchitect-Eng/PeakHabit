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
    startup.dart                warmUp: liest Theme und Onboarding-Flag vor dem ersten Frame
    startup_gate.dart           entscheidet zwischen Fehlerbildschirm und App
    startup_error_screen.dart   Anzeige, wenn die Datenbank nicht öffnet
  features/
    onboarding/                 Erststart-Ablauf, läuft vor der Bottom-Navigation
    shell/                      Bottom-Navigation-Gerüst
    home/                       Startseite (u.a. Körpergewicht-Widget)
    body_weight/                Gewichtseinträge, von Startseite und Statistik genutzt
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

`StatefulShellRoute.indexedStack` gibt jedem der fünf Tabs einen eigenen Navigations-Stack.
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

**Sommer-/Winterzeit verschiebt keinen gespeicherten Tag.** Der Text trägt keine Zeitzone, und
`fromSql` gibt lokale Mitternacht zurück. In Zonen, die die Uhr um Mitternacht stellen (Kairo,
Santiago, Havanna, Beirut), existiert diese Mitternacht am Umstellungstag nicht — Dart
normalisiert einen solchen Wert dann **vorwärts** auf 01:00 desselben Tages, nie zurück auf den
Vortag. Der Kalendertag bleibt also erhalten. Abgesichert ist das in
`test/core/database/date_only_converter_test.dart` sowie in den Gewichts-Tests; auf der CI
läuft alles unter UTC, wo diese Tage gewöhnliche Tage sind, die Prüfungen greifen also erst
auf einer Maschine in einer betroffenen Zone.

Zwei Dinge folgen daraus für alles, was mit diesen Daten rechnet:

- Über Tage **nicht** mit `add(Duration(days: 1))` iterieren. Ein Tag ist um eine Umstellung
  herum 23 oder 25 Stunden lang; 24 Stunden auf lokale Mitternacht addiert landen dann wieder
  im selben Tag oder überspringen einen. Stattdessen `DateTime(jahr, monat, tag + 1)` — der
  Konstruktor normalisiert einen überlaufenden Tageswert korrekt.
- Gespeicherte Daten nur untereinander vergleichen, nie mit einem unnormalisierten
  `DateTime` (siehe Klassenkommentar von `DateOnlyConverter`).

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
| `body_weight_entries` | 4 | `lib/features/body_weight/data/body_weight_table.dart` |
| `foods` | 9 | `lib/features/nutrition/data/food_table.dart` |
| `composite_foods` | 9 | `lib/features/nutrition/data/composite_food_tables.dart` |
| `composite_food_ingredients` | 9 | `lib/features/nutrition/data/composite_food_tables.dart` |
| `meal_entries` | 9 | `lib/features/nutrition/data/meal_entry_table.dart` |

Schema-Version 5 bringt keine neue Tabelle, sondern räumt Daten auf: `BiologicalSex` hat
seine Option `diverse` verloren (#4), und eine Migration setzt ein gespeichertes `diverse`
auf `NULL`. Nötig, weil die Spalte den Enum-Namen hält — drift löst ihn beim Lesen wieder
auf und wirft bei einem Namen, den das Enum nicht mehr kennt. Das ist der zweite Fall neben
„neue Tabelle": **Eine Migration braucht auch, wer nur die möglichen Werte einer Spalte
einschränkt.**

Schema-Version 6 ergänzt `user_profiles` um die Spalte `username` (#34) — nicht nullable,
mit `''` als Default, damit `addColumn` auch für eine bestehende Zeile funktioniert. Das ist
der dritte Fall: **Eine bestehende Tabelle bekommt eine neue Spalte per `m.addColumn(...)`,
zusätzlich zur `schemaVersion`-Erhöhung und dem `if (from < n)`-Block**, ohne dass dafür eine
neue Tabelle nötig wäre.

Schema-Version 8 räumt wie Version 5 nur Daten auf, diesmal in `user_profiles.goal`:
`WeightGoal` hat seine drei Richtungen gegen acht Wochenraten getauscht (#43), die alten
Namen `lose` und `gain` gibt es nicht mehr. Die Migration schreibt sie auf die Rate um, für
die sie standen (`lose` → `lose500`, `gain` → `gain200`); `maintain` heißt weiter so und
braucht keine Anweisung. **Derselbe Fall wie Version 5 — wer die möglichen Werte einer
Spalte ändert, braucht eine Migration**, ganz gleich ob Werte wegfallen oder umbenannt
werden.

`body_weight_entries` liegt in einem eigenen Feature statt unter `home/`: Startseite (#5) und
Statistik (#6) lesen dieselbe Reihe, und ein Feature, das aus einem anderen liest, wäre die
erste Ausnahme von der Feature-Trennung. Der Kalendertag ist der Primärschlüssel — pro Tag
gibt es höchstens einen Eintrag, und so setzt SQLite das durch, statt es dem Schreibenden zu
überlassen; ein zweites Wiegen am selben Tag korrigiert den Wert per Upsert. Morgens und
abends unterscheiden sich um mehr als die meiste echte Veränderung, beide Werte zu behalten
täuschte also eine Genauigkeit vor, die die Zahl nicht hat. Gespeichert wird in Kilogramm:
Eine Anzeigeeinheit (kg oder lbs) ist eine spätere Einstellung und eine Frage der Darstellung
— beim Schreiben umzurechnen hinge die gespeicherte Reihe davon ab, wann welcher Wert
eingetragen wurde.

`app_settings` ist wie `user_profiles` eine Ein-Zeilen-Tabelle. Weitere Einstellungen kommen
als weitere Spalten dazu, nicht als eigene Tabellen. Bewusst hier statt in
`shared_preferences`: Der Theme-Modus wäre der einzige Wert dort, und ein zweiter
Speicherort kostet mehr als die Spalte einspart.

Die vier Ernährungstabellen entstehen zusammen in Version 9 (#8) — sie ergeben einzeln keinen
Sinn. Sechs Entscheidungen hängen daran:

- **Nährwerte liegen immer je 100 g.** Ein Etikett, das seine Zahlen je Portion nennt, wird
  beim Anlegen umgerechnet; `portion_grams` hält fest, was eine Portion wiegt, damit der Weg
  zurück offen bleibt. Die Alternative wäre eine Spalte für die Bezugsgröße — dann müsste
  jede Summe jedes Lebensmittel erst fragen, worauf sich seine Zahlen beziehen.
- **Ein Gericht rechnet, statt zu speichern.** `composite_foods` hat keine Nährwertspalten;
  sie ergeben sich aus `composite_food_ingredients`. Genau deshalb baut man ein Gericht aus
  Lebensmitteln, statt einen zweiten Satz Zahlen dafür einzutippen: Eine Korrektur an einer
  Zutat erreicht jedes Gericht, in dem sie steckt.
- **`prepared_grams` ist das Gewicht der fertigen Zubereitung.** Kochen ändert das Gewicht,
  nicht die Nährwerte — 100 g roher Reis verlassen den Topf als rund 260 g. Ohne diese Spalte
  verteilte das Gericht die Nährwerte der rohen Zutaten auf das rohe Gewicht, und 200 g vom
  Teller zählten mehr als das Zweieinhalbfache dessen, was gegessen wurde. `NULL` heißt: nichts
  gewogen, die Zutaten addieren sich.
- **Der Mahlzeiteneintrag verweist auf das Lebensmittel, statt dessen Nährwerte zu kopieren.**
  Eine Korrektur zieht damit jeden Tag mit, an dem das Lebensmittel gegessen wurde — was
  jemand meint, der seinen eigenen Katalog korrigiert. Der Preis ist, dass ein Lebensmittel
  nicht mehr gelöscht werden kann, sobald es in einem Eintrag oder einem Gericht steckt: die
  Fremdschlüssel stehen auf `RESTRICT`, und das Repository prüft vorher und wirft
  `FoodItemInUseException` statt eines SQLite-Fehlers. Ein Gericht zu löschen nimmt seine
  Zutatenzeilen mit (`CASCADE`) — die gehören ihm und bedeuten allein nichts.
- **Zwei nullbare Fremdschlüssel statt einer Id mit Typspalte.** Ein Eintrag zeigt entweder auf
  ein Lebensmittel oder auf ein Gericht; `CHECK ((food_id IS NULL) <> (composite_food_id IS
  NULL))` setzt „genau eines von beiden" durch. Eine einzelne Id, die je nach Typspalte in die
  eine oder andere Tabelle zeigt, könnte keinen Fremdschlüssel tragen — nichts hielte einen
  Eintrag davon ab, das zu überleben, worauf er zeigt.
- **`barcode` und `source` stehen von Anfang an in `foods`.** Geschrieben wird heute nur
  `manual`. Die Spalten gibt es trotzdem, weil ein späterer Barcode-Scan gegen eine externe
  Lebensmitteldatenbank in **dieselbe** Tabelle schreiben soll statt in einen zweiten Katalog
  daneben; das Anlegen von Hand ist dann der Weg für alles, was dort fehlt. Nachgerüstet wäre
  die Herkunft eine Migration über Zeilen, deren Ursprung niemand mehr rekonstruieren kann.
  `barcode` ist `UNIQUE`, damit ein zweimal gescanntes Produkt den vorhandenen Datensatz
  findet.

Mengen sind durchgehend Gramm. Getränke je 100 ml sind damit noch nicht abgebildet; das wäre
eine zusätzliche Spalte für die Einheit und keine Umstellung des Schemas, und es wartet auf
das Ticket, das Getränke tatsächlich braucht.

Der Grund: Ein vorab entworfenes Gesamtschema müsste beim Anbinden der einzelnen Features
ohnehin wieder geändert werden, und ungenutzte Tabellen lassen sich nicht sinnvoll testen.

Das Datenmodell wird so entworfen, dass eine spätere Cloud-Synchronisation nachrüstbar bleibt
(stabile IDs, Zeitstempel), ohne dass jetzt Sync-Code entsteht.

#### Eine neue Tabelle ergänzen

1. Tabellenklasse im Feature anlegen, z.B.
   `lib/features/body_weight/data/body_weight_table.dart`.
2. In `app_database.dart` bei `@DriftDatabase(tables: [...])` eintragen.
3. `schemaVersion` um eins erhöhen.
4. In `onUpgrade` einen Block für die neue Version ergänzen:

   ```dart
   if (from < 4) {
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

### Kalorienziel: berechnet, nicht erraten

Das Kalorienziel lässt sich aus dem Profil berechnen, statt dass der Nutzer eine Zahl kennen
muss. Die Rechnung steht in `lib/features/profile/domain/calorie_calculation.dart` und läuft
in drei Schritten:

1. **Grundumsatz nach Mifflin-St Jeor:** `10 × kg + 6,25 × cm − 5 × Jahre`, plus 5 bei
   Männern, minus 161 bei Frauen. Gewählt statt Harris-Benedict, weil die Formel für alle,
   die nicht sehr schlank sind, näher liegt — und das ist die Mehrheit derer, die tracken.
2. **Gesamtumsatz:** Grundumsatz mal Aktivitätsfaktor, die übliche Leiter von 1,2 (sitzend)
   bis 1,9 (täglich hart).
3. **Zielanpassung:** −500 kcal beim Abnehmen (500 g pro Woche), ±0 beim Halten, +200 kcal
   beim Zunehmen (200 g pro Woche). Umgerechnet über die Konvention von rund 7000 kcal pro
   Kilogramm Körperfett. Die Raten sind **fest, nicht wählbar**: eine Rate, die sich
   hochdrehen lässt, lädt zu einem Defizit ein, das niemand durchhält.

Drei Punkte, die sich daraus ergeben:

- **Das Gewicht kommt nicht aus dem Profil,** sondern aus dem jüngsten Eintrag in
  `body_weight_entries` — es ändert sich laufend und liegt deshalb als eigene Reihe vor.
  Ohne Eintrag ist keine Berechnung möglich; der Ernährungsziele-Screen benennt das dann.
- **Ziel und Aktivität ziehen das Kalorienziel mit.** Wer auf der Ziele-Seite eines von
  beiden ändert, bekommt das neue Kalorienziel sofort mitgespeichert; die Snackbar nennt
  die Zahl, damit die Änderung nicht stillschweigend passiert. Reicht das Profil für die
  Rechnung nicht (kein Gewichtseintrag, keine Größe, kein Geburtsdatum), bleibt der alte
  Wert stehen.

  Das **kehrt die Entscheidung aus #4 um**, nach der nie ohne Zutun geschrieben wurde.
  Damals gab es auf der Profil-Seite den Knopf „Übernehmen", der die Rechnung ins Feld
  schrieb; mit dem zeilenweisen Umbau (#33) ist er weg, und ohne ihn gäbe es keinen Weg
  mehr vom geänderten Ziel zum passenden Kalorienziel. Ein von Hand gesetztes Ziel hält
  weiterhin, solange Ziel und Aktivität unangetastet bleiben — die Ernährungsziele-Seite
  schreibt genau das, was eingetippt wurde.
- **Die Rechnung selbst wird nicht mehr angezeigt.** Grundumsatz, Faktor und Zielanpassung
  standen als Zeilen unter dem Kalorienziel, solange der Nutzer die Rechnung selbst
  auslösen musste. Sichtbar bleibt sie im Onboarding, wo das erste Kalorienziel entsteht
  und die Zahl sonst aus dem Nichts käme.

Die Eingaben, aus denen sich das ergibt, liegen bewusst auf drei Seiten statt in einem
Formular (#33):

| Seite | Route | Inhalt |
| --- | --- | --- |
| Profil | `/settings/profile` | Benutzername, Größe, Geschlecht, Geburtsdatum |
| Ziele | `/settings/goals` | Start- und aktuelles Gewicht, Ziel, Aktivitätslevel |
| Ernährungsziele | `/settings/goals/nutrition` | Kalorienziel, Makroverteilung samt Gramm-Werten |

Der Schnitt folgt der Frage, die eine Seite beantwortet: Das Profil sagt, wer jemand ist, die
Ziele sagen, wohin es gehen soll, und die Ernährungsziele teilen auf, was daraus folgt.
Deshalb liegt die Makroverteilung nicht im Profil, sondern neben dem Kalorienziel, das sie
aufteilt — und deshalb steht das Aktivitätslevel bei den Zielen, obwohl es eine Körperangabe
ist: es geht nur in die Zielrechnung ein.

**Ein neuer Gewichtseintrag startet mit leerem Feld**, auch wenn schon eine Wiegung auf Record
ist. Vorbelegt war es der letzte Wert; damit ließ sich der Eintrag bestätigen, ohne je auf eine
Waage gesehen zu haben — die heutige Wiegung wäre dann die gestrige Zahl. Der Haken bleibt
unerreichbar, bis etwas getippt ist. Beim **Korrigieren** einer Zeile auf `/home/weight` steht
der Wert des Tages weiterhin drin: Dort ist er der Ausgangspunkt, nicht eine Vermutung.

Start- und aktuelles Gewicht auf der Ziele-Seite sind **schreibgeschützt**. Gewogen wird auf
der Startseite; eine zweite Stelle zum Eintragen wäre eine zweite Stelle, an der es
danebengehen kann. Beide Werte werden abgefragt (`readFirst`/`readLatest`) statt gespeichert,
damit ein korrigierter oder gelöschter erster Eintrag den Startpunkt mitzieht.

### Einstellungen: Zeilen statt Formulare

Die drei Seiten sind Listen aus `SettingRow`, nicht Formulare mit einem Speichern-Knopf
darunter. Eine Zeile wird angetippt, der Editor darüber mit dem Haken bestätigt oder mit dem
Kreuz verworfen — geschrieben wird beim Bestätigen. Die Teile liegen in
`lib/features/profile/presentation/`:

| Datei | Inhalt |
| --- | --- |
| `setting_row.dart` | `SettingRow` — Beschriftung, optionaler Zusatz, Wert; ohne `onTap` eine reine Anzeige |
| `value_editor.dart` | `showTextEditor`, `showChoiceEditor`, dazu `EditorHeader` und `EditorSheet` |

Zwei Punkte, die daran hängen:

- **Der Haken ist der einzige Weg nach vorn.** Solange der Editor einen Wert hält, den die
  Seite nicht speichern würde — ein leerer Benutzername, eine Makroverteilung, die nicht 100
  ergibt —, ist er nicht auslösbar, und der Grund steht am Feld. Vorher ließ sich so ein Wert
  eintippen und wurde erst beim Speichern abgelehnt.
- **Die Makroverteilung wird zu dritt bearbeitet.** Ein einzelner Anteil lässt sich nicht
  ändern, ohne die 100 zu brechen, die die drei zusammen ergeben müssen; jede der drei Zeilen
  öffnet deshalb denselben Editor mit allen dreien.

`showChoiceEditor` gibt die Auswahl als Record (`({T? value})?`) zurück. Nötig, weil es zwei
leere Antworten gibt, die nichts miteinander zu tun haben: `null` heißt „abgebrochen",
`(value: null)` heißt „Keine Angabe gewählt".

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
stehen bleibt und der Tab seine Position behält. Der Optionen-Tab hat davon drei:
`/settings/profile`, `/settings/goals` und darunter `/settings/goals/nutrition` — die
Verschachtelung bildet ab, dass die Ernährungsziele von der Ziele-Seite aus erreicht werden
und der Zurück-Weg über sie führt. Der Start-Tab hat eine: `/home/weight`, der
Gewichtsverlauf hinter der Gewichtskarte. Der Ernährungs-Tab hat zwei:
`/nutrition/meal?type=…&date=…` und darunter `/nutrition/meal/food`.

`/nutrition/meal/food` ist die erste Route, die **für ein Ergebnis** geschoben wird: Der
Mahlzeiten-Screen ruft sie über `context.push<FoodItem>` auf, die Auswahl beendet sich mit
`context.pop(item)`, und die Menge wird danach in einem Sheet erfragt. Eine Route statt eines
Sheets, weil eine Suche über den Katalog eine ganze Bildschirmhöhe braucht und ein Sheet über
der Tastatur davon wenig übrig lässt.

**Der gewählte Tag ist State des Ernährungs-Screens, nicht Teil seiner Route.** Er ist die
Wurzel des Tabs, und der Tag zu wechseln ist eine Bedienung darauf, keine Navigation — ein
History-Eintrag je Tag machte aus der Zurück-Geste ein Rückgängig für die Datumsauswahl,
statt den Tab zu verlassen. Die Mahlzeiten-Route darunter trägt ihren Tag sehr wohl, weil ein
von dort geöffneter Screen wissen muss, auf welchem er geöffnet wurde; wie beim Zeitraum auf
`/home/weight` fällt ein unbekannter Wert auf einen Standard zurück, statt zu werfen.

Der Vortags-Vorschlag steht **unter der Mahlzeit-Zeile im Tab**, nicht auf der Detailseite:
Der Sinn des Übernehmens ist, den Umweg zu sparen. Er erscheint nur, solange die Mahlzeit
heute leer ist — auf eine befüllte kopiert, legte der Wisch die Portionen des Vortags obendrauf.
Der Wisch **verwirft die Zeile nicht**: Er bestätigt einen Vorschlag, statt einen Eintrag zu
entfernen, also antwortet ein erfolgreiches Kopieren mit `false` und die Zeile federt zurück.
Sie verschwindet gleich darauf ohnehin, weil die Mahlzeit nicht mehr leer ist. Sie stattdessen
wegzuanimieren ließe ein verworfenes `Dismissible` so lange im Baum stehen, wie der Schreibvorgang
braucht, um über den Stream des Tages zurückzukommen — und genau das ist ein Framework-Fehler.

Der gewählte Zeitraum reist als Query-Parameter mit (`/home/weight?period=threeMonths`), nicht
in `extra`: Es ist ein einfacher Enum-Name, und einer, der eine wiederhergestellte Route
übersteht, statt danach als `null` zurückzukommen. Ein unbekannter Name fällt auf den
Standardzeitraum zurück, statt zu werfen — die URL ist von Hand tippbar.

Die Zahlen und der Graph auf `/home/weight` beziehen sich auf den **gewählten Zeitraum**: Das
Startgewicht dort ist die erste Wiegung im Fenster, nicht die allererste überhaupt. Das
allzeit-Startgewicht steht weiter auf der Ziele-Seite (`readFirst`).

Der Screen zerfällt dafür sichtbar in zwei Blöcke: Zeitraum, Eckwerte und Graph stehen
zusammen auf einer `Card`, die Wiegungen darunter auf dem blanken Hintergrund. Die Karte ist
zugleich das, was den Zeitraum-Umschalter eingrenzt — er sitzt kompakt neben der Überschrift
„Verlauf" statt über die volle Bildschirmbreite, wo er wie ein Filter für den ganzen Screen
aussähe. Deshalb hat `WeightPeriodPicker` das Flag `expand`: Die Startseiten-Karte lässt ihn
über die volle Kartenbreite laufen, weil er dort genau die Karte ändert.

**Die Liste darunter ist bewusst die Ausnahme** und zeigt immer alle Wiegungen, unabhängig vom
Zeitraum — gelesen über denselben `bodyWeightSeriesProvider`, nur auf `WeightPeriod.allTime`.
Der Zeitraum beantwortet die Frage, was eine Zeitspanne mit dem Gewicht gemacht hat; die Liste
ist der Bestand, an dem das passiert ist. Ein kürzeres Fenster ist kein Grund, Einträge an der
einzigen Stelle zu verstecken, an der sie sich korrigieren und löschen lassen. Sichtbar gemacht
wird das durch die Überschrift „Alle Wiegungen" — ohne sie sähen drei Wiegungen unter einem
Ein-Wochen-Fenster nach einem Fehler aus statt nach einer Entscheidung.

Grün und Rot am Trend-Icon stehen für die
Richtung, nicht für gut oder schlecht — das Ziel aus dem Profil geht dort bewusst nicht ein —,
und sie sind nie das einzige Unterscheidungsmerkmal: Icon und Vorzeichen tragen dieselbe
Aussage. Die beiden Farbpaare stehen in `weight_detail_screen.dart` statt im `ColorScheme`:
Ein hellblauer Seed liefert kein Grün, und `error` ist das Rot für einen Fehler, nicht für
eine Richtung.
