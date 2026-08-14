# Board-Referenz

GitHub Project mit den unten festgehaltenen IDs. **Nicht bei jeder Skill-Ausführung neu
ermitteln** — diese Datei ist die Quelle. Nur aktualisieren, wenn ein `gh`-Aufruf tatsächlich
fehlschlägt, weil sich eine ID geändert hat.

## Ticket-Board (das produktive Board)

| Feld | Wert |
| --- | --- |
| Repository | `DevArchitect-Eng/PeakHabit` |
| Default-Branch | `main` |
| Project-Nummer | `2` |
| Project-Owner | `DevArchitect-Eng` (User, nicht Org) |
| Project-ID | `PVT_kwHOEuK3vc4BgVVq` |
| URL | https://github.com/users/DevArchitect-Eng/projects/2 |

## Status-Feld

Feld-ID: `PVTSSF_lAHOEuK3vc4BgVVqzhah5Iw`

| Option | ID |
| --- | --- |
| Backlog | `f75ad846` |
| Ready | `61e4505c` |
| In progress | `47fc9ee4` |
| In review | `df73e18b` |
| Done | `98236657` |

Schreibweise beachten: „In progress" und „In review" klein nach dem ersten Wort.

## Priority-Feld

Feld-ID: `PVTSSF_lAHOEuK3vc4BgVVqzhah5LQ`

| Option | ID |
| --- | --- |
| P0 | `79628723` |
| P1 | `0a877460` |
| P2 | `da944a9c` |

## Size-Feld

Feld-ID: `PVTSSF_lAHOEuK3vc4BgVVqzhah5LU`

| Option | ID |
| --- | --- |
| XS | `6c6483d2` |
| S | `f784b110` |
| M | `7515a9f1` |
| L | `817d0097` |
| XL | `db339eb2` |

Bedeutung und Vergabe-Heuristik der Felder stehen in `ticket-format.md`.

Dieses Board hat **kein Quelle-Feld**. Von Claude gefundene Tickets werden allein über das
Label `claude-found` gekennzeichnet.

Ein **Blocker-Feld existiert nicht** — Abhängigkeiten werden im Issue-Text ausgedrückt
(Formulierungen in `ticket-format.md`).

## Ideen-Board (kein Ticket-Board)

Für Ideen, die noch keine Tickets sind. Einträge sind **Draft-Items**, keine Issues, und
lassen sich in GitHub per Klick in ein echtes Issue umwandeln.

| Feld | Wert |
| --- | --- |
| Project-Nummer | `1` |
| Project-ID | `PVT_kwHOEuK3vc4BgVOl` |
| URL | https://github.com/users/DevArchitect-Eng/projects/1 |
| Status-Feld-ID | `PVTSSF_lAHOEuK3vc4BgVOlzhahyiw` |

Status-Optionen: Idee `b195c0a3`, Angenommen `863d27f2`, Später `e7f98d4e`,
Verworfen `2c9a1dff`.

Neue Idee anlegen:

```bash
gh project item-create 1 --owner DevArchitect-Eng --title "<titel>" --body "<beschreibung>"
```

**Die Ticket-Skills fassen dieses Board nicht an.** Es wird nur bespielt, wenn ausdrücklich
nach einer Idee-Notiz gefragt wird. Wird eine Idee zum Ticket, entsteht daraus ein normales
Issue auf Board 2, und der Draft wird auf „Angenommen" gesetzt.

## Status setzen

```bash
gh project item-edit \
  --project-id PVT_kwHOEuK3vc4BgVOl \
  --id <ITEM_ID> \
  --field-id PVTSSF_lAHOEuK3vc4BgVOlzhahyiw \
  --single-select-option-id <OPTION_ID>
```

Die `<ITEM_ID>` ist die Project-Item-ID (nicht die Issue-Nummer). Ermitteln über:

```bash
gh project item-list 1 --owner DevArchitect-Eng --format json
```

## Issue aufs Board legen

```bash
gh project item-add 1 --owner DevArchitect-Eng --url <ISSUE_URL>
```

## Weitere Felder setzen

Priority, Size und Quelle laufen über denselben `item-edit`-Aufruf, nur mit anderer
`--field-id` und `--single-select-option-id`.

## Labels

Im Repository vorhanden: `bug`, `enhancement`, `claude-found`, `documentation`,
`accessibility`, `duplicate`, `good first issue`, `help wanted`, `invalid`, `question`,
`wontfix`.

`bug` oder `enhancement` ist Pflicht, `claude-found` kommt bei selbst gefundenen Tickets dazu
(siehe `ticket-format.md`). Keine neuen Labels anlegen, ohne dass sie gebraucht werden.
