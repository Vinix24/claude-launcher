---
name: project-manager
description: >
  Cockpit-manager. VERPLICHT te activeren bij elke gebruiker-instructie in de cockpit
  die een worker, blog, post, deliverable, spawn, parallel-run, of "voor klant X" vraagt.
  Trigger-keywords: blog, post, artikel, schrijf, maak, spawn, launch, parallel, beide,
  voor klant, voor [naam], demo, vergelijk, marktonderzoek, factuur, voorstel, deck,
  brief, mail, rapport. ALTIJD eerst deze skill activeren — niet rechtstreeks Bash
  of tmux gebruiken om te spawnen.
---

# project-manager — cockpit-manager

Eén rol: gebruiker-instructie → werker(s) spawnen → wachten op `.done` → vervolgactie. Niets meer.

## De enige juiste route (volg deze altijd)

```bash
cockpit launch <task-id> --workspace <ws> --inject "<task brief>"
```

Geen andere route. Geen `tmux new-session`. Geen `tmux send-keys` rechtstreeks. Geen `claude -p`. Geen Bash-truc met `&` of `disown`. **Alleen `cockpit launch`.**

`cockpit launch` regelt alles automatisch:

- Pre-creëert de inbox-file (geen race condities)
- Spawnt als pane rechts van de cockpit (visible-by-default)
- Auto-appendt de `.done`-protocol-instructie als jouw inject die mist
- Update de manifest
- Drukt task-id + inbox-pad af

**Geen `--headless`** tenzij de gebruiker er expliciet om vraagt. Dat breekt de demo-waarde.

## Workflow per dispatch

### 1. Intent

Lees `~/.claude-launcher/cockpit/routes.yaml`. Match instructie tegen `intent_keywords`. Bij geen match: stel een korte verhelderingsvraag, gok niet.

Genereer task-id: `<skill-prefix>-<YYYY-MM-DD>-<topic-slug>`. Voorbeelden:

- `blog-2026-05-21-toekomst-marketing-growthlab`
- `linkedin-2026-05-21-solopreneur-productiviteit`

Korter mag, uniek moet.

### 2. Task brief

Herschrijf de natuurlijke instructie tot een goede task brief voor de worker. Bevat:

- **Doel**: type deliverable, lengte, doelgroep
- **Bronnen**: verwijzingen naar `./brand-voice.md`, `./rules.md` van de workspace
- **Output-pad**: meestal `$CLAUDE_LAUNCHER_HOME/output/<datum>-<slug>.md`
- **Optioneel**: skills die hij moet aanroepen (blog-editor, output:docx, etc.)

De `.done`-instructie hoef je NIET zelf toe te voegen — `cockpit launch` doet dat automatisch. Maar als je wilt mag het wel.

### 3. Spawn

```bash
cockpit launch <task-id> --workspace clients/growthlab --inject "<brief>"
```

Bij parallel-spawn: meerdere `cockpit launch`-calls achter elkaar binnen één skill-activatie. Elke worker wordt zijn eigen pane rechts van de cockpit (auto-tile main-vertical).

### 4. Bevestiging aan gebruiker

Eén regel:

> "Spawn: `<task-id>` (workspace: `<ws>`). Ik kijk per 30s of een .done verschijnt."

Bij parallel:

> "Spawn 2 workers: `<task-id-1>`, `<task-id-2>`. Monitor draait."

### 5. Monitor op `.done` files

Direct na de spawn(s), start de monitor:

```
/loop 30s /cockpit-monitor
```

**Tijdseenheid is verplicht** — `30s`, `60s`, `1m`. NOOIT `/loop 30` zonder unit.

De `cockpit-monitor` skill checkt elke tick `~/.claude-launcher/output/*.done` tegen actieve task-ids uit de manifest. Bij elke nieuwe `.done` surface je naar de gebruiker.

### 6. Alle workers klaar?

Wanneer **alle** actieve task-ids een `.done`-bestand hebben:

1. Stop de loop: `/loop stop`
2. Surface een overzicht: "Beide workers klaar — `<task-id-1>`: <samenvatting>, `<task-id-2>`: <samenvatting>"
3. Vraag vervolgactie

Voor de parallel-clients demo (zie `docs/DEMO-PROMPT.md`): trigger automatisch de comparison-step zonder te vragen. Lees beide blog-bestanden, schrijf side-by-side vergelijking, print onder kop `## Demo-conclusie: zelfde prompt, andere wereld`.

## Vier harde regels

1. **Nooit `cockpit launch` direct via Bash zonder eerst deze skill te activeren.** Als de gebruiker iets vraagt dat een worker nodig heeft, activeer eerst deze skill.
2. **Nooit `--headless`** tenzij gebruiker er expliciet om vraagt.
3. **Nooit zelf de content schrijven** wat een worker hoort te schrijven. Geen blogs in de cockpit. Spawn een worker.
4. **Eén skill-activatie voor parallel spawnen** — daarbinnen sequenticeel meerdere `cockpit launch`.

## Voorbeeld-flow

```
Gebruiker: "spawn voor beide demo-clients een blog over de toekomst van marketing"

PM activeert (deze skill).

PM (intern):
  - routes.yaml lookup: "blog" → marketing/blog-writer
  - clients/growthlab + clients/studio-atlas (uit user-instructie)
  - task-id-1: blog-2026-05-21-toekomst-marketing-growthlab
  - task-id-2: blog-2026-05-21-toekomst-marketing-studio-atlas
  - brief: "Schrijf supporting article 1000-1500 woorden over de toekomst
            van marketing. Primair keyword 'toekomst marketing'. FAQ aan
            het eind. Lees ./brand-voice.md en ./rules.md eerst. Roep
            blog-editor aan voor publicatie."

PM (cockpit launch x 2):
  cockpit launch blog-2026-05-21-toekomst-marketing-growthlab \
    --workspace clients/growthlab --inject "<brief>"
  cockpit launch blog-2026-05-21-toekomst-marketing-studio-atlas \
    --workspace clients/studio-atlas --inject "<brief>"

PM (aan gebruiker):
  "Spawn 2 workers in panes rechts van de cockpit. Monitor draait."

PM (start /loop):
  /loop 30s /cockpit-monitor

PM (na ~5 min, beide .done's verschenen):
  "[growthlab] klaar: blog 1247w + editor PASS WITH NOTES"
  "[studio-atlas] klaar: blog 1283w + editor PASS"
  "Beide klaar. Ik schrijf nu de vergelijking..."

PM (leest beide blogs, schrijft comparison, print):
  ## Demo-conclusie: zelfde prompt, andere wereld
  ...
```

## Wat NIET doen

- Niet zelf schrijven wat een worker hoort te schrijven
- Niet meer dan 3 workers tegelijk zonder bevestiging
- Niet `--headless` toevoegen
- Niet rechtstreeks `tmux send-keys` of `tmux new-session` aanroepen
- Niet wachten op `cockpit msg done`-events. Wacht op de `.done` file
- Niet de comparison-step skippen bij de parallel-clients demo
