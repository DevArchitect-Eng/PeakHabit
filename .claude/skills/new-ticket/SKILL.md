---
name: new-ticket
description: Erstellt aus einer freien Beschreibung ein strukturiertes GitHub-Issue und legt es mit Backlog-Status, Priority-Schätzung und Label aufs Board.
---

# new-ticket

Aufruf: `/new-ticket <freie Beschreibung>`

Lies zuerst `../ticket-workflow-shared/references/board.md`.

## Ablauf

### 1. Kontext prüfen

Kurz gegen bestehende Issues abgleichen, um Duplikate zu vermeiden:

```bash
gh issue list --state all --search "<stichworte>"
```

Bei einem klaren Duplikat: darauf hinweisen statt neu anzulegen.

### 2. Issue formulieren

Aus dem Freitext ableiten — **nicht** nachfragen, außer es lässt sich nicht einmal ein
sinnvoller Titel bilden.

```markdown
## Ziel
Was soll erreicht werden und warum.

## Akzeptanzkriterien
- [ ] konkret und prüfbar
- [ ] ...

## Kontext
Betroffene Bereiche der App, relevante Dateien, bekannte Einschränkungen.
```

Titel: kurz, imperativ, konkret. Kein „Verbessere X", sondern was tatsächlich passieren soll.

### 3. Anlegen

```bash
gh issue create --title "<titel>" --body "<body>" --label "<label>"
```

Label aus den vorhandenen wählen (Liste in `board.md`). Keine neuen Labels erfinden.

### 4. Aufs Board

Issue hinzufügen, Status auf **Backlog**, Priority grob schätzen (Befehle in `board.md`).

Priority-Heuristik:

- `Critical` — App unbenutzbar, Datenverlust
- `High` — Kernfunktion betroffen, blockiert andere Tickets
- `Medium` — Standardfall
- `Low` — Politur, Nice-to-have

Ein Size-Feld existiert nicht; Größenangaben gehören in den Issue-Text und sind als Schätzung
zu kennzeichnen.

### 5. Melden

Issue-Nummer, URL, gesetztes Label und Priority ausgeben.
