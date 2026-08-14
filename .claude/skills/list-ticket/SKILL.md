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

| # | Titel | Status | Priority | Unabhängig | Alter |
| --- | --- | --- | --- | --- | --- |

Sortierung: Priority (Critical → Low), dann unabhängige vor blockierten Tickets, dann Alter.

## Ableitungen kennzeichnen

Das Board hat **keine** Felder für Risiko, Größe oder Blocker. Solche Angaben dürfen nur
heuristisch aus Labels und Issue-Text abgeleitet werden — und müssen dann sichtbar als
Schätzung markiert sein, z.B. `unabhängig?` oder ein Suffix `(geschätzt)`.

Signale für „blockiert": Issue-Text nennt ein anderes Ticket als Voraussetzung, GitHub-
Verlinkung auf ein offenes Issue, Label `help wanted`/`question`.

**Fehlt ein Signal, nicht raten** — Feld leer lassen oder `unbekannt` eintragen.

## Zusammenfassung

Nach der Tabelle zwei bis drei Sätze: wie viele Tickets offen sind, was als Nächstes
sinnvoll wäre und ob etwas auffällt (z.B. viele Tickets in „In Progress", die niemand
bearbeitet).
