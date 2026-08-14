---
name: new-ticket
description: Erstellt aus einer freien Beschreibung ein strukturiertes GitHub-Issue und legt es mit Backlog-Status, Priority-/Size-Schätzung und passendem Label aufs Board.
---

# new-ticket

Aufruf: `/new-ticket <freie Beschreibung>`

Lies zuerst `../ticket-workflow-shared/references/ticket-format.md` (Body-Formate,
Labels, Feld-Heuristiken) und `../ticket-workflow-shared/references/board.md` (Feld-IDs).

## Ablauf

### 1. Duplikate ausschließen

```bash
gh issue list --state all --search "<stichworte>"
```

Bei einem klaren Duplikat darauf hinweisen statt neu anzulegen.

### 2. Issue formulieren

Format nach Größe wählen — leichtgewichtig für einen klaren Bug, ausführlich für ein
größeres Feature. Beide Vorlagen stehen in `ticket-format.md`.

Aus dem Freitext ableiten, **nicht** nachfragen — außer es lässt sich nicht einmal ein
sinnvoller Titel bilden.

Titel: kurz, imperativ, konkret. Kein „Verbessere X", sondern was tatsächlich passieren soll.

Hängt das Ticket erkennbar an einem anderen, die Abhängigkeit **explizit in den Text**
schreiben („braucht #49", „nach #49") — das Board hat kein Blocker-Feld, und ohne diese
Formulierung gilt das Ticket später als unabhängig.

### 3. Anlegen

```bash
gh issue create --title "<titel>" --body "<body>" --label "<bug|enhancement>"
```

`bug` oder `enhancement` ist Pflicht. `claude-found` gehört hier **nicht** dazu — das Ticket
kommt vom Nutzer.

### 4. Aufs Board

Issue hinzufügen und setzen (Befehle und IDs in `board.md`):

- **Status:** Backlog
- **Priority:** grobe Schätzung (P0/P1/P2)
- **Size:** grobe Schätzung (XS–XL)
- **Quelle:** User

Alle Schätzungen sind vorläufig und dürfen später korrigiert werden.

### 5. Melden

Issue-Nummer, URL, Label und die gesetzten Feldwerte ausgeben.
