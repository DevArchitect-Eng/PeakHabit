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

Je Ticket protokollieren: Ergebnis, PR, Tests, CI, Folge-Tickets, Entscheidungen.

## Fehler und Blockaden

- Ein fehlgeschlagenes Ticket stoppt den Rest **nicht**.
- Ausnahme: systemisches Problem (CI generell defekt, `main` kaputt, Toolchain fehlt) →
  gesamten Loop anhalten und melden.
- **Merge-Konflikte zwischen parallelen Tickets nicht selbst auflösen.** Als blockiert
  melden und loggen.
- Kein Merge ohne Freigabe des Nutzers (konservative Policy). PRs bleiben offen und werden
  als `waiting` geloggt.

## Kein Nutzer live dabei

Der Loop läuft ohne mitlesenden Nutzer. Auf keine Rückfrage warten: Bei echter Unsicherheit
das betroffene Ticket sicher anhalten, als blockiert loggen und mit dem nächsten weitermachen.

## Abschlussbericht

Tabelle über alle bearbeiteten Tickets: Nummer, Ergebnis, PR, CI-Status, offene Blockaden,
angelegte Folge-Tickets.
