# Konventionen

Gilt für alle Ticket-Workflow-Skills. Projektregeln in `CLAUDE.md` und `docs/ARCHITECTURE.md`
haben Vorrang und werden hier nicht dupliziert.

## Branches

Schema: `<nummer>-<inhaltlicher-slug>`, z.B. `42-koerpergewicht-eintragen`.

Immer vom aktuellen `main` abzweigen. Ist ein Branch falsch benannt, vor dem ersten Commit
umbenennen.

## Commits

Imperativ, englisch, eine Zeile Betreff ohne abschließenden Punkt. Bei Bedarf ein
erklärender Absatz darunter (das Warum, nicht das Was).

```
Add body weight entry widget to the home screen
```

## Verifikationskette

Nach jeder inhaltlichen Änderung lokal ausführen:

```bash
dart format .
flutter analyze
flutter test
```

Bei UI-Änderungen zusätzlich auf einem Simulator/Emulator prüfen. Verfügbare Geräte:
`apple_ios_simulator`, `Medium_Phone_API_36.0`, `Medium_Tablet`.

Hinweis: Die native Simulator-Integration setzt voraus, dass der Nutzer einmalig
`sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` ausgeführt hat. Schlägt sie
fehl, ersatzweise über `xcrun simctl` bauen/installieren/screenshotten und das im Bericht
offenlegen.

## Pull Requests

Titel wie der Commit-Betreff, plus Referenz aufs Issue im Body (`Closes #42`).

Body-Struktur:

```markdown
## Zusammenfassung
Was wurde geändert und warum.

## Tests
Welche Prüfungen liefen, mit Ergebnis.

## Sicherheitsauswirkung
Keine — oder konkret beschreiben.

## Migrationen
Keine — oder Datenbankänderungen beschreiben.

## Offene Risiken / Annahmen
Getroffene Annahmen, die nicht aus Code oder Ticket ableitbar waren.
```

## CI

`.github/workflows/ci.yml` prüft bei PRs und Pushes auf `main`:
`dart format --set-exit-if-changed .`, `flutter analyze`, `flutter test`.

Bei roter CI gezielt reparieren, **maximal 3 Versuche**. Danach anhalten, den PR offen lassen
und klar als blockiert melden — keine Endlosschleife.

## Review- und Merge-Policy

Konservativ, vom Nutzer festgelegt:

- **Code Review vor jedem Merge** — verpflichtend.
- **Security Review** zusätzlich bei sicherheits- oder datenrelevanten Änderungen. In diesem
  Projekt sind das: lokale Datenbank und Migrationen, Gerätezugriffe/Berechtigungen
  (Health-Daten, Benachrichtigungen, Kamera), Export/Import von Nutzerdaten sowie alles, was
  später Auth oder Cloud-Sync betrifft.
- **Merge nur nach ausdrücklicher Freigabe des Nutzers.** Niemals automatisch mergen, auch
  nicht bei grüner CI und sauberem Review. PR offen lassen und zur Freigabe vorlegen.
- Kostenpflichtige oder nutzergetriggerte Review-Modi (z.B. `/code-review ultra`) **nie**
  selbst auslösen.

Merge-Methode: Squash-Merge, Branch danach löschen.

## GitHub-Schreibaktionen

Erlaubt ohne Rückfrage: Issues anlegen/kommentieren, Board-Status setzen, Branch pushen,
PR öffnen.

Nur mit ausdrücklicher Freigabe: Merge, Issues schließen, Branch-Protection, Repository-
Einstellungen, Secrets, Labels löschen.

## Rückfragen

Nur bei echten Geschäftsentscheidungen nachfragen. Alles, was aus Code, Doku oder
Ticket-Kommentaren klärbar ist, selbst klären und die Annahme im PR dokumentieren.

Hintergrund-Subagents ohne live mitlesenden Nutzer dürfen nicht auf Rückfragen warten: bei
Unsicherheit sicher anhalten und klar berichten.

## Nebenbefunde

Echte Funde außerhalb des Ticket-Scopes (Bugs, Tech Debt, Sicherheitsrisiken) als eigenes
Issue anlegen, nicht nur im Chat erwähnen. Keine Scope-Ausweitung im laufenden PR.
