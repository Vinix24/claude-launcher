---
name: cockpit-monitor
description: >
  Poll all active worker inboxes and surface the events that need operator attention
  (questions, deliver, done, errors). Designed to be invoked every 60 seconds via
  /loop 60s /cockpit-monitor, or manually after spawning a worker.
---

# cockpit-monitor

Lees alle inbox-NDJSON-bestanden van actieve workers en surface relevante events naar de gebruiker.

## Stappen per tick

### 1. Lijst actieve workers

```bash
cockpit status
```

Geeft per worker: task-id, workspace, started-at, aantal events in inbox.

### 2. Lees ELKE inbox volledig

Voor elk task-id uit de manifest, lees `~/.claude-launcher/inbox/<task-id>.ndjson` van regel 1 tot het einde. Niet tail, niet `-F`, niet alleen-nieuwe-regels. Het hele bestand.

```bash
cat ~/.claude-launcher/inbox/<task-id>.ndjson
```

### 3. Track wat je al hebt gezien

Houd een mentale teller bij per task-id: hoeveel regels van die inbox heb je deze sessie al gesurfaced? Dat is jouw "seen-count". Surface alleen regels met index > seen-count. Update de teller na surfacen.

Voorbeeld: tick 1 leest 3 regels (status, status, question) → surface alle 3, seen-count = 3. Tick 2 leest 5 regels → surface alleen regel 4 en 5, seen-count = 5.

Als je geen geheugen meer hebt van vorige ticks (cold start na compaction), surface alleen `done` / `error blocking=true` / `question` regels — dat zijn de altijd-relevant types die nooit te laat zijn om te tonen.

### 4. Surface op basis van event-type

| Event-type | Actie |
|---|---|
| `status` | Stil houden tenzij milestone (outline, draft 80%, klaar voor review) |
| `question` | **Direct surfacen**, vraag de gebruiker om antwoord, paste antwoord door naar worker via een nieuwe instructie |
| `deliver` | Surface "artefact klaar: `<pad>`". Vraag of de gebruiker hem wil zien / openen / converteren |
| `done` | Surface "task `<task-id>` klaar: `<samenvatting>`". Vraag vervolgactie |
| `error blocking=true` | **Direct surfacen**, escaleer naar gebruiker |
| `error blocking=false` | Log + status, tenzij meerdere errors in dezelfde worker |

### 5. Maak het kort

Eén regel per event in surface. Niet de hele NDJSON terugparaderen.

Voorbeeld:

```
[linkedin-2026-05-20] question: lengte 900 of 1500 chars? [900 / 1500]
[blog-2026-05-20] status: outline klaar
[blog-2026-05-20] deliver: output/2026-05-20-ai-mkb.md (1.247 woorden)
```

### 6. Wachtpatroon

Als er geen nieuwe events zijn: meld dat niet expliciet. Geen "ik blijf kijken, nog niets". Stilte is de juiste output, je wordt over 60s opnieuw aangeroepen door de /loop.

## Activatie

Twee routes, project-manager kiest:

**Default — Monitor skill (event-driven):** `project-manager` invokes `Monitor` met `tail -F -n +1` op `~/.claude-launcher/inbox/*.ndjson`. Direct getriggerd bij nieuwe regel. Geen polling-cycles. Pre-creatie van inbox-file door `cockpit launch` voorkomt de macOS file-watch race.

**Fallback — /loop 60s /cockpit-monitor:** wanneer Monitor niet beschikbaar is. Recurring poll elke 60 seconden. **Tijdseenheid is verplicht** — geldig: `30s`, `60s`, `1m`, `2m`, `5m`. NOOIT `/loop 30` of `/loop 60` zonder unit, dat valt naar dynamic mode. Stoppen: `/loop stop`.

Deze skill (`cockpit-monitor`) werkt onder beide routes — bij Monitor wordt hij niet expliciet aangeroepen (Monitor surfaced events direct), bij /loop wordt hij elke 60s aangeroepen en doorloopt zijn eigen lees-en-surface flow hieronder.

Project-manager stopt monitoring zodra alle actieve workers `done` hebben gerapporteerd en de gebruiker een vervolgactie heeft gekozen.

## Inbox-cleanup (geen v0.0)

Niet automatisch wissen. Laat events staan voor de geschiedenis. v0.5+ kan een retention-config krijgen.

## Wat NIET doen

- Niet zelf antwoorden op `question`-events. Vraag altijd de gebruiker.
- Niet workers killen op basis van events alleen. Vraag bevestiging.
- Niet de inbox roteren of opschonen.
- Niet tail of file-watch gebruiken (race-condities op macOS). Lees elke tick het hele bestand.
