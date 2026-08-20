# Konventionen

Gilt für alle Ticket-Workflow-Skills. Projektregeln in `CLAUDE.md` und `docs/ARCHITECTURE.md`
haben Vorrang und werden hier nicht dupliziert.

Weitere Referenzen in diesem Ordner:

- `board.md` — Project- und Feld-IDs, Labels
- `ticket-format.md` — Issue-Body-Formate, Feld-Heuristiken, Abhängigkeits-Formulierungen
- `log-format.md` — Log-Datei für den Loop-Modus

## Branches

Schema: `<nummer>-<inhaltlicher-slug>`, z.B. `42-koerpergewicht-eintragen`.

Immer vom aktuellen `main` abzweigen. Ist ein Branch falsch benannt, vor dem ersten Commit
umbenennen.

## Commits

Format und Zuschnitt stehen in `CLAUDE.md` § Commits — sie gelten für **jeden** Commit im
Projekt, nicht nur für Ticket-Arbeit. Kurzform: `<prefix>: <betreff>`, darunter `-`-Punkte,
und lieber mehrere kleine Commits als einen großen.

Für Ticket-Arbeit zusätzlich: Der erste Commit auf einem Ticket-Branch nennt die Ticketnummer
im Body (`Ticket: #42`), damit die Zuordnung auch ohne PR erkennbar bleibt.

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

## Dokumentation aktuell halten

Nach dem Umsetzen, **vor** der lokalen Verifikation: prüfen, ob das Ticket etwas verändert, das
in README.md, CLAUDE.md oder `docs/ARCHITECTURE.md` beschrieben ist, und die Beschreibung bei
Bedarf im selben Commit mitziehen — nicht als Nachtrag und nicht als eigenes Ticket. Das gilt in
`/do-ticket` und `/do-ticket-prepare` gleichermaßen.

Konkret zu prüfen:

- **README.md § Stand:** neue oder veränderte Features, neue Tabs, neue Screens, neue
  Datenbank-Tabellen.
- **CLAUDE.md § Produkt:** dieselbe Art von Änderung, dazu die Liste der Datenbank-Tabellen im
  Abschnitt „Technisches".
- **`docs/ARCHITECTURE.md`:** neue Tabellen in „Vorhandene Tabellen" samt Migration, neue
  Ordner unter `lib/features/`, neue Architekturentscheidungen oder Begründungen, die das
  Ticket tatsächlich trifft.

Nicht jedes Ticket berührt alle drei Dateien — ein reiner Bugfix oder ein Refactoring ohne
sichtbare Verhaltensänderung meist keine. Maßstab: Stimmt die Beschreibung nach der Änderung
noch? Wenn nein, aktualisieren; wenn ja, nichts anfassen. Kein pauschales Update „zur
Sicherheit".

Deckt das Ticket selbst schon eine Doku-Aktualisierung ab (z.B. ein `doc`-Ticket wie #54), gilt
dieser Schritt trotzdem — er verhindert, dass README.md & Co. beim *nächsten* Feature wieder
zurückfallen.

## Akzeptanzkriterien abhaken

Sobald Umsetzung, lokale Verifikation und Review abgeschlossen sind — in `/do-ticket` und
`/do-ticket-prepare` also nach Schritt „Review", vor PR bzw. vor dem Stopp —, das
Issue erneut lesen und jedes Akzeptanzkriterium **einzeln** gegen das tatsächliche Ergebnis
prüfen: bestandener Test, beobachtetes Verhalten im Simulator/Emulator, tatsächlich
vorhandener Code. Nicht raten und nicht pauschal alles abhaken, nur weil das Ticket
insgesamt fertig wirkt.

- Nachweislich erfüllte Kriterien im Issue-Body von `- [ ]` auf `- [x]` setzen:
  ```bash
  gh issue edit <nummer> --body "<vollständiger, aktualisierter Body>"
  ```
  Der gesamte Body wird neu geschrieben — nur die betroffenen Checkbox-Zeilen ändern sich,
  alles andere bleibt wortgleich erhalten.
- Nicht erfüllte Kriterien bleiben unverändert. Grund im Abschlussbericht bzw. im PR-Body
  unter „Offene Risiken / Annahmen" nennen, nicht stillschweigend übergehen.
- Tickets im leichtgewichtigen Bug-Format (kein `## Akzeptanzkriterien`-Block) — dieser
  Schritt entfällt ersatzlos, da nichts zum Abhaken existiert.
- Das ist eine normale Issue-Bearbeitung, keine Merge-Aktion — läuft ohne Rückfrage
  (siehe „GitHub-Schreibaktionen").
- Ändert eine spätere CI-Reparatur in `/do-ticket-publish` noch den Code, die betroffenen
  Kriterien vor dem Merge-Gate erneut prüfen.

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
Ein einziger Job namens `verify`.

Auf `main` gibt es **keine Branch-Protection** — die CI ist das einzige Gate, technisch
erzwingt nichts einen grünen Lauf vor dem Merge. Umso strikter gilt: nicht mergen, solange die
CI nicht grün ist, auch wenn GitHub es zuließe.

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

Merge-Methode: **Merge Commit** (nicht Squash) — die einzelnen Commits eines PRs bleiben damit
auch auf `main` erhalten, statt beim Merge zu einem zusammengefasst zu werden. Genau dafür
gibt es die Commit-Konvention in `CLAUDE.md`: Sie soll die Historie von `main` lesbar machen,
nicht nur die PR-Ansicht während der Review. Branch nach dem Merge löschen.

## GitHub-Schreibaktionen

Erlaubt ohne Rückfrage: Issues anlegen/kommentieren/bearbeiten (inkl. Akzeptanzkriterien
abhaken), Board-Status setzen, Branch pushen, PR öffnen.

Nur mit ausdrücklicher Freigabe: Merge, Issues schließen, Branch-Protection, Repository-
Einstellungen, Secrets, Labels löschen.

## Rückfragen

Zwei Fälle lösen eine Rückfrage aus:

1. **Echte Geschäftsentscheidungen** — Produktentscheidungen, die niemand aus dem Repository
   beantworten kann. Alles, was aus Code, Doku oder Ticket-Kommentaren klärbar ist, selbst
   klären und die Annahme im PR dokumentieren.
2. **Alles, was Code außerhalb des Ticket-Scopes betrifft** — hier wird **immer** gefragt,
   ohne eigene Abwägung, ob es die Unterbrechung wert ist.

### Was „außerhalb des Scopes" heißt

- **Zählt dazu:** jede Änderung, die eine Datei anfassen würde, die das Ticket nicht ohnehin
  betrifft. Dazu jeder Bug, jede Tech Debt und jeder Sicherheitsfund außerhalb des Tickets —
  auch wenn er nur beobachtet und gar nicht behoben werden soll.
- **Zählt nicht dazu:** Entscheidungen innerhalb des eigenen Diffs — Benennung, Aufteilung,
  Formulierung, Teststruktur. Das ist normale Umsetzungsarbeit.

### Wann gefragt wird

**Vor dem Programmieren.** Der Fund wird vorgelegt, bevor die erste Zeile Code entsteht — in
`/do-ticket` und `/do-ticket-prepare` also in Schritt 3, vor dem Branch. Deshalb gehört zum
Ticketverständnis ein Blick auf den betroffenen Code, statt erst beim Umsetzen zu merken, was
alles daranhängt.

Fällt später trotzdem etwas auf, sofort fragen und die Umsetzung so lange anhalten — nicht
nebenbei miterledigen und nicht erst im PR-Body erwähnen.

### Ohne live mitlesenden Nutzer

Hintergrund-Subagents und der Loop-Modus dürfen nicht auf Rückfragen warten. Dort gilt: Fragen
so früh stellen, dass der Nutzer noch dabei ist (`/do-ticket-loop` § Sichtung vor dem ersten
Ticket), und alles, was danach noch auffällt, führt zum sicheren Anhalten des betroffenen
Tickets — nicht zu einer eigenen Entscheidung.

## Nebenbefunde

Echte Funde außerhalb des Ticket-Scopes (Bugs, Tech Debt, Sicherheitsrisiken) sind
rückfragepflichtig (siehe „Rückfragen"): erst vorlegen, dann entscheidet der Nutzer, was
daraus wird.

Nach der Freigabe als eigenes Issue anlegen, nicht nur im Chat erwähnen — Format nach
`ticket-format.md`, Label `claude-found`, im Body auf das Ursprungsticket verweisen. Ohne
Freigabe entsteht kein Issue, und Scope-Ausweitung im laufenden PR gibt es weiterhin nicht.
