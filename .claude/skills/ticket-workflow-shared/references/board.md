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
| Low | `3e66fb9b` |
| Medium | `b4951a0b` |
| High | `54a44841` |
| Critical | `6a834128` |

Ein Size-Feld existiert nicht. Wo Sortierung nach Size verlangt ist, stattdessen heuristisch
aus Labels/Issue-Text schätzen und die Schätzung als solche kennzeichnen.

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

## Labels

Im Repository vorhanden: `bug`, `enhancement`, `documentation`, `accessibility`, `duplicate`,
`good first issue`, `help wanted`, `invalid`, `question`, `wontfix`. Keine neuen Labels anlegen,
ohne dass sie gebraucht werden.
