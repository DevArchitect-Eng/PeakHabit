---
name: check-ticket-ready
description: Prüft ausschließlich Backlog-Tickets auf Unabhängigkeit und ausreichende Spezifikation, verschiebt geeignete nach Ready und begründet, warum andere im Backlog bleiben.
---

# check-ticket-ready

Aufruf: `/check-ticket-ready`

Lies zuerst `../ticket-workflow-shared/references/board.md` und
`../ticket-workflow-shared/references/ticket-format.md`.

## Umfang

**Nur Tickets mit Board-Status Backlog.** Alles andere ignorieren — Ready, In Progress,
In Review und Done werden nicht angefasst.

## Maßstab

> Reicht die Beschreibung, um direkt mit `/do-ticket` loszulegen, ohne dass sofort eine
> Rückfrage nötig wäre?

Nicht perfekt, aber ein klares Problem/Ziel plus genug Kontext für einen ersten
Umsetzungsversuch.

## Ready-Kriterien

Ein Ticket darf nach Ready, wenn **alle** Punkte erfüllt sind:

1. **Zielklar** — es ist erkennbar, was am Ende anders sein soll.
2. **Fertig-Kriterium erkennbar** — jemand kann feststellen, ob es fertig ist. „Verbessere
   die Statistik" reicht nicht. Akzeptanzkriterien sind nicht Pflicht, machen es aber eindeutig.
3. **Unabhängig** — der Text nennt keinen offenen Blocker („nach #49", „braucht #49", … —
   Liste in `ticket-format.md`), und der nötige Code existiert bereits. Verweise auf
   geschlossene Issues zählen nicht als Blocker.
4. **Keine offene Geschäftsentscheidung** — alles Nötige ist aus Code, Doku oder Ticket
   ableitbar. Fehlt eine Produktentscheidung, bleibt es im Backlog.
5. **Im Rahmen** — passt zu `docs/ARCHITECTURE.md` und erfordert keinen Architekturumbau, der
   selbst noch nicht entschieden ist. `Size = XL` ist ein Warnsignal: erst aufteilen.

Für die Unabhängigkeitsprüfung den Code tatsächlich ansehen, nicht nur den Ticket-Text. Ein
Ticket zur Gewichts-Statistik ist nicht ready, solange es keine Datenhaltung für Gewicht gibt.

Fehlen Priority oder Size, beim Befördern gleich mit setzen — der Loop-Modus sortiert danach.

## Ausgabe

| # | Titel | Entscheidung | Begründung |
| --- | --- | --- | --- |

Entscheidung ist `→ Ready` oder `bleibt Backlog`. Die Begründung ist bei „bleibt Backlog"
konkret: welches Kriterium fehlt und was nötig wäre, um es zu erfüllen.

## Danach

Die als Ready bewerteten Tickets auf dem Board verschieben (Befehle in `board.md`).

Das ist die einzige Schreibaktion dieses Skills — keine Issues anlegen, ändern oder schließen.
