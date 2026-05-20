---
name: cockpit-monitor
description: >
  Poll all active worker inboxes and surface the events that need operator attention
  (questions, done, errors). Use either manually after spawning a worker, or
  automatically via Monitor (event-driven) or /loop 1m /cockpit-monitor (poll).
---

# cockpit-monitor

Lees alle inbox-NDJSON-bestanden van actieve workers en surface relevante events naar de gebruiker.

## Stappen

### 1. Lijst actieve workers

```bash
cockpit status
```

Geeft per worker: task-id, workspace, started-at, aantal events in inbox.

### 2. Voor elke worker met nieuwe events

Lees `~/.claude-launcher/inbox/<task-id>.ndjson`. Track per session welke events je al hebt gezien (bv. een teller in je werkgeheugen) zodat je niet dezelfde events herhaaldelijk surfaced.

### 3. Surface op basis van event-type

| Event-type | Actie |
|---|---|
| `status` | Stil houden tenzij milestone (outline, draft, klaar voor review) |
| `question` | **Direct surfacen**, vraag de gebruiker om antwoord, dan `cockpit msg ...` of doorgeven aan worker via een nieuwe spawn met de answer |
| `deliver` | Surface "artefact klaar: <pad>". Vraag of de gebruiker hem wil zien / openen |
| `done` | Surface "task `<task-id>` klaar: <samenvatting>". Vraag vervolgactie (open / edit / nog een output-format / kill) |
| `error blocking=true` | **Direct surfacen**, escaleer naar gebruiker |
| `error blocking=false` | Log + status, tenzij meerdere errors in dezelfde worker |

### 4. Maak het kort

Eén regel per event in surface. Niet de hele NDJSON terugparaderen.

Voorbeeld:

```
[linkedin-2026-05-20] question: lengte 900 of 1500 chars? [900 / 1500]
[blog-2026-05-20] status: outline klaar
[blog-2026-05-20] deliver: output/2026-05-20-ai-mkb.md (1.247 woorden)
```

### 5. Wachtpatroon

Als geen events: meld dat niet expliciet (geen spam). Wacht op de volgende loop-iteratie.

## Inbox-cleanup (geen v0.0)

Niet automatisch wissen — laat events staan voor de geschiedenis. v0.5+ kan een retention-config krijgen.

## Activatie

Twee routes, in volgorde van voorkeur:

**Event-driven (aanbevolen)**: gebruik de `Monitor` skill met file-watch op `~/.claude-launcher/inbox/*.ndjson` filterend op events van type `question`, `deliver`, `done`, of `error`. Direct getriggerd op een nieuwe regel.

**Polling-fallback**: `/loop 1m /cockpit-monitor` (met **expliciete tijdseenheid** — `30s`, `1m`, `2m`, `5m`). NOOIT `/loop 60` zonder unit, dat valt naar dynamic mode. Stop met `/loop stop`.

`project-manager` skill kiest standaard route A (Monitor); deze skill werkt onder beide.

## Wat NIET doen

- Niet zelf antwoorden op `question`-events. Vraag de gebruiker.
- Niet workers killen op basis van events alleen. Vraag bevestiging.
- Niet de inbox roteren of opschonen in v0.0.
