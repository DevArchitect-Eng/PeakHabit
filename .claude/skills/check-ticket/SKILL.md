---
name: check-ticket
description: Prüft offene Tickets gegen den aktuellen Code statt nur gegen ihren Text, bewertet Aktualität und passende Board-Spalte und schlägt Duplikat- oder Erledigt-Kandidaten zur Bestätigung vor.
---

# check-ticket

Aufruf: `/check-ticket [nummer]`

Ohne Nummer werden alle offenen Tickets geprüft, mit Nummer nur das eine.

Lies zuerst `../ticket-workflow-shared/references/board.md` und
`../ticket-workflow-shared/references/ticket-format.md`.

## Was übersprungen wird

Tickets mit Board-Status **In Progress** oder **In Review** — dort arbeitet gerade jemand
oder etwas. Nicht anfassen, nur in der Zusammenfassung erwähnen.

## Prüfung je Ticket

Nicht nur den Issue-Text lesen, sondern **gegen den echten Code prüfen**:

1. Issue und Kommentare lesen
2. Die genannten Dateien/Bereiche im Code tatsächlich öffnen
3. Bewerten:
   - **Erledigt?** Ist die beschriebene Funktion inzwischen da (z.B. durch einen anderen PR)?
   - **Überholt?** Bezieht sich das Ticket auf Code, der so nicht mehr existiert?
   - **Duplikat?** Deckt ein anderes offenes Issue dasselbe ab?
   - **Falsche Spalte?** Ausreichend spezifiziert und unabhängig → gehört nach Ready.
     Vage oder blockiert → gehört ins Backlog. Maßstab für „ausreichend spezifiziert" steht
     in `ticket-format.md`.
   - **Abhängigkeit noch aktuell?** Nennt der Text einen Blocker („nach #49", „braucht #49",
     …), prüfen, ob das referenzierte Issue noch offen ist. Ist es inzwischen geschlossen,
     ist das Ticket nicht mehr blockiert — das ist ein Befund.
   - **Felder plausibel?** Priority, Size und Quelle gegen den tatsächlichen Umfang prüfen.
     Grobe Fehlschätzungen melden.

## Ausgabe

| # | Titel | Aktueller Status | Befund | Empfehlung | Beleg |
| --- | --- | --- | --- | --- | --- |

Beleg ist die konkrete Codestelle, auf die sich der Befund stützt, z.B.
`lib/features/home/presentation/home_screen.dart:14`. Ohne Beleg keine Behauptung, ein Ticket
sei erledigt.

## Grenzen

- **Keine Tickets eigenständig schließen.** Erledigt- und Duplikat-Kandidaten werden zur
  Bestätigung vorgelegt, nicht ausgeführt.
- Board-Status darf nach Bestätigung angepasst werden (Backlog ↔ Ready). Priority- und
  Size-Korrekturen ebenfalls erst nach Bestätigung.
- Bei Unsicherheit `unklar` melden statt zu raten.

## Zusammenfassung

Kurz: wie viele Tickets geprüft, wie viele auffällig, was zuerst geklärt werden sollte.
