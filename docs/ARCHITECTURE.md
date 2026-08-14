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

### Persistenz: lokal, noch nicht implementiert

Geplant ist Drift (SQLite): typsichere Queries, echte Migrationen und Streams, die sich direkt
an Riverpod anbinden lassen.

**Das Schema wächst pro Feature, nicht vorab.** Das Fundament — Datenbank öffnen, über einen
Provider bereitstellen, Migrationsmechanismus, Testhilfe — wird einmal angelegt und enthält
selbst keine fachlichen Tabellen. Jede Tabelle entsteht in dem Feature-Ticket, das sie
tatsächlich braucht, zusammen mit ihrer Migration.

Der Grund: Ein vorab entworfenes Gesamtschema müsste beim Anbinden der einzelnen Features
ohnehin wieder geändert werden, und ungenutzte Tabellen lassen sich nicht sinnvoll testen.

Das Datenmodell wird so entworfen, dass eine spätere Cloud-Synchronisation nachrüstbar bleibt
(stabile IDs, Zeitstempel), ohne dass jetzt Sync-Code entsteht.

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
