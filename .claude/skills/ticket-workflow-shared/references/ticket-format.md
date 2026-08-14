# Ticket-Aufbau

Verbindlich für `/new-ticket`, `/new-ticket-think` und beim Anlegen von Folge-Tickets.

## Body — zwei Formate je nach Größe

### Kleiner/klarer Bug (leichtgewichtig)

```markdown
**Problem**
<was ist kaputt oder fehlt, so konkret wie möglich>

**Vorschlag**
<falls schon eine Lösungsidee erkennbar ist>
```

### Größeres Feature (ausführlicher)

```markdown
## Ziel
<worum geht es>

## Funktionsumfang
<konkrete Punkte>

## Offene Fragen / zu klären bei Umsetzung
<Unklarheiten, die erst bei der Umsetzung geklärt werden>

## Akzeptanzkriterien
- [ ] ...
```

Akzeptanzkriterien sind optional, aber empfehlenswert: Sie geben `/do-ticket` ein klares
„fertig ist fertig", das nicht interpretiert werden muss.

Das Format nach der tatsächlichen Größe wählen — ein Einzeiler-Bug bekommt keine
Funktionsumfang-Überschrift.

## Labels

- **Pflicht:** `bug` **oder** `enhancement` — entscheidet Ton und Einordnung.
- **Zusätzlich `claude-found`**, wenn das Ticket von Claude beim Durchsehen von Code/Docs
  gefunden wurde statt vom Nutzer angefragt.
- Weitere vorhandene Labels nach Passung (Liste in `board.md`). Keine neuen Labels erfinden.

## Board-Felder beim Anlegen

| Feld | Werte | Hinweis |
| --- | --- | --- |
| Status | Backlog → Ready → In progress → In review → Done | Skills pflegen ihn entlang des Workflows |
| Priority | P0 / P1 / P2 | grobe Schätzung bei Anlage, keine endgültige Festlegung |
| Size | XS / S / M / L / XL | grobe Schätzung, dient der Sortierung im Loop-Modus |

Ein Quelle-Feld gibt es auf dem Board nicht — die Herkunft steckt im Label `claude-found`.

Neue Tickets starten immer auf **Backlog**. Feld-IDs stehen in `board.md`.

### Priority-Heuristik

- `P0` — App unbenutzbar, Datenverlust, blockiert alles andere
- `P1` — Kernfunktion betroffen oder blockiert andere Tickets
- `P2` — alles Übrige, inklusive Politur und Nice-to-have

### Size-Heuristik

- `XS` — einzelne Datei, wenige Zeilen
- `S` — ein Feature-Ordner, keine neuen Abhängigkeiten
- `M` — mehrere Dateien oder ein neuer Screen
- `L` — feature-übergreifend, neues Datenmodell oder Migration
- `XL` — Architekturänderung; sollte vor der Umsetzung aufgeteilt werden

## Abhängigkeiten im Text ausdrücken

Das Board hat **kein** Blocker-Feld. `/check-ticket` und `/do-ticket-loop` erkennen
Abhängigkeiten ausschließlich an Formulierungen in Titel oder Body:

> „nach #49", „blockiert durch #49", „braucht #49", „Rest aus #49", „siehe #49"

Ohne eine solche Formulierung gilt ein Ticket als **unabhängig** — auch wenn es inhaltlich
auf etwas anderem aufbaut. Deshalb beim Anlegen im Zweifel explizit hinschreiben.

## „Ausreichend spezifiziert"

Maßstab für die Beförderung Backlog → Ready durch `/check-ticket-ready`:

> Reicht die Beschreibung, um direkt mit `/do-ticket` loszulegen, ohne dass sofort eine
> Rückfrage nötig wäre?

Nicht perfekt, aber ein klares Problem/Ziel plus genug Kontext für einen ersten
Umsetzungsversuch.

## Kommentare zählen mit

`/do-ticket` liest beim Umsetzen auch die Issue-Kommentare, nicht nur den ursprünglichen Body.
Spätere Präzisierungen und Antworten auf Rückfragen landen dort also nicht ins Leere — und
gehören beim Anlegen nicht vorweggenommen.
