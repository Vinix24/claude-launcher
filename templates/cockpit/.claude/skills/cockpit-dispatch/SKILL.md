---
name: cockpit-dispatch
description: >
  Route a natural-language user instruction to the right workspace + skill,
  rewrite the prompt for clarity, and spawn a worker via cockpit launch.
  Trigger on EVERY user instruction in the cockpit that asks for content or a deliverable.
---

# cockpit-dispatch

Je classificeert een gebruiker-instructie, bepaalt de juiste workspace en skill, herschrijft de instructie tot een goed gestructureerde prompt voor de worker, en spawn die worker.

## Stappen

### 1. Lees de routing-tabel

```bash
cat ~/.claude-launcher/cockpit/routes.yaml
```

Of indien daar afwezig: `routes.yaml` in dezelfde folder als deze skill.

### 2. Classificeer intent

- Zoek `intent_keywords` die overeenkomen met de user-instructie (case-insensitive)
- Bij meerdere matches: kies de specifiekere (langste exact-match wint)
- Bij geen match: gebruik `fallback.action` (in v0.0 is dat `ask_clarification`)

### 3. Genereer een task-id

- Format: `<skill-prefix>-<YYYY-MM-DD>-<kort-onderwerp>` of `<skill-prefix>-<XXX>` met een nummer
- Voorbeelden: `blog-2026-05-20-ai-mkb`, `linkedin-2026-05-20-solopreneur`, `marktonderzoek-saas`
- Voorkom collisies: check `cockpit status` of de id al draait

### 4. Herschrijf de prompt

Maak de natuurlijke instructie expliciet. Voeg toe:

- **Doel + format**: "Schrijf een [type] van [lengte] over [topic]"
- **Doelgroep**: leid af uit de instructie of vraag het
- **Brand-voice referentie**: "Lees eerst `~/.claude-launcher/workspaces/<ws>/brand-voice.md` voor stem"
- **Output-locatie**: `$CLAUDE_LAUNCHER_HOME/output/YYYY-MM-DD-<slug>.<ext>`
- **Inbox-protocol**: "Lever op via `cockpit msg deliver <pad>` en `cockpit msg done <samenvatting>`"
- **Output-format**: indien gespecificeerd door route (docx, pptx) of door user

Houd de prompt onder 1500 chars — beter compact dan uitgebreid.

### 5. Spawn de worker

```bash
cockpit launch <task-id> \
  --workspace <workspace> \
  --inject "<herschreven-prompt>"
```

### 6. Bevestig aan de gebruiker

Eén zin:

> "Spawn `<task-id>` (workspace: `<ws>`, skill: `<skill>`). Status volgt zodra de worker meldt."

## Bij ambiguïteit

Gok niet. Stel een korte vraag:

> "Bedoel je [optie A] of [optie B]?"

Specifieke ambiguïteiten in v0.0:

- "schrijf iets over X" zonder format -> vraag: blog, LinkedIn-post, of marktonderzoek?
- "maak een deck" -> vraag: voor welke doelgroep, hoeveel slides ongeveer?
- "factuur" / "contract" -> v0.0 nog niet geïmplementeerd (finance/operations workspaces komen in v0.5+). Meld dat eerlijk.

## Output-skill chaining

Als de route een `output_format` heeft (zoals `pptx`):

1. Spawn eerst de inhoud-worker (bv. marketing/linkedin-writer)
2. Wacht op `done` event
3. Spawn een vervolg-worker die de output-skill aanroept op het geleverde markdown
4. Of: instrueer de eerste worker zelf het output-script aan te roepen na zijn markdown

In v0.0: kies de simpelere route (eerste worker doet beide stappen). Geef die instructie expliciet mee in de prompt.

## Wat NIET doen

- Niet zelf de inhoud schrijven (je orchestreert, je executeert niet)
- Niet meer dan 3 workers tegelijk spawnen zonder de gebruiker te vragen
- Niet gokken bij intent: vraag liever
- Niet hardcoderen welke skill: lees `routes.yaml`
