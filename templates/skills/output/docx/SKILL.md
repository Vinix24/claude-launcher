---
name: output-docx
description: >
  Convert markdown content into a clean Word (.docx) document with basic styling.
  Use this skill when the user asks for a Word document, .docx export, factuur,
  contract, NDA, proposal, brief, or wants to convert generated markdown to docx.
  Triggers on: "docx", "Word", "factuur", "contract", "NDA", "voorstel", "brief", "rapport als Word".
---

# output:docx — Markdown to Word

Converteer markdown naar een Word-document met basis-styling: H1/H2/H3, paragrafen, bullets, genummerde lijsten, bold en italic. Gebruikt `python-docx` (MIT license).

Deze skill is **cross-cutting**: hij wordt aangeroepen vanuit elke workspace die een Word-deliverable nodig heeft (marketing, sales, finance, operations). De skill bemoeit zich niet met de inhoud — die wordt door de calling-skill in markdown geleverd. Hier zit alleen de conversie.

## Snelle aanroep

```bash
python3 scripts/md2docx.py <input.md> <output.docx>
```

Voor de cockpit-pipeline: laat een worker eerst de inhoud in markdown schrijven, dan deze converter aanroepen, dan `cockpit msg deliver <pad>.docx --format docx`.

## Workflow voor een worker

1. Schrijf de inhoud als markdown-bestand in `$CLAUDE_LAUNCHER_HOME/output/<basename>.md`
2. Roep de converter aan:
   ```bash
   python3 ~/.claude-launcher/skills/output/docx/scripts/md2docx.py \
     "$CLAUDE_LAUNCHER_HOME/output/<basename>.md" \
     "$CLAUDE_LAUNCHER_HOME/output/<basename>.docx"
   ```
3. Lever beide op:
   ```bash
   cockpit msg deliver $CLAUDE_LAUNCHER_HOME/output/<basename>.md --format markdown
   cockpit msg deliver $CLAUDE_LAUNCHER_HOME/output/<basename>.docx --format docx --bytes
   ```

## Ondersteunde markdown-elementen

| Element | Markdown | Resultaat in docx |
|---------|----------|-------------------|
| H1 | `# Titel` | Heading 1 stijl |
| H2 | `## Subtitel` | Heading 2 stijl |
| H3 | `### Sub-subtitel` | Heading 3 stijl |
| Paragraaf | tekst | Body paragraph |
| Bold | `**tekst**` | Bold run |
| Italic | `*tekst*` | Italic run |
| Bullet | `- item` of `* item` | Genummerd bullet |
| Numbered list | `1. item` | Genummerd item |
| Horizontale lijn | `---` | Pagina-break of separator |

Niet ondersteund in v0.0 (markdown wordt letterlijk overgenomen): tabellen, code-blokken met syntax highlighting, afbeeldingen, hyperlinks. Voeg toe in v0.5+ als de behoefte er is.

## Frontmatter

YAML-frontmatter aan het begin van het markdown-bestand wordt overgeslagen. Dat is bewust: blogs hebben frontmatter die niet in de docx hoort.

## Dependencies

- Python 3.10+
- `python-docx` (`pip3 install python-docx`)

`install.sh` controleert beide.

## Output-locatie

Default: `$CLAUDE_LAUNCHER_HOME/output/<basename>.docx`. Anders het pad dat als tweede argument is meegegeven.

## Voorbeelden van wanneer dit nuttig is

- Factuur uit een finance-workspace
- NDA of contract uit een operations-workspace
- Proposal uit een sales-workspace
- Pillar-page-export voor een klant die geen markdown wil
- Klantrapport, audit-rapport, of meeting-notes

## Wat NIET doen

- Niet inhoud genereren binnen deze skill (dat is de calling-skill zijn werk)
- Geen bestaande docx-bestanden bewerken (overschrijven mag, in-place editen niet)
- Geen Anthropic SDK gebruiken — alleen `python-docx`
