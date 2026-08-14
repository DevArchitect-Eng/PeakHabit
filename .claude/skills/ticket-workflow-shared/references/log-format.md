# Log-Format für den Loop-Modus

## Pfad

`~/peakhabit-logs/loop.log`

Bewusst außerhalb des Repositories, damit Einträge mehrere Worktrees überleben und nicht auf
`main` committed werden müssen. Ordner bei Bedarf anlegen.

## Format

Eine Zeile pro Ereignis, immer anhängen (nie überschreiben). Einträge treffen in
Abschlussreihenfolge ein, nicht in Startreihenfolge — deshalb trägt jede Zeile die
Ticketnummer.

```
<ISO-8601-Zeitstempel> | #<nummer> | <phase> | <ergebnis> | <details>
```

- **phase**: `prepare`, `publish`, `ci`, `merge-gate`, `followup`
- **ergebnis**: `ok`, `blocked`, `failed`, `waiting`

## Beispiele

```
2026-08-14T10:12:04Z | #42 | prepare | ok | branch 42-koerpergewicht-eintragen, analyze+test grün
2026-08-14T10:18:31Z | #42 | publish | ok | PR #57 geöffnet
2026-08-14T10:24:57Z | #42 | ci | failed | flutter analyze: unused_import lib/app.dart, Reparatur 1/3
2026-08-14T10:31:12Z | #42 | ci | ok | alle Checks grün
2026-08-14T10:31:20Z | #42 | merge-gate | waiting | Freigabe des Nutzers erforderlich (Policy: konservativ)
2026-08-14T10:33:02Z | #42 | followup | ok | Folge-Issue #58 (fehlende Testabdeckung Gewichts-Repository)
2026-08-14T10:41:15Z | #43 | prepare | blocked | Merge-Konflikt mit #42 in lib/core/router/app_router.dart
```

## Was protokolliert wird

Je Ticket mindestens: Ergebnis, PR-Nummer, gelaufene Tests, CI-Status, angelegte Folge-Tickets
und getroffene Entscheidungen. Blockaden immer mit Grund.
