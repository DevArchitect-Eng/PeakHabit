---
name: list-ticket
description: Zeigt offene Tickets als Tabelle, sortiert nach Priorität und Unabhängigkeit. Reine Leseoperation ohne Änderungen.
---

# list-ticket

Aufruf: `/list-ticket`

Rein lesend — ändert nichts an Issues, Board oder Repository.

Lies zuerst `../ticket-workflow-shared/references/board.md`.

## Daten holen

```bash
gh issue list --state open --limit 100 --json number,title,labels,createdAt,url
gh project item-list 1 --owner DevArchitect-Eng --format json
```

Board-Daten mit Issues zusammenführen, damit Status und Priority mit ausgegeben werden.

## Ausgabe

| # | Titel | Status | Priority | Size | Quelle | Unabhängig | Alter |
| --- | --- | --- | --- | --- | --- | --- | --- |

Sortierung: Priority (P0 → P2), dann unabhängige vor blockierten Tickets, dann Size (klein
zuerst), dann Alter.

Status, Priority, Size und Quelle sind echte Board-Felder — direkt übernehmen, nicht schätzen.
Ist ein Feld leer, `—` eintragen.

## Ableitungen kennzeichnen

Für **Blocker und Risiko gibt es keine Board-Felder**. Diese Angaben werden bei jedem Lauf
heuristisch abgeleitet und müssen sichtbar als Schätzung markiert sein, z.B. mit einem Suffix
`(geschätzt)`.

„Blockiert" wird ausschließlich an Formulierungen im Titel/Body erkannt: „nach #49",
„blockiert durch #49", „braucht #49", „Rest aus #49", „siehe #49" (Liste in
`../ticket-workflow-shared/references/ticket-format.md`). Referenziert ein Ticket ein
**geschlossenes** Issue, zählt das nicht als Blocker.

**Fehlt ein Signal, nicht raten** — dann gilt das Ticket als unabhängig, so wie es in
`ticket-format.md` festgelegt ist.

## Zusammenfassung

Nach der Tabelle zwei bis drei Sätze: wie viele Tickets offen sind, was als Nächstes
sinnvoll wäre und ob etwas auffällt (z.B. viele Tickets in „In Progress", die niemand
bearbeitet).
