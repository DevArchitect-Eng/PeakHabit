---
name: do-ticket
description: Setzt ein bestehendes GitHub-Issue vollständig um — Branch, Implementierung, Verifikation, Review, PR, CI und Merge-Gate. Aufruf mit der Ticketnummer.
---

# do-ticket

Aufruf: `/do-ticket <nummer>`

Lies zuerst `../ticket-workflow-shared/references/conventions.md` und
`../ticket-workflow-shared/references/board.md`. Projektregeln in `CLAUDE.md` und
`docs/ARCHITECTURE.md` gelten zusätzlich.

Gibt es einen QA-/Test-Agenten im Projekt, diesen für die Verifikation verwenden statt einen
eigenen Ablauf zu erfinden. Aktuell existiert keiner (`.claude/agents/` ist nicht vorhanden).

## Ablauf

### 1. Ticket verstehen

```bash
gh issue view <nummer> --comments
```

Prüfe, ob das Ticket bereits bearbeitet, gelöst oder blockiert ist — offene PRs, verlinkte
Branches, Kommentare. Trifft das zu: anhalten und berichten statt doppelt zu arbeiten.

Prüfe den aktuellen Code gegen die Beschreibung. Manche Tickets sind bereits durch andere
Änderungen erledigt.

### 2. Board auf „In Progress"

Item-ID ermitteln und Status setzen (Befehle in `board.md`). Ist das Issue nicht auf dem
Board, zuerst hinzufügen.

### 3. Vor dem Programmieren fragen

Beides wird hier geklärt, **bevor** ein Branch entsteht:

- **Geschäftsentscheidungen** — nur die, die niemand aus dem Repository beantworten kann.
  Alles aus Code, Doku oder Ticket-Kommentaren Ableitbare selbst klären und die Annahme
  später im PR dokumentieren.
- **Alles, was Code außerhalb des Tickets betrifft** — hier **immer** fragen. Dafür jetzt
  den betroffenen Code ansehen: Was hängt am Ticket dran, das es selbst nicht abdeckt?
  Abgrenzung in `../ticket-workflow-shared/references/conventions.md` § Rückfragen.

Fällt beim Umsetzen doch noch etwas auf, sofort fragen und so lange anhalten.

### 4. Branch anlegen

```bash
git checkout main && git pull
git checkout -b <nummer>-<inhaltlicher-slug>
```

### 5. Umsetzen

Konventionen aus `docs/ARCHITECTURE.md` einhalten (feature-first, Riverpod, go_router).
Keine Scope-Ausweitung.

### 6. Lokale Verifikation

```bash
dart format .
flutter analyze
flutter test
```

Bei UI-Änderungen zusätzlich auf Simulator/Emulator prüfen (siehe `conventions.md`).

### 7. Review

Code Review durchführen — verpflichtend. Bei sicherheits- oder datenrelevanten Änderungen
(Liste in `conventions.md`) zusätzlich Security Review. Findings beheben, danach Schritt 6
erneut ausführen.

Kostenpflichtige oder nutzergetriggerte Review-Modi nie selbst auslösen.

### 8. Akzeptanzkriterien abhaken

Jedes Akzeptanzkriterium einzeln gegen das tatsächliche Ergebnis prüfen und nachweislich
erfüllte im Issue-Body abhaken. **Selbständig, ohne nachzufragen** — Details und der
`gh issue edit`-Befehl stehen in `conventions.md`. Nicht erfüllte bleiben unverändert und
werden im PR-Body unter „Offene Risiken / Annahmen" genannt.

### 9. PR öffnen

Push, dann PR mit der Body-Struktur aus `conventions.md`. Board auf „In Review".

### 10. CI

```bash
gh pr checks --watch
```

Bei Rot gezielt reparieren, maximal 3 Versuche. Danach anhalten, PR offen lassen, als
blockiert melden. Hat eine Reparatur den Code verändert, betroffene Akzeptanzkriterien aus
Schritt 8 erneut prüfen.

### 11. Merge-Gate

Policy ist konservativ: **niemals selbst mergen.** Bei grüner CI und sauberem Review den PR
zur Freigabe vorlegen und anhalten. Board bleibt auf „In Review", bis der Nutzer gemergt hat;
danach auf „Done" setzen.

### 12. Nebenbefunde

Funde außerhalb des Scopes sind zu diesem Zeitpunkt bereits vorgelegt — in Schritt 3 oder,
wenn sie erst beim Umsetzen auffielen, sofort danach. Was der Nutzer freigegeben hat, wird
jetzt als eigenes Issue angelegt — Format nach
`../ticket-workflow-shared/references/ticket-format.md`, dabei Label **`claude-found`**
setzen, weil diese Tickets aus der eigenen Arbeit stammen, nicht vom Nutzer. Im Body auf das
Ursprungsticket verweisen.

Ohne Freigabe entsteht kein Issue.
