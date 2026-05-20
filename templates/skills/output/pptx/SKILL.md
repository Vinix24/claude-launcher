---
name: output-pptx
description: >
  Convert a slide outline (JSON or markdown with --- separators) into a PowerPoint (.pptx) deck.
  Use this skill when the user asks for a pitch deck, presentation, slides, or .pptx export.
  Triggers on: "pptx", "PowerPoint", "deck", "slides", "presentatie", "pitch deck".
---

# output:pptx — Outline to PowerPoint

Converteer een slide-outline naar een PowerPoint-deck met basis-layouts: titel-slide, content-slide met bullets, sectie-headers. Gebruikt `python-pptx` (MIT license).

Deze skill is **cross-cutting**: hij wordt aangeroepen vanuit elke workspace die een PowerPoint-deliverable nodig heeft. De skill genereert geen inhoud — die wordt door de calling-skill in een outline geleverd.

## Snelle aanroep

```bash
python3 scripts/outline2pptx.py <input.md> <output.pptx>
```

## Outline-formaat

Een markdown-bestand waarin elke slide gescheiden wordt door `---`:

```markdown
# Pitch deck: AI-impact op MKB-marketing

Auteur: Voornaam Achternaam
Datum: 2026-05-20

---

# Probleem

- Marketeers spenderen 60% van hun tijd aan herhalend werk
- Geen overzicht over parallel-AI-tabs
- Brand-voice consistentie kost mentaal werk

---

# Oplossing

- Eén centrale cockpit
- Vooraf geconfigureerde workspaces
- Natuurlijke instructies, directe oplevering

---

# Volgende stap

Plan een korte demo via [contact].
```

Regels:

- Eerste slide is altijd de titel-slide (`# Titel` + optionele meta-regels)
- Elke `---` start een nieuwe slide
- `# Titel` op een content-slide wordt slide-titel
- Bullets (`- ...`) worden bullet-content
- Paragrafen worden als bullet-paragrafen behandeld (max 5 bullets per slide is good practice)

## Workflow voor een worker

1. Schrijf de outline als markdown in `$CLAUDE_LAUNCHER_HOME/output/<basename>.outline.md`
2. Roep de converter aan:
   ```bash
   python3 ~/.claude-launcher/skills/output/pptx/scripts/outline2pptx.py \
     "$CLAUDE_LAUNCHER_HOME/output/<basename>.outline.md" \
     "$CLAUDE_LAUNCHER_HOME/output/<basename>.pptx"
   ```
3. Lever op:
   ```bash
   cockpit msg deliver $CLAUDE_LAUNCHER_HOME/output/<basename>.pptx --format pptx --bytes
   ```

## Slide-layouts

| Slide-type | Detectie | Layout |
|---|---|---|
| Title | Eerste slide met alleen `# Titel` + meta | Centered title + subtitle |
| Section header | `# Titel` zonder bullets | Section header layout |
| Content | `# Titel` + bullets | Title + content bullets |
| Closing | Laatste slide | Section header layout |

## Niet ondersteund in v0.0

- Afbeeldingen embedden (placeholder-tekst `[image: pad]` blijft als tekst)
- Tabellen
- Charts of grafieken
- Custom themes / branding (gebruikt de python-pptx default)
- Speaker notes

Voor v0.5+ overwegen, niet voor de demo.

## Dependencies

- Python 3.10+
- `python-pptx` (`pip3 install python-pptx`)

`install.sh` controleert beide.

## Output-locatie

Default: `$CLAUDE_LAUNCHER_HOME/output/<basename>.pptx`. Anders het pad dat als tweede argument is meegegeven.

## Voorbeelden van wanneer dit nuttig is

- Sales-pitch deck uit de sales-workspace
- Klant-demo-deck uit operations
- Interne kick-off-deck

## Wat NIET doen

- Geen inhoud genereren binnen deze skill
- Geen Anthropic SDK gebruiken — alleen `python-pptx`
- Geen externe assets fetchen (geen URLs, geen fonts downloaden)
