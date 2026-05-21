# claude-launcher

> Vijf experts in mijn cockpit. Eén instructie volstaat.

Een lichte orchestrator bovenop [Claude Code](https://docs.anthropic.com/claude/docs/claude-code). Eén centrale cockpit-sessie spawnt werkers in voor-geconfigureerde workspaces (marketing, sales, finance, etc.). Elke werker heeft domeinspecifieke skills en rapporteert resultaten terug via een NDJSON inbox-protocol.

Geen copy-paste tussen tabs. Geen brand-voice opnieuw uitleggen. Geen prompt-engineering-werk meer in je hoofd.

## Status

Dit is **v0.0** — een werkend prototype, geen polished product. Bewust rauwe randjes, bewust open source, bewust local-first. Mac-only voor nu.

## Hoe dit ontstaan is

claude-launcher is de oer-vorm van mijn eigen orchestratie-werk. Ik begon ooit met een handvol bash-scripts die Claude-sessies opspawnden in tmux-windows, zodat ik niet meer tussen browser-tabs hoefde te switchen. Die scripts groeiden uit tot iets serieus: [VNX Orchestration](https://github.com/Vinix24/vnx-orchestration), mijn governance-first runtime voor multi-agent productie-werk met audit-trail, SPC-grade quality gates, en NDJSON receipts.

VNX is het werkpaard. claude-launcher is de lichte voorganger: dezelfde mentale model (cockpit + workers + inbox), zonder de governance-overhead. Bedoeld voor solopreneurs, marketeers en kenniswerkers die geen 1.100+ receipts per week nodig hebben.

Als je serieuze productie-orchestratie wilt, kijk naar VNX. Als je gewoon wilt dat je content sneller af is zonder tabs-tetris, dit is je tool.

## Wat het wel doet

- Spawnt parallelle Claude Code-sessies in workspaces (`marketing` in v0.0)
- Routeert natuurlijke instructies naar de juiste skill via een routing-tabel
- Werkers schrijven blogs, LinkedIn-posts, marktonderzoeken
- Cross-cutting output-skills: markdown naar `.docx` (Word) en outline naar `.pptx` (PowerPoint)
- Volledig lokaal, MIT-license, geen cloud, geen telemetry

## Wat het NIET doet

- Geen enterprise-SSO, geen audit-trail. Kijk naar [VNX Orchestration](https://github.com/Vinix24/vnx-orchestration) als je dat nodig hebt.
- Geen perfectie. Dit is een prototype, geen productie-tool. Voor governance-grade orchestratie: zie VNX.
- Werkt nog niet op Windows. Mac alleen, voorlopig.
- Geen finance-, sales-, of operations-workspaces in v0.0. Die komen in v0.5+.

## Vereisten

- macOS
- tmux
- Python 3.10+
- Claude Code CLI (`claude`) — [installatie](https://docs.anthropic.com/claude/docs/claude-code)
- Een Anthropic-account met Claude Code-toegang

`install.sh` controleert alle dependencies en biedt installatie aan via Homebrew waar mogelijk.

## Auto-approve van Claude-tools

`cockpit start` en `cockpit launch` draaien standaard met `claude --dangerously-skip-permissions`. Dat betekent dat Claude in de cockpit (en in de werkers) zonder tussenkomst Bash, Edit en Write mag uitvoeren. Anders moet je elke `cockpit launch`-aanroep handmatig goedkeuren, wat de hele orchestratie breekt.

Wil je toch de standaard permission-prompts terug? Voeg `--require-permissions` toe:

```bash
cockpit start --require-permissions
cockpit launch <task-id> --workspace marketing --inject "..." --require-permissions
```

Veiligheid blijft jouw verantwoordelijkheid: workers krijgen volledige filesystem-toegang binnen hun workspace. Beoordeel zelf welke skills je in je workspace toelaat.

## Installatie

```bash
git clone https://github.com/Vinix24/claude-launcher.git
cd claude-launcher
./install.sh
```

Of in één regel:

```bash
curl -fsSL https://raw.githubusercontent.com/Vinix24/claude-launcher/main/install.sh | bash
```

Het script vraagt om bevestiging bij elke installatie-stap. Niets wordt geforceerd.

## Eerste run

1. **Vul je brand-voice in.** Edit `~/.claude-launcher/workspaces/marketing/brand-voice.md` met jouw stem, doelgroep en authority-punten. Hoe specifieker, hoe consistenter de output.

2. **Start de cockpit.**
   ```bash
   cockpit start
   ```
   Dit opent een Claude Code-sessie in `~/.claude-launcher/cockpit/`. De cockpit weet automatisch welke workspaces en skills beschikbaar zijn.

3. **Type een instructie in natuurlijke taal.** Bijvoorbeeld:
   > "schrijf een blog over AI-impact op MKB-marketing"

   De cockpit detecteert de intent, kiest de juiste workspace + skill, herschrijft de instructie, en spawn een werker in een aparte tmux-sessie.

4. **Volg de voortgang** (optioneel automatisch):
   ```
   /loop 1m /cockpit-monitor
   ```
   Elke 60 seconden checkt de cockpit de inbox en surfaced relevante events (vragen, oplevering, errors).

5. **Werker is klaar.** Output staat in `~/.claude-launcher/output/`.

## De demo: één prompt, twee compleet verschillende blogs

`install.sh` zet standaard twee voorbeeld-klantworkspaces neer:

- **GrowthLab** — fictief performance marketing bureau, cijfers-eerst, B2B SaaS
- **Studio Atlas** — fictieve brand consultancy, klassiek Nederlands, verhalend

Dezelfde prompt naar beide spawnen → twee compleet andere blogs. Niet door slimme prompting, door eigen `CLAUDE.md` + `brand-voice.md` + `rules.md` per workspace.

Start `cockpit start` en plak deze prompt:

```
Draai de parallel-clients demo:

1. Spawn twee blog-workers gelijktijdig, een per demo-client:
   - workspace clients/growthlab
   - workspace clients/studio-atlas

   Identieke prompt voor beide (woord-voor-woord hetzelfde, geen
   client-specifieke hints):

   "Schrijf een supporting article van 1000-1500 woorden over
    'de toekomst van marketing', primair keyword 'toekomst marketing',
    FAQ-sectie aan het eind. Roep de blog-editor aan voor publicatie.
    Sla op in $CLAUDE_LAUNCHER_HOME/output/."

2. Geen --headless. Ik wil beide terminal-vensters (iTerm of Terminal.app) zien opengaan.

3. Wacht tot beide workers 'done' rapporteren via de inbox.

4. Als beide done zijn:
   a. Lees beide blog-bestanden uit ~/.claude-launcher/output/
   b. Maak een side-by-side vergelijking met aandacht voor:
      - Openingszin (hook-stijl en lengte)
      - Woordkeus en jargon-gebruik
      - Zinsritme en alinea-lengte
      - Authority-punten die elke client heeft gebruikt
      - Gebruik van em-dashes, vraagtekens, uitroeptekens
      - Stijl van de CTA aan het eind
      - Concrete passages die de tegenstelling het sterkst tonen
   c. Print de conclusie hier in de cockpit onder de kop
      "## Demo-conclusie: zelfde prompt, andere wereld"
   d. Sla de vergelijking op in
      $CLAUDE_LAUNCHER_HOME/output/YYYY-MM-DD-demo-vergelijking.md

5. Lever drie artefacten op: blog GrowthLab, blog Studio Atlas,
   vergelijkings-rapport. Vraag of ik ze wil openen.
```

Verwacht resultaat: twee nieuwe terminal-vensters openen met de workers (iTerm als je dat gebruikt, anders Terminal.app), na 4-7 minuten zie je de demo-conclusie in je cockpit-terminal. Drie deliverables in `~/.claude-launcher/output/`.

Volledige uitleg, varianten en troubleshooting in **[docs/DEMO-PROMPT.md](docs/DEMO-PROMPT.md)**.

## CLI-overzicht

```bash
cockpit start                                      # open cockpit
cockpit launch <task-id> --workspace <ws> --inject "<prompt>"
cockpit status                                     # actieve workers
cockpit attach <task-id>                           # kijk in een werker
cockpit kill <task-id> [--all]                     # stop een werker
cockpit msg <type> ...                             # worker-side inbox event
```

`cockpit msg` wordt door werkers gebruikt om events te rapporteren:

```bash
cockpit msg status "outline klaar"
cockpit msg question "lengte 900 of 1500 chars?" --options "900,1500"
cockpit msg deliver ~/.claude-launcher/output/2026-05-20-blog.md --format markdown
cockpit msg done "blog klaar, 1247 woorden"
cockpit msg error "iets ging mis" --blocking
```

## Beschikbare skills in v0.0

### Workspace: marketing

| Skill | Wat doet het |
|---|---|
| `blog-writer` | SEO-blog 600-3000 woorden, markdown met frontmatter |
| `linkedin-writer` | LinkedIn-post (text-only, carousel, of image brief) |
| `marktonderzoeker` | Doelgroepprofiel, kooptriggers, bezwaren |

### Cross-cutting output

| Skill | Wat doet het |
|---|---|
| `output:docx` | Markdown naar Word-document via `python-docx` |
| `output:pptx` | Outline naar PowerPoint via `python-pptx` |

## Mapstructuur na install

```
~/.claude-launcher/
├── cockpit/                  # Claude Code dir voor de centrale sessie
│   ├── CLAUDE.md             # rol van de cockpit
│   ├── routes.yaml           # intent-naar-skill mapping
│   └── .claude/skills/       # cockpit-dispatch, cockpit-monitor
├── workspaces/
│   └── marketing/
│       ├── CLAUDE.md         # workspace-context + inbox-protocol
│       ├── brand-voice.md    # JOUW stem (vul zelf in)
│       └── .claude/skills/   # blog-writer, linkedin-writer, marktonderzoeker
├── skills/output/
│   ├── docx/                 # markdown -> docx converter
│   └── pptx/                 # outline -> pptx converter
├── inbox/                    # NDJSON events per task-id
├── output/                   # alle deliverables
├── bin/cockpit               # CLI (gesymlinkt naar ~/.local/bin)
├── lib/inbox.py              # event-writer helper
└── manifest.json             # actieve workers
```

## Roadmap (geen belofte)

- **v0.5**: sales-, finance-, content-workspaces. First-run wizard. Brew tap. Skill-marketplace.
- **v1.0**: operations + personal workspaces. Desktop-wrapper. PDF + Excel output. Gedeelde workspaces via git-sync.

Wat het waarschijnlijk **nooit** wordt: een cloud-tool, een SaaS, een enterprise-product. Voor governance-grade orchestratie: [VNX Orchestration](https://github.com/Vinix24/vnx-orchestration).

## Bijdragen

PRs welkom. Zie [CONTRIBUTING.md](CONTRIBUTING.md). Skill-suggesties via issues, niet via PRs — laat me eerst de fit beoordelen.

## License

MIT. Zie [LICENSE](LICENSE).

## Auteur

Vincent van Deth. AI-architect voor het MKB. Open source: [github.com/Vinix24](https://github.com/Vinix24). Werk: [vincentvandeth.nl](https://vincentvandeth.nl).
