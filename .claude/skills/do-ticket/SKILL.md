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

### 3. Nur bei echter Geschäftsentscheidung fragen

Alles, was aus Code, Doku oder Ticket-Kommentaren ableitbar ist, selbst klären. Nachfragen
nur bei Produktentscheidungen, die niemand aus dem Repository beantworten kann. Getroffene
Annahmen später im PR dokumentieren.

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

Echte Funde außerhalb des Scopes als eigenes Issue anlegen, nicht nur im Chat erwähnen.
Format nach `../ticket-workflow-shared/references/ticket-format.md`, dabei Label
**`claude-found`** setzen — diese Tickets stammen aus der eigenen
Arbeit, nicht vom Nutzer. Im Body auf das Ursprungsticket verweisen.
