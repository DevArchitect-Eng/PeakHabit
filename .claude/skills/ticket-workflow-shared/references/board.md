# Board-Referenz

GitHub Project mit den unten festgehaltenen IDs. **Nicht bei jeder Skill-Ausführung neu
ermitteln** — diese Datei ist die Quelle. Nur aktualisieren, wenn ein `gh`-Aufruf tatsächlich
fehlschlägt, weil sich eine ID geändert hat.

## Projekt

| Feld | Wert |
| --- | --- |
| Repository | `DevArchitect-Eng/PeakHabit` |
| Default-Branch | `main` |
| Project-Nummer | `1` |
| Project-Owner | `DevArchitect-Eng` (User, nicht Org) |
| Project-ID | `PVT_kwHOEuK3vc4BgVOl` |
| URL | https://github.com/users/DevArchitect-Eng/projects/1 |

## Status-Feld

Feld-ID: `PVTSSF_lAHOEuK3vc4BgVOlzhahyiw`

| Option | ID |
| --- | --- |
| Backlog | `b210ac7b` |
| Ready | `d9339a19` |
| In Progress | `a05323cc` |
| In Review | `db24b512` |
| Done | `addf73f6` |

## Priority-Feld

Feld-ID: `PVTSSF_lAHOEuK3vc4BgVOlzhahy5I`

| Option | ID |
| --- | --- |
| P0 | `2560a17d` |
| P1 | `e7507e91` |
| P2 | `1e132445` |

## Size-Feld

Feld-ID: `PVTSSF_lAHOEuK3vc4BgVOlzhah6WI`

| Option | ID |
| --- | --- |
| XS | `b32985d7` |
| S | `02c9a8d3` |
| M | `e7259ab5` |
| L | `0c4271c6` |
| XL | `caae0fa8` |

## Quelle-Feld

Feld-ID: `PVTSSF_lAHOEuK3vc4BgVOlzhah6WM`

| Option | ID |
| --- | --- |
| User | `0fd00558` |
| Claude | `c3f8a275` |

Bedeutung und Vergabe-Heuristik der Felder stehen in `ticket-format.md`.

Ein **Blocker-Feld existiert nicht** — Abhängigkeiten werden im Issue-Text ausgedrückt
(Formulierungen in `ticket-format.md`).

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
