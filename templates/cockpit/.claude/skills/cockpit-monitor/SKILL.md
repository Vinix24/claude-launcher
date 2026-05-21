---
name: cockpit-monitor
description: >
  Poll the active workers and surface their completion. Primary mechanism:
  file-watch on ~/.claude-launcher/output/ for <task-id>.done marker files.
  Designed to run every 30s via /loop 30s /cockpit-monitor, or manually after
  spawning workers.
---

# cockpit-monitor

Detecteer wanneer workers klaar zijn en surface dat naar de gebruiker. Primair mechanisme: check op `<task-id>.done` marker-files in `~/.claude-launcher/output/`. Secundair: lees de inbox NDJSON files voor granulaire updates.

## Stappen per tick

### 1. Lees manifest

```bash
cat ~/.claude-launcher/manifest.json
```

Lijst van actieve task-ids met workspace en started-at.

### 2. Check .done files

Voor elke task-id in de manifest:

```bash
ls ~/.claude-launcher/output/<task-id>.done 2>/dev/null
```

Bestaat het? → die worker is klaar. Lees de inhoud (één-regel samenvatting) en surface.

Bestaat niet? → worker is nog bezig. Skip.

### 3. Track wat je al hebt gesurfaced

Houd in je werkgeheugen bij welke task-ids al gemeld zijn. Als je een .done al hebt gemeld, niet opnieuw doen op de volgende tick.

Cold-start fallback (na compaction of nieuwe sessie): surface alle .done files die je nu ziet, behandel ze als "net opgemerkt". Beter dubbel melden dan missen.

### 4. Optioneel: inbox-events

Voor extra context kun je per task-id ook lezen:

```bash
cat ~/.claude-launcher/inbox/<task-id>.ndjson
```

Als er events instaan (status / question / error), surface `question` en `error blocking=true` direct. Status-events alleen bij milestones. Maar **vertrouw niet op deze file voor done-detectie** — workers kunnen `cockpit msg done` vergeten. De .done marker is de bron van waarheid.

### 5. Output-formaat

Eén regel per surface, geprefixed met task-id:

```
[blog-2026-05-21-toekomst-marketing-growthlab] klaar: blog 1247w + editor-rapport PASS WITH NOTES
[blog-2026-05-21-toekomst-marketing-studio-atlas] klaar: blog 1283w + editor-rapport PASS
```

Bij eerste tick zonder events: stilte. Niet "wachten op events" spammen.

### 6. Alle workers klaar?

Wanneer **elke** task-id uit de manifest een .done-file heeft:

1. Surface een totaal-overzicht aan de gebruiker
2. Stop de /loop (`/loop stop`)
3. Vraag vervolgactie (open / vergelijken / export / etc.)
4. Voor de parallel-clients demo: trigger automatisch de comparison-step zoals beschreven in `docs/DEMO-PROMPT.md`

## Activatie

`project-manager` skill zet deze monitor automatisch op met `/loop 30s /cockpit-monitor` direct na een dispatch.

**Tijdseenheid is verplicht** — geldig: `15s`, `30s`, `60s`, `1m`, `2m`. NOOIT `/loop 30` of `/loop 60` zonder unit (valt naar dynamic mode).

Stoppen: `/loop stop`. Project-manager doet dit automatisch zodra alle .done-files er zijn.

## Wat NIET doen

- Niet zelf antwoorden op `question`-events. Vraag altijd de gebruiker.
- Niet workers killen op basis van events alleen. Vraag bevestiging.
- Niet wachten op een `cockpit msg done`-event in de inbox NDJSON. De worker kan dat vergeten. Check de .done file.
- Niet de inbox-files of done-files automatisch wissen.
