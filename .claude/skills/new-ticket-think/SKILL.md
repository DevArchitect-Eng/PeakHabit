---
name: new-ticket-think
description: Durchsucht Code und Dokumentation nach offenen Punkten (TODOs, dokumentierte Lücken), gleicht gegen bestehende Issues ab und legt nach Bestätigung Tickets an.
---

# new-ticket-think

Aufruf: `/new-ticket-think`

Lies zuerst `../ticket-workflow-shared/references/ticket-format.md` und
`../ticket-workflow-shared/references/board.md`.

Gezielt suchen, **nicht** die ganze Codebase auf einmal durchgehen.

## 1. Suchen

Gezielt nach offenen Punkten suchen:

```bash
grep -rn "TODO\|FIXME\|HACK\|XXX" lib/ test/
```

Zusätzlich lesen und auf dokumentierte, aber nicht umgesetzte Vorhaben prüfen:

- `docs/ARCHITECTURE.md` — insbesondere Abschnitte, die etwas als „noch nicht festgelegt"
  oder „noch nicht implementiert" markieren
- `README.md`
- `CLAUDE.md`

Weitere echte Lücken, die beim Lesen auffallen: fehlende Testabdeckung an kritischen Stellen,
Platzhalter-Screens ohne Funktion, inkonsistente Fehlerbehandlung.

Keine Stilkritik und keine hypothetischen Verbesserungen sammeln — nur konkret Umsetzbares.

## 2. Duplikate ausschließen

```bash
gh issue list --state all --limit 100
```

Jeden Kandidaten dagegen abgleichen. Bereits erfasste Punkte verwerfen.

## 3. Vorschlagsliste zeigen

**Erst bestätigen lassen, dann anlegen.** Tabelle ausgeben:

| # | Titel | Fundstelle | Priority | Size | Begründung |
| --- | --- | --- | --- | --- | --- |

Fundstelle ist die konkrete Quelle, z.B. `lib/core/router/app_router.dart:22` oder
`docs/ARCHITECTURE.md § Fehlerbehandlung`.

## 4. Nach Bestätigung anlegen

Nur die bestätigten Punkte. Body-Format nach Größe wählen (siehe `ticket-format.md`), die
Fundstelle im Body nennen.

Labels: `bug` oder `enhancement` **plus `claude-found`** — diese Tickets stammen aus einer
automatisierten Durchsicht, nicht vom Nutzer.

Board: Status **Backlog**, Priority, Size, **Quelle = Claude**.

So bleibt später nachvollziehbar, welche Tickets aus dieser Durchsicht stammen.
