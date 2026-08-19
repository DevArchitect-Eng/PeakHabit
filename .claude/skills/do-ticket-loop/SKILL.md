---
name: do-ticket-loop
description: Arbeitet mehrere Ready-Tickets nacheinander ab — serielle Vorbereitung in isolierten Worktrees, parallele Veröffentlichung im Hintergrund, durchgehendes Logging.
---

# do-ticket-loop

Aufruf: `/do-ticket-loop [--max <n> | --noLimit]`

Ohne Angabe: `--max 3`.

Lies zuerst `../ticket-workflow-shared/references/conventions.md`,
`../ticket-workflow-shared/references/board.md` und
`../ticket-workflow-shared/references/log-format.md`.

## Tickets auswählen

Alle Tickets mit Board-Status **Ready**, die nicht blockiert sind. Sortierung: Priority
(P0 → P2), dann Size (klein zuerst), dann Alter (älteste zuerst).

Priority und Size sind echte Board-Felder — übernehmen statt schätzen. Fehlt ein Wert, das
Ticket ans Ende der jeweiligen Gruppe sortieren.

Blocker werden nur an Formulierungen im Issue-Text erkannt („nach #49", „blockiert durch #49",
„braucht #49", „Rest aus #49", „siehe #49" — Liste in
`../ticket-workflow-shared/references/ticket-format.md`). Verweist ein Ticket auf ein noch
offenes Issue, überspringen. Verweist es auf ein geschlossenes, ist es nicht blockiert.

Tickets, die dieselben Dateien anfassen, nicht gleichzeitig einplanen.

## Sichtung vor dem ersten Ticket

Der Loop läuft ohne mitlesenden Nutzer — deshalb wird gefragt, solange er noch da ist.

Nach der Auswahl und **vor** der ersten Umsetzung alle eingeplanten Tickets durchgehen: Issue
samt Kommentaren lesen und den betroffenen Code ansehen. Notiert wird, was eine Rückfrage
braucht — offene Geschäftsentscheidungen und alles, was Code außerhalb des jeweiligen Tickets
betrifft (Abgrenzung in `../ticket-workflow-shared/references/conventions.md` § Rückfragen).

Alle Fragen **gesammelt in einem Block** stellen, nach Ticket sortiert, und die Antworten
abwarten. Erst danach beginnt der Ablauf. Ziel der Sichtung ist, dass im weiteren Verlauf
keine Rückfrage mehr nötig wird.

Bleibt ein Ticket unbeantwortet oder stellt der Nutzer es zurück, dieses Ticket aus dem Lauf
nehmen und mit den übrigen weitermachen.

## Ablauf

Vorbereitung läuft **seriell**, Veröffentlichung **parallel im Hintergrund**:

1. Ticket N in einem eigenen Worktree vorbereiten (Logik von `/do-ticket-prepare`)
2. Ist es fertig, `/do-ticket-publish <N>` im Hintergrund starten
3. Währenddessen Ticket N+1 vorbereiten
4. Wiederholen, bis das Limit erreicht oder keine Ready-Tickets mehr da sind

### Worktrees

Jedes Ticket bekommt eine isolierte Arbeitskopie:

```bash
git worktree add ../peakhabit-wt-<nummer> -b <nummer>-<slug> origin/main
```

Nach erfolgreichem Merge aufräumen:

```bash
git worktree remove ../peakhabit-wt-<nummer>
```

Gemeinsame lokale Ressourcen beachten: Es gibt nur **einen** Simulator/Emulator und einen
Gradle-/Pub-Cache. UI-Verifikation und Builds daher nicht parallel laufen lassen —
serialisieren.

## Logging

Durchgehend nach `~/peakhabit-logs/loop.log` schreiben, Format siehe `log-format.md`.
Ordner bei Bedarf anlegen. Einträge treffen in Abschlussreihenfolge ein, nicht in
Startreihenfolge — deshalb trägt jede Zeile die Ticketnummer.

Je Ticket protokollieren: Ergebnis, PR, Tests, CI, Folge-Tickets, Entscheidungen und
Rückfragen, die während des Laufs offen geblieben sind.

## Fehler und Blockaden

- Ein fehlgeschlagenes Ticket stoppt den Rest **nicht**.
- Ausnahme: systemisches Problem (CI generell defekt, `main` kaputt, Toolchain fehlt) →
  gesamten Loop anhalten und melden.
- **Merge-Konflikte zwischen parallelen Tickets nicht selbst auflösen.** Als blockiert
  melden und loggen.
- Kein Merge ohne Freigabe des Nutzers (konservative Policy). PRs bleiben offen und werden
  als `waiting` geloggt.

## Kein Nutzer live dabei

Ab dem ersten Ticket läuft der Loop ohne mitlesenden Nutzer — die Fragen sind in der Sichtung
gestellt. Danach auf keine Rückfrage mehr warten: Bei echter Unsicherheit, und ebenso bei
einem Fund außerhalb des Ticket-Scopes, der in der Sichtung nicht aufgefallen ist, das
betroffene Ticket sicher anhalten, als blockiert loggen und mit dem nächsten weitermachen.
Nichts davon selbst entscheiden.

## Abschlussbericht

Tabelle über alle bearbeiteten Tickets: Nummer, Ergebnis, PR, CI-Status, offene Blockaden,
angelegte Folge-Tickets. Danach die Rückfragen auflisten, die erst während des Laufs
aufgekommen sind — sie sind der Grund für jedes so angehaltene Ticket.
