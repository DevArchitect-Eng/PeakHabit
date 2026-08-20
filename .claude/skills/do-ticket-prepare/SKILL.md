---
name: do-ticket-prepare
description: Setzt ein GitHub-Issue lokal um und stoppt nach Review und Verifikation — kein Push, kein PR, keine CI, kein Merge. Aufruf mit der Ticketnummer.
---

# do-ticket-prepare

Aufruf: `/do-ticket-prepare <nummer>`

Identisch zu `/do-ticket`, **Schritte 1 bis 9**. Danach ist Schluss.

Lies zuerst `../ticket-workflow-shared/references/conventions.md` und
`../ticket-workflow-shared/references/board.md`.

## Was gemacht wird

1. Issue inklusive Kommentare lesen, auf bereits erledigt/blockiert prüfen
2. Board auf „In Progress"
3. Offene Fragen stellen, **bevor** programmiert wird: Geschäftsentscheidungen und alles, was
   Code außerhalb des Tickets betrifft (`conventions.md` § Rückfragen). Dafür den betroffenen
   Code vorher ansehen
4. Branch `<nummer>-<slug>` von aktuellem `main`
5. Umsetzen
6. README.md, CLAUDE.md und `docs/ARCHITECTURE.md` bei Bedarf mitziehen
   (`conventions.md` § „Dokumentation aktuell halten")
7. `dart format .`, `flutter analyze`, `flutter test`; bei UI zusätzlich Simulator/Emulator
8. Code Review, bei Bedarf Security Review; Findings beheben und erneut verifizieren
9. Lokal committen
10. Akzeptanzkriterien einzeln gegen das Ergebnis prüfen und nachweislich erfüllte im
    Issue-Body abhaken — selbständig, ohne nachzufragen (Details in `conventions.md`)

## Was ausdrücklich NICHT gemacht wird

- kein `git push`
- kein PR
- keine CI
- kein Merge

Der Branch bleibt rein lokal. Veröffentlicht wird später mit `/do-ticket-publish <nummer>`.

## Abschlussbericht

Melde knapp:

- Branch-Name
- was umgesetzt wurde
- Ergebnis der Verifikationskette
- Review-Findings und wie sie behoben wurden
- welche Akzeptanzkriterien abgehakt wurden und welche nicht (mit Grund)
- getroffene Annahmen (die gehören später in den PR-Body)
- offene Rückfragen und was der Nutzer dazu entschieden hat
- offene Risiken oder Gründe, warum nicht fertig geworden

Bei Blockade: Branch mit dem bisherigen Stand committen, klar als blockiert melden und den
Grund nennen. Nicht raten.
