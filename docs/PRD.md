# claude-launcher — Product Requirements Document

| | |
|---|---|
| **Status** | Draft v0.1 |
| **Auteur** | Vincent van Deth |
| **Datum** | 2026-05-19 |
| **Repo (gepland)** | `github.com/Vinix24/claude-launcher` (MIT) |
| **Werk-titel** | claude-launcher / Claude Cockpit |
| **Doelgroep** | Marketeers, ondernemers, consultants en andere kenniswerkers die parallel met meerdere AI-sessies werken |

---

## 1. Executive summary

Eén centrale Claude Code-sessie (de cockpit) waarvan ik via natuurlijke staccato-zinnen werkers spawn in voor-geconfigureerde workspaces. Elke werker heeft domeinspecifieke skills (marketing, sales, finance, etc.) en rapporteert resultaten terug naar de cockpit via een inbox-protocol. Geen copy-paste tussen tabs meer, geen prompt-herhaal-werk, één opus-punt voor alles.

Pitch in één zin: "Vijf experts in mijn cockpit. Eén instructie volstaat."

---

## 2. Probleem

De gemiddelde power-gebruiker heeft 3-8 AI-tabs open: één voor blog, één voor sales-mail, één voor financiële vraag, één voor Slack-bericht-helper. Drie pijnpunten:

1. **Context-switching kost mentaal energie** — elke tab heeft eigen geschiedenis + system prompt + brand-voice die ik mentaal moet bijhouden.
2. **Prompt-herhaal-werk** — bij elke nieuwe sessie typ ik dezelfde toon, dezelfde voorbeelden, dezelfde formaten opnieuw.
3. **Geen overzicht** — welke tab is klaar, welke wacht op input, welke heeft een vraag? Onmogelijk te tracken in N browser-tabs.

Bestaande oplossingen voor parallel-AI:
- ChatGPT projects: alleen één model, één UI, geen tool-use, geen file-output
- Claude.ai projects: idem, geen filesystem-toegang
- VNX Orchestration: te zwaar, voor developers, governance-first
- N losse Claude Code-sessies: werkt maar geen orchestratie

Gap: een lichte orchestrator voor niet-developers die wel Claude Code-power willen.

---

## 3. Oplossing in één plaatje

```
┌──────────────────────────────────────────────────────────────┐
│  COCKPIT — één Opus 4.7 sessie in primaire iTerm-tab         │
│                                                                │
│  Jij:    "Schrijf blog over AI-impact op MKB-marketing"       │
│  ↓                                                            │
│  Cockpit's cockpit:dispatch skill:                            │
│    • intent classify  → blog-creatie                          │
│    • workspace match  → marketing                             │
│    • skill match      → blog-writer                           │
│    • prompt rewrite   → 800w, brand-voice, 3 voorbeelden, ... │
│  ↓                                                            │
│  cockpit launch blog-001 \                                    │
│    --workspace marketing \                                    │
│    --inject "/blog-writer <rewritten>"                        │
└─────────────────────────────┬────────────────────────────────┘
                              │
        ┌─────────────────────┴────────────────────┐
        │ TMUX-WINDOW: workspaces/marketing/        │
        │   Claude Code, Sonnet, .claude/skills/    │
        │   /blog-writer fires + uitvoering        │
        │                                           │
        │ Worker rapporteert via                   │
        │ ~/.claude-launcher/inbox/blog-001.ndjson:│
        │   {"type":"status","content":"outline OK"}│
        │   {"type":"status","content":"draft 80%"} │
        │   {"type":"done","artifact":"...md"}     │
        └─────────────────────┬────────────────────┘
                              │
┌─────────────────────────────┴────────────────────────────────┐
│  COCKPIT's /loop 60s polled inbox, surfaced aan jou:         │
│  "Blog klaar (1247w, 4 min). Open? Edit? Export naar docx?"  │
└──────────────────────────────────────────────────────────────┘
```

---

## 4. Doelgroep en persona's

### Primair (v0.0 → v1.0)

| Persona | Wat ze elke dag doen | Waarom dit hen helpt |
|---|---|---|
| **Solo marketeer** | Blogs, LinkedIn-posts, email-sequences, brand-voice consistency | Eén cockpit voor alles, brand-voice in workspace-skills geborgd |
| **MKB-ondernemer** | Sales-mail, facturen, vendor-research, weekend-planning | Meerdere petten, één tool, geen tab-chaos |
| **Consultant / freelancer** | Proposals, klant-research, factuurherinneringen, content | Klantcontext per workspace, herbruikbare skill-templates |

### Secundair (v0.5+)

| Persona | Notitie |
|---|---|
| Solopreneur in product-fase | Marketing + sales + light coding (apart workspace) |
| Kleine team-leider | 2-3 mensen, gedeelde workspaces via git-sync (v1.5+) |

### Anti-doelgroep (expliciet niet)

- Developers die VNX-style governance willen (gebruik VNX)
- Enterprises met SSO/IAM-vereisten (gebruik enterprise-tools)
- Mensen die nooit een terminal openen (v0.0 vereist comfort met iTerm; desktop-wrapper komt v1.0)

---

## 5. Architectuur

### 5.1 Componenten

```
~/.claude-launcher/                # User-data + runtime state
├── workspaces/                    # Pre-configured role-folders
│   ├── marketing/
│   ├── content/
│   ├── sales/
│   ├── finance/
│   ├── operations/
│   └── personal/
├── inbox/                         # Per-task NDJSON files
│   ├── blog-001.ndjson
│   └── invoice-002.ndjson
├── output/                        # Worker-deliverables
│   ├── 2026-05-19-ai-mkb.md
│   ├── 2026-05-19-pitch.pptx
│   └── 2026-05-19-invoice-acme.docx
├── manifest.json                  # Welke tmux-sessies draaien
└── config.yaml                    # User-preferences
```

### 5.2 Cockpit-process

- Eén Claude Code-sessie in primair iTerm-venster
- Opus 4.7 (de duurste lane, want eindbeslisser)
- Heeft `cockpit:*` skills geladen via `~/.claude-launcher/cockpit/CLAUDE.md`
- Draait `/loop 60s` voor inbox-polling
- Houdt manifest van actieve workers bij

### 5.3 Worker-process

- Eén Claude Code-sessie per task in eigen tmux-window
- Sonnet 4.6 default (goedkoper, snel genoeg voor uitvoer)
- Heeft workspace-specifieke skills via `workspaces/<name>/.claude/skills/`
- CLAUDE.md per workspace bevat rol-context + inbox-protocol-instructie
- Schrijft status naar inbox via `cockpit msg <type> <text>` CLI
- Output-bestanden in `~/.claude-launcher/output/<task-id>.<ext>`

### 5.4 Inbox-protocol

Eén NDJSON-file per task: `~/.claude-launcher/inbox/<task-id>.ndjson`

Event-types:

```json
{"ts":"2026-05-19T16:01:23Z","type":"status","content":"Outline klaar"}
{"ts":"...","type":"question","content":"Welke lengte: 600 of 1200w?","options":["600","1200"]}
{"ts":"...","type":"deliverable","artifact":"output/2026-05-19-ai-mkb.md","format":"markdown"}
{"ts":"...","type":"done","summary":"Blog klaar, 1247 woorden, brand-voice gecheckt"}
{"ts":"...","type":"error","content":"...","blocking":true}
```

Worker-side CLI om dit makkelijk te maken:

```bash
cockpit msg status "..."
cockpit msg question "..." --options "A,B,C"
cockpit msg deliver "<path>" --format docx
cockpit msg done "<summary>"
```

### 5.5 Cockpit-skills (de brain)

Drie kern-skills in `~/.claude-launcher/cockpit/skills/`:

| Skill | Functie |
|---|---|
| `cockpit:dispatch` | Classificeer intent → workspace/skill match → herschrijf prompt → spawn worker |
| `cockpit:monitor` | Poll alle actieve inboxes, surface relevante events (vooral `question` en `done`) |
| `cockpit:followup` | Bij `done` of `question` van worker: vraag user om vervolgactie of paste new prompt |

Plus één gedeelde routing-table in `~/.claude-launcher/cockpit/routes.yaml`:

```yaml
routes:
  - intent_keywords: [blog, artikel, longform, post-blog]
    workspace: marketing
    skill: blog-writer
  - intent_keywords: [linkedin, post, sociale, social-media]
    workspace: marketing
    skill: linkedin-post
  - intent_keywords: [email, mail-sequence, drip]
    workspace: marketing
    skill: email-sequence
  - intent_keywords: [factuur, invoice]
    workspace: finance
    skill: invoice-generator
  - intent_keywords: [cashflow, prognose, forecast]
    workspace: finance
    skill: cashflow-reporter
  - intent_keywords: [prospect, lead-research]
    workspace: sales
    skill: prospect-research
  - intent_keywords: [voorstel, proposal, offerte]
    workspace: sales
    skill: proposal-writer
  - intent_keywords: [pitch, presentatie, deck]
    workspace: marketing  # of presentations als aparte ws
    skill: pitch-deck
    output: pptx
  - intent_keywords: [contract, NDA, voorwaarden]
    workspace: operations
    skill: legal-template
    output: docx
```

Bij ambiguïteit: cockpit vraagt user te clarifiseren in plaats van te gokken.

---

## 6. Workspaces — initieel zes

### 6.1 marketing

**Doel**: alle outbound communicatie van een ondernemer of marketeer.

| Skill | Output |
|---|---|
| `blog-writer` | Markdown blog 600-1500w, brand-voice toegepast |
| `linkedin-post` | Korte/lange LinkedIn-post met hook + CTA |
| `email-sequence` | 3-7 mails drip met escalerende CTAs |
| `pitch-deck` | PowerPoint via pptx-skill, ~10 slides |
| `brand-voice-applier` | Cross-cutting: pas tone-of-voice toe op tekst |

`CLAUDE.md`: rol-context (positionering, doelgroep, no-buzzwords-regels uit user's `~/.claude/rules/anti-ai-tics.md` + `voice-profile.md`).

### 6.2 content

**Doel**: long-form en multi-format content-werk.

| Skill | Output |
|---|---|
| `blog-outline` | H2/H3-structuur + key-points |
| `video-script` | YouTube/short script met tijd-stempel-cues |
| `newsletter` | Newsletter-section met hook + 3-5 punten |
| `social-thread` | Twitter/X-thread 5-12 tweets |
| `summarize-source` | Boek/artikel/podcast → 1-page summary |

### 6.3 sales

**Doel**: prospecting tot deal-close.

| Skill | Output |
|---|---|
| `prospect-research` | LinkedIn + website + nieuws → ICP-fit rapport |
| `proposal-writer` | Offerte/voorstel-doc met scope + pricing + timing |
| `follow-up-email` | Slimme follow-up na meeting/proposal |
| `objection-handler` | Antwoord op standaard bezwaren, brand-voice |
| `meeting-prep` | Voorbereiding voor sales-call: doel + vragen + risico's |

### 6.4 finance

**Doel**: financiële admin voor ZZP/MKB.

| Skill | Output |
|---|---|
| `invoice-generator` | Factuur via docx-skill, BTW-NL conform |
| `cashflow-reporter` | Maand/kwartaal-cashflow uit transacties |
| `expense-categorizer` | CSV/bankafschriften → categorieën |
| `tax-prep-helper` | NL BTW-aangifte voorbereiding (geen advies, alleen prep) |
| `quote-calculator` | Project-quote met uurprijs + marge |

### 6.5 operations

**Doel**: admin, meetings, vendors, contracten.

| Skill | Output |
|---|---|
| `meeting-summarizer` | Notes/transcript → action-items + decisions |
| `sop-writer` | Standard Operating Procedure document |
| `vendor-research` | Tool/leverancier vergelijking met scorecard |
| `legal-template` | NDA/contract/voorwaarden via docx-skill |
| `weekly-review` | Reflectie + planning voor komende week |

### 6.6 personal

**Doel**: privé-leven dat overlap heeft met productiviteit.

| Skill | Output |
|---|---|
| `travel-planner` | Reis-itinerary met budget + boekings-tips |
| `recipe-meal-plan` | Weekmenu + boodschappenlijst |
| `reading-summarizer` | Boek/artikel → key-takeaways + actions |
| `habit-tracker-review` | Week/maand habit-reflectie |

Personal is laatste in shipping-volgorde, eerst de zakelijke vijf.

### 6.7 Cross-cutting output-skills

Beschikbaar voor alle workspaces, via shared `~/.claude-launcher/cockpit/skills/output/`:

| Skill | Library | Wat doet hij |
|---|---|---|
| `output:docx` | `python-docx` | Markdown/tekst → Word-document met basic styling |
| `output:pptx` | `python-pptx` | Outline/JSON → PowerPoint deck met slide-layouts |
| `output:pdf` | `weasyprint` | Markdown → PDF (v0.5+) |
| `output:xlsx` | `openpyxl` | Data → Excel met formules en styling (v0.5+) |

Workers verwijzen ernaar via instructie: "schrijf eerst de inhoud in markdown, dan call `output:docx <markdown> <doelpad>`". Cockpit kan op basis van intent een output-format mee-routen ("maak een pitch over X" → `pptx`).

---

## 7. De killer demo-flow (LinkedIn-video)

90-seconden script:

1. **Sec 0-5**: Splash. "Vijf experts in mijn cockpit. Eén instructie volstaat."
2. **Sec 5-15**: Cockpit-terminal in beeld. Ik type: "Schrijf een blog over AI-impact op MKB-marketing voor LinkedIn".
3. **Sec 15-25**: Cockpit "denkt zichtbaar" — toont routing-besluit. tmux split-screen opent rechts.
4. **Sec 25-50**: Worker in marketing-workspace begint te werken. Status updates flikkeren langs in cockpit. Outline → draft → done.
5. **Sec 50-60**: Cockpit surfaced: "Blog klaar, 1247 woorden". Ik type: "perfect, maak er ook een pptx-pitch deck van".
6. **Sec 60-75**: Nieuwe worker start. PowerPoint wordt gegenereerd, geopend in Keynote.
7. **Sec 75-90**: Beide outputs in beeld. Tekst: "Open source. MIT. github.com/Vinix24/claude-launcher. Setup: 30 seconden."

Visueel sterk omdat het ECHT gebeurt, geen mockup.

---

## 8. Onboarding

### 8.1 Install (v0.5+)

```bash
# Homebrew (primaire route)
brew tap vinix24/claude-launcher
brew install claude-launcher

# Of curl-eenvouder
curl -fsSL https://claude-launcher.vincentvandeth.nl/install.sh | bash
```

Installeert: cockpit-CLI, `~/.claude-launcher/` tree, alle workspaces, alle skills, tmux dependency-check.

### 8.2 First-run wizard (v0.5+)

```
$ claude-launcher setup

Welkom bij Claude Launcher.

Welke workspaces wil je activeren?
  [x] marketing
  [x] content
  [x] sales
  [ ] finance       (kun je later aanzetten)
  [ ] operations
  [ ] personal

OK. 3 workspaces geïnstalleerd in ~/.claude-launcher/workspaces/.

Test-run: ik open nu een cockpit-sessie en spawn een worker
die "hello world from blog-writer" produceert.
Doorgaan? [y/N]
```

### 8.3 Dagelijks gebruik (v0.0+)

```
$ claude-launcher start
# opent iTerm-tab met cockpit-Claude in ~/.claude-launcher/cockpit/

Cockpit: "Klaar voor instructies."

Jij: "schrijf linkedin-post over de productiviteit van solopreneurs"
```

---

## 9. Phased delivery

### v0.0 — Demo-quality (3-4 dagen)

**Doel**: postable LinkedIn-demo. Validatie van de novelty.

| Onderdeel | Geschat werk |
|---|---|
| Launcher script (klaar als kiem) + msg-CLI + inbox-NDJSON | 0.5 dag |
| Cockpit CLAUDE.md + 1 dispatch-skill | 1 dag |
| `marketing` workspace + 2 skills (blog-writer, linkedin-post) | 1 dag |
| `output:docx` cross-cutting skill | 0.5 dag |
| README + 90-sec demo-video + LinkedIn-post draft | 0.5 dag |
| Buffer | 0.5 dag |

**Niet in v0.0**: install-script, wizard, andere workspaces, pptx, desktop-wrapper.

### v0.5 — Aangevuld (1 week vervolg)

| Onderdeel |
|---|
| Workspaces: sales, finance, content |
| `output:pptx` skill |
| Brew + curl install-routes |
| First-run wizard |
| Manifest-cleanup (`cockpit kill --all`) |

### v1.0 — Vol product (2 weken vervolg)

| Onderdeel |
|---|
| Operations + personal workspaces |
| Desktop-wrapper (pywebview) voor non-terminal |
| Skill-marketplace-overzicht |
| `output:pdf` + `output:xlsx` |
| Gedeelde workspaces via git-sync (early) |

Totale time-to-v1.0: ~3.5 weken cumulatief werk.

---

## 10. Technische specs

### 10.1 Stack

| Component | Keuze | Reden |
|---|---|---|
| Cockpit-shell | tmux | Bestaande gebruikers kennen het, robuust, scriptbaar |
| CLI taal | Bash + Python | Bash voor tmux-glue, Python voor skills/output-generatie |
| Config-format | YAML | Lezbaar voor gebruikers, makkelijk te editen |
| Skill-format | Standaard Claude Code SKILL.md | Volledig compatibel, geen eigen format |
| Output-libs | `python-docx`, `python-pptx`, `weasyprint`, `openpyxl` | MIT/BSD, stable, geen Anthropic SDK |
| Package-manager | Homebrew + curl-installer | Macos-first; brew is industrie-standaard |
| OS-support v0.x | macOS only | Marketeers + ondernemers zijn vooral op Mac. Linux v1.x. |
| **Hard constraint** | **Geen Anthropic SDK** | Per user's `no-anthropic-sdk` rule — alleen `claude` CLI subprocess |

### 10.2 Performance-eisen

- Cockpit-start: < 5 seconden van `claude-launcher start` tot input-prompt
- Worker-spawn: < 10 seconden van staccato-instructie tot worker-Claude-input-prompt
- Inbox-poll-latency: < 2 seconden tussen worker-msg en cockpit-surface
- Output-generation (docx/pptx): < 30 seconden voor doc onder 10 pagina's

### 10.3 Security/privacy

- **100% local-first**: geen cloud-backend, geen telemetry, geen tracking
- Workspaces zijn user-eigendom in `~/.claude-launcher/` — git-init'd zodat ze versioneerbaar zijn
- Workers gebruiken user's eigen Anthropic-subscription via `claude` CLI
- Geen API-keys hardcoded, geen .env-files in repo

### 10.4 TOS-positie (eerlijke disclosure)

Per user's eigen analyse en VNX-precedent:

- **OK**: operator-present pattern (jij zit in cockpit, geeft elke dispatch handmatig). Multi-pane interactive Claude Code is precies waar Anthropic die subscription voor verkocht.
- **Grijs**: continuous loop zonder operator (cron-driven cockpit). claude-launcher gaat niet die kant op; cockpit is altijd interactief.
- **Hard NO**: geen Anthropic-SDK gebruik, alleen `claude` CLI subprocess. Conform user's `no-anthropic-sdk` constraint.

In README + setup-wizard duidelijk maken: "Dit is een operator-tool. Je bent altijd aan de knoppen."

---

## 11. Risks & mitigations

| Risico | Impact | Mitigatie |
|---|---|---|
| Niet-developers vinden tmux/terminal te alien | Hoog | v1.0 desktop-wrapper. v0.x duidelijk in README dat het terminal-comfort vereist. |
| Skill-kwaliteit middelmatig bij snel uitrollen | Hoog | v0.0 ship 2 polished skills, niet 24 stubs. Kwaliteit boven dekking. |
| Claude Code rate-limits bij parallelle workers | Mid | Standaard max 3 workers parallel. Wachtrij voor 4e+. Configureerbaar. |
| Anthropic positioneert zelf "managed agents"-product | Mid | Differentieer: claude-launcher is solopreneur-tool, niet enterprise. Open source + lokaal blijft sterk. |
| Skill-PR's van community zijn van wisselende kwaliteit | Mid | CONTRIBUTING.md met kwaliteitscriteria. Maintainer-review verplicht. |
| Inbox-NDJSON corruptie bij crash | Laag | Atomic file-writes via tmp+rename. Cockpit valideert JSON bij lezen. |

---

## 12. Anti-goals (expliciet NIET bouwen)

- ❌ Audit-trail / governance / SPC-metrics (= VNX-territorium)
- ❌ Multi-track T0/T1/T2/T3 hiërarchie (= VNX-pattern)
- ❌ PR-tracked governance (= VNX-pattern)
- ❌ Eigen LLM-routing / multi-provider (= LiteLLM/OpenRouter doen dit beter)
- ❌ Database-backed state (= NDJSON + filesystem volstaan)
- ❌ Enterprise IAM/SSO/RBAC (= verkeerde doelgroep)
- ❌ Cloud-hosted backend (= local-first principe)
- ❌ Telemetry of usage-tracking (= privacy + brand)

Bij twijfel: "Is dit iets dat een solo marketeer of MKB-ondernemer wil?" → Ja: bouw. Nee: skip.

---

## 13. Success metrics

### v0.0 (LinkedIn-validatie)

- LinkedIn-post haalt > 5.000 impressies in 7 dagen
- > 50 comments/reacties op de post
- > 100 GitHub-stars in 30 dagen
- > 10 issues/PR's van community
- 1 inkomende klantvraag voor VNX of consulting via deze post

### v0.5 (adoptie)

- > 500 GitHub-stars
- > 50 unique installations (telemetry-vrije meting via download-count Brew tap)
- > 5 externe skill-PR's gemerged
- > 1 testimonial van een marketeer die het dagelijks gebruikt

### v1.0 (product-market-fit indicatoren)

- > 1.000 GitHub-stars
- > 200 active users (Brew analytics)
- > 20 community-skills gemerged
- Genoemd in 2+ AI-newsletters / podcasts

---

## 14. Open vragen voor latere review

1. **Naam definitief**: claude-launcher, Claude Cockpit, Captain's Chair, Bridge, anders?
2. **Workspace-namen**: blijven Engels (`marketing`/`finance`) of Nederlands (`marketing`/`financien`)? Nederlands sluit beter aan bij doelgroep maar maakt de repo minder internationaal.
3. **v0.0 workspace-keuze**: alleen `marketing` met 2 skills, of `marketing` + `sales` met 2 skills elk? Eerste is sneller, tweede sterker als demo.
4. **Skill-format**: precies de Claude Code SKILL.md-standaard, of eigen format met meta-velden (cost-est, model-pref, etc.)? Eerste is hergebruikbaar, tweede is rijker.
5. **Brand-voice in workspaces**: laat `marketing/CLAUDE.md` user's voice-profile importeren via `~/.claude/rules/voice-profile.md`, of generieke template + per-user override? Eerste werkt alleen voor Vincent, tweede schaalt naar andere users.
6. **Cockpit-model**: hardcode Opus 4.7 of laat user kiezen via config? Eerste is opinionated, tweede is flexibel.
7. **Worker-model default**: Sonnet 4.6 of Haiku 4.5? Sonnet is veiliger voor kwaliteit; Haiku is goedkoper bij grote volumes.
8. **Inbox-cleanup**: automatisch wissen na N dagen of nooit? Privacy vs nostalgia.
9. **Multi-workspace tasks**: kan een task spannend over 2 workspaces (bv. blog + email-sequence)? Of strikt 1-task-1-worker?
10. **iTerm-only of ook ander terminal**: launch via `open -a Terminal` als fallback voor mensen zonder iTerm?

---

## 15. Cross-references

- Bestaande launcher-kiem: `/Users/vincentvandeth/Development/vnx-roadmap-autopilot-wt/claudedocs/claude-launcher.sh`
- VNX (heavyweight zus-product): `~/Development/vnx-orchestration-system/`
- Conversation-manager (browser/resumer voor sessies): `~/Desktop/BUSINESS/development/claude-conversation-manager/`
- User's voice-profile: `~/.claude/rules/voice-profile.md`
- User's anti-AI-tics: `~/.claude/rules/anti-ai-tics.md`
- User's provider-constraints (hard): `~/.claude/rules/provider-constraints.md`

---

## 16. Volgende stappen

1. **Review dit PRD** — markeer wijzigingen / open vragen die jij belangrijk vindt
2. **Kies v0.0 scope** — welke 2 skills in welke workspace
3. **Schrijf voorbeeld-content** voor de eerste 2 skills (jij hebt voice + voorbeelden uit eigen archief)
4. **Start scaffolding** — repo init, folder-structuur, CLAUDE.md-templates
5. **Build v0.0 over 3-4 werkdagen**
6. **Demo-video + LinkedIn-post**
7. **Meet, leer, beslis over v0.5**

Wanneer je dit PRD oppakt, begin met punt 1-2 voordat code start. Scope-discipline maakt dit project of breekt het.
