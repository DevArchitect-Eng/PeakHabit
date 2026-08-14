---
name: do-ticket-publish
description: Veröffentlicht einen mit do-ticket-prepare vorbereiteten Branch — Push, PR, CI-Überwachung, CI-Reparatur und Merge-Gate. Aufruf mit der Ticketnummer.
---

# do-ticket-publish

Aufruf: `/do-ticket-publish <nummer>`

Übernimmt einen lokal vorbereiteten Branch und bringt ihn bis ans Merge-Gate. Funktioniert
interaktiv **und** als Hintergrundschritt von `/do-ticket-loop`.

Lies zuerst `../ticket-workflow-shared/references/conventions.md` und
`../ticket-workflow-shared/references/board.md`.

## Ablauf

### 1. Branch finden und prüfen

Branch `<nummer>-*` lokal suchen. Existiert keiner, abbrechen und melden — dieser Skill
implementiert nichts selbst.

Prüfen, dass der Stand sauber ist und die Verifikationskette lokal grün läuft:

```bash
dart format .
flutter analyze
flutter test
```

Ist sie rot, **nicht** veröffentlichen. Melden und anhalten.

### 2. Rebase auf aktuellen main

```bash
git fetch origin && git rebase origin/main
```

Bei Merge-Konflikten **nicht raten**: Rebase abbrechen (`git rebase --abort`), Ticket als
blockiert melden. Konfliktauflösung ist keine Hintergrundentscheidung.

### 3. Push und PR

Push, dann PR mit der Body-Struktur aus `conventions.md`. Annahmen aus der Prepare-Phase
dort dokumentieren. Board auf „In Review".

### 4. CI

```bash
gh pr checks --watch
```

Bei Rot gezielt reparieren, **maximal 3 Versuche**. Danach PR offen lassen und als blockiert
melden.

### 5. Merge-Gate

Policy ist konservativ: **niemals selbst mergen.**

Ohne live mitlesenden Nutzer (Loop-Modus) gilt zusätzlich: bei risikoreichen Änderungen nicht
raten und nichts unbeaufsichtigt entscheiden. PR offen lassen und klar als wartend melden.

Bei grüner CI: PR zur Freigabe vorlegen, Status `waiting` loggen, Board bleibt „In Review".
Erst nach dem Merge durch den Nutzer auf „Done".

## Logging

Im Loop-Modus jede Phase in `~/peakhabit-logs/loop.log` schreiben — Format in
`../ticket-workflow-shared/references/log-format.md`.
