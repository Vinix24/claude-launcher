# claude-launcher — Launch & Community Strategy

| | |
|---|---|
| **Status** | Draft v0.1 |
| **Datum** | 2026-05-19 |
| **Begeleidt** | PRD.md (productspec) |
| **Doel** | Een speelse give-away tool inzetten voor LinkedIn-bereik, naamsbekendheid en VNX-funnel |

---

## 1. Premise — waarom geven, niet verkopen

Twee redenen.

**Ik verkoop geen tools, ik verkoop denkwerk.** VNX en mijn consultancy zijn de echte producten. claude-launcher is geen revenue-product, het is een **showroom**. Een gratis weg-geefje toont meer competentie dan elke whitepaper. Niemand leest jouw "10 redenen waarom AI je MKB transformeert", maar mensen klikken wél op een github-repo waar ze meteen iets mee kunnen.

**Open source is mijn handtekening.** VNX heeft 29 stars zonder enige promotie, pure long-tail discovery. Dat patroon werkt voor mij. Een tweede open source release versterkt de positie van "die ondernemer die echt open source doet, geen marketing-cosplay".

---

## 2. Positionering — "werkend prototype", niet enterprise

Belangrijke set-the-bar move: dit is **bewust** geen polished product.

| Wat het IS | Wat het NIET is |
|---|---|
| Werkend prototype voor power-users | Enterprise-tool |
| Bash + Python + tmux | Electron-app of SaaS |
| MIT, lokaal, geen telemetry | Subscription of freemium |
| Mag rauwe randjes hebben | Bug-vrije productie-software |
| Living roadmap met community-input | Vastgepind feature-overzicht |
| De voorganger van VNX Orchestration | De productie-versie (dat is VNX) |

Door dit expliciet zo te framen in de eerste post, zet ik verwachtingen. Mensen die "het werkt niet voor X" reageren ben ik niet bang voor, dat is precies de **engagement** die ik wil. Die comments zijn mijn roadmap.

Voorbeeld-zin voor de post: *"Dit is hoe VNX Orchestration ooit begon. Lichter, kleiner, geen governance-overhead. Vertel me wat jij er nog in wil zien."*

---

## 3. Funnel-design

claude-launcher is de poort. Drie lagen:

```
LAYER 1 — claude-launcher (giveaway)
  Gratis, MIT, prototype-niveau, lage drempel
  Doel: traffic + naamsbekendheid
        ↓ wie wil meer
LAYER 2 — VNX Orchestration
  Open source, heavyweight, governance-first
  Doel: technische geloofwaardigheid
        ↓ wie wil hulp
LAYER 3 — Vincent's consulting
  AI-architectuur voor MKB, betaald
  Doel: omzet
```

Verwijzingen in de README en in de LinkedIn-posts:

- "Wil je dezelfde aanpak maar dan voor productie-werk met audit-trail? Kijk eens naar **VNX Orchestration** (link)."
- "Heb je een eigen AI-architectuur-vraag voor je MKB? Ik help bedrijven hiermee (link naar vincentvandeth.nl)."

Subtiel, niet pushy. Functioneert als footer, niet als pitch.

---

## 4. LinkedIn-post-serie

Niet één post maar een **serie van 4-6 posts** over 3-4 weken. Dat houdt het algoritme en de aandacht warm.

### Post 1 — De launch (week 0)

**Hook-statement (geen vraag)**:
*"Vijf experts in mijn cockpit. Eén instructie volstaat."*

**Body** (~150 woorden):
- Wat het doet (concreet, met voorbeeld)
- Hoe het werkt (1 zin per laag)
- Wat het NIET doet (verwachtingen managen)
- Open vraag: "wat zou jij er in willen zien?"
- Links: GitHub-repo + VNX-repo + website

**Visual**: 60-90 sec demo-video, geen voice-over, ondertiteling in Nederlands.

### Post 2 — Eerste community-feedback verwerkt (week 1)

**Hook**:
*"24 uur na launch: 47 comments, 12 PR's. Hier is wat ik heb verwerkt."*

**Body**:
- Top 3 wishes uit de comments
- Welke ik heb verwerkt, welke niet (eerlijk over de "nee")
- Screenshot van een PR die ik mergede
- Lesson learned: een specifieke verrassing
- Vraag: nieuwe feature-poll

**Visual**: screenshot van het merged-PR view + nieuwe demo-snippet.

### Post 3 — Anatomie van een skill (week 2)

**Hook**:
*"Ik schreef een blog-skill van 8 zinnen. Dit is wat hij doet."*

**Body**:
- Toon de SKILL.md letterlijk (gestylde code-block)
- Leg uit waarom korte instructies beter werken dan lange prompts
- Verwijs naar Claude Code Skills docs
- Sterk statement over prompt-engineering als craft

**Visual**: split-screen, input (korte zin), output (gepolijste blog).

### Post 4 — De grote broer (week 3)

**Hook**:
*"claude-launcher is de voorganger. VNX Orchestration is het werkpaard."*

**Body**:
- Verschil tussen exploration en productie
- Wanneer je launcher gebruikt, wanneer VNX
- Concrete metriek: hoeveel governance is genoeg voor jouw werk?
- Link naar VNX-repo + eigen consulting-pagina

**Visual**: side-by-side diagram (cockpit-flow vs T0-T3-flow).

### Post 5 — Case study (week 4-5, optioneel)

Iemand uit de community gebruikt het in productie. Interview-stijl post:

*"Hoe Sara haar contentkalender draait met claude-launcher en 3 workspaces."*

Alleen doen als er een echte case opduikt. Niet forceren.

### Post 6 — Roadmap-update (week 5-6)

**Hook**:
*"Ik bouwde 6 features uit jullie wensenlijst. Hier is de v0.5 release."*

Bundel-update. Sluit de eerste cyclus af.

---

## 5. De engagement-loop

Dit is de mechaniek die de give-away tot een **bereik-engine** maakt.

```
[1] Post 1 vraagt expliciet om feature-wensen in comments
[2] Comments worden GitHub-issues (met credit naar de commenter)
[3] Ik bouw 1-3 van die issues per week
[4] Volgende post toont de updates en tagt de oorspronkelijke commenters
[5] Getagde commenters reageren, hun netwerk ziet de tag, nieuwe bereik
[6] Nieuwe wensen in comments → issues → bouwen → tag → ...
```

**Belangrijk**: tag echt mensen die feedback gaven (max 3 per post, anders spam). "Mensen voelen zich gezien" is een sterke engagement-driver.

Voorbeeld-zin in post 2: *"Sara vroeg om een Finse-vlag-skill, die staat er nu in. Joost wilde een lay-out-optie voor docx, gebouwd. Pieter vroeg om enterprise-SSO, nee, dat past niet bij deze tool, sorry."*

Die laatste "nee" is **belangrijk**. Het toont karakter en focus. Mensen vertrouwen meer iemand die soms nee zegt.

---

## 6. Tone-of-voice voor de posts

Strikte toepassing van mijn voice-profile (`~/.claude/rules/voice-profile.md` + `anti-ai-tics.md`):

| Wel | Niet |
|---|---|
| 1e persoon enkelvoud | "we", "ons", "onze" |
| Sterke statement als hook | Vraag als hook ("Wist je dat...?") |
| Concrete getallen (47 comments, 1247 woorden) | Vage "veel mensen" / "iedereen" |
| Korte zinnen, witregels tussen alinea's | Lange paragrafen zonder lucht |
| Eerlijke "nee" bij verzoeken die niet passen | Alles-met-iedereen-tevreden-houden |
| Authority spaarzaam (1 bewijspunt per post) | Stapeling van credentials |
| Nederlands | Engels (tenzij specifiek B2B/dev-audience) |
| Verwijzingen naar VNX als grote broer | Zwijgen over VNX (mis daarmee de funnel) |

**Geen em-dashes**, geen "uiteindelijk", geen "kortom", geen "In de hedendaagse snel veranderende AI-wereld...".

---

## 7. Concept-draft Post 1

```
Vijf experts in mijn cockpit. Eén instructie volstaat.

Ik typ "schrijf een blog over AI-impact op MKB-marketing" en
mijn cockpit doet de rest. Hij kiest het juiste skill-pakket,
herschrijft mijn zin tot een gestructureerde prompt, opent een
nieuwe Claude-sessie in een voor-geconfigureerde folder, en
rapporteert terug zodra de blog klaar is.

Geen copy-paste tussen tabs. Geen brand-voice opnieuw uitleggen.

Zo begon VNX Orchestration ooit. Een handvol bash-scripts die
Claude-sessies opspawnden in tmux-windows. Inmiddels is VNX een
governance-first runtime voor productie-werk, maar de oer-vorm
zat al in die scripts.

Die oer-vorm heb ik nu opgepoetst en open source gezet:
claude-launcher. De lichte voorganger, zonder de governance-
overhead. Voor solopreneurs en marketeers die geen 1.100+
receipts per week nodig hebben, maar wel sneller af willen zijn.

Wat het wel doet:
- Spawnt parallelle Claude Code-sessies in workspaces
- Routeert jouw natuurlijke instructie naar de juiste skill
- Genereert blogs, LinkedIn-posts, marktonderzoek, pitch-decks
- Volledig lokaal, MIT-license, geen cloud, geen telemetry

Wat het NIET doet:
- Geen enterprise-SSO, geen audit-trail (kijk naar VNX als je
  dat nodig hebt, link in comments)
- Geen perfectie. Dit is een werkend prototype, geen productie-tool
- Werkt nog niet op Windows. Mac alleen, voorlopig

Vertel me in de comments: wat zou jij er nog in willen zien?
Komende weken bouw ik de top-wishes uit.

→ github.com/Vinix24/claude-launcher

#AI #OpenSource #ClaudeCode #MKB
```

Twee bewuste keuzes om scherp te houden:
- "wat het NIET doet" is groter dan in een normale launch-post. Dat zet verwachtingen en lokt geen klachten uit.
- Verwijzing naar VNX in "wat het niet doet"-blok, niet in een aparte plug-zin. Subtieler.

---

## 8. Comment-strategy (eerste 48 uur)

De eerste 48 uur na posten zijn cruciaal voor LinkedIn-algoritme. Plan:

| Tijdstip | Actie |
|---|---|
| T+0 | Post live. Direct alle DM-friends/peers privé bericht: "kijk eens, mocht je iets interessants zien laat het weten". |
| T+15min | Eerste 3 comments krijgen meteen een reactie van mij (algoritme-boost). |
| T+1u | Tag 1-2 specifieke peers in een comment ("@persoon dit lijkt iets voor jou"). |
| T+3u | Eerste GitHub-issue uit een comment promoveren ("opgepakt, zie issue #1"). |
| T+24u | Mini-update in comments: "X stars, Y comments, top-wish was Z". |
| T+48u | Beslissen over post 2: heeft de momentum-cyclus aangetrokken? |

Op alle comments reageer ik **eerlijk en kort** (1-3 zinnen). Geen "thanks for sharing!"-vlees. Wel: substantieve antwoorden op substantieve vragen.

Bij negatieve comments ("dit is gewoon X opnieuw", "waarom geen Y"):
- Lees twee keer voordat je antwoordt
- Bedank serieus voor de scherpe blik
- Wees eerlijk over de tradeoff
- Sluit af met een specifieke wedervraag

Mensen die scherp zijn worden vaak je beste ambassadeurs als je ze respecteert.

---

## 9. Risks van deze strategie

| Risico | Mitigatie |
|---|---|
| **Overpromise**: mensen verwachten meer dan v0.0 levert | Sectie "wat het niet doet" prominent in alle posts |
| **Feature-creep door comments**: te veel community-wishes verwerken, focus verliezen | Strikt: max 3 issues per week oppakken, rest in "later"-bucket |
| **Engagement valt dood na week 2** | Voorbereiden van 2-3 content-buckets vóór launch; niet alleen reactief posten |
| **Trolls / negative SEO** | LinkedIn modereert redelijk. Niet engageren met haters; één keer kort en verder negeren |
| **VNX-cannibalisatie** ("waarom dan VNX gebruiken?") | Post 4 over verschil expliciet maken |
| **Code-kwaliteit valt af** door snelheid | "Bewust niet perfect" framing biedt dekking; pre-launch wel een minimale linting + test-stap |

---

## 10. Success metrics (recap PRD + extra)

| Metriek | v0.0 launch target (30 dagen) |
|---|---|
| LinkedIn-post 1: impressies | > 5.000 |
| LinkedIn-post 1: comments | > 50 |
| GitHub-stars | > 100 |
| GitHub-PR's van community | > 5 |
| Inkomende DM's "vertel meer over VNX" | > 5 |
| Inkomende consulting-vragen | > 1 |
| Posts in de serie | 4-6 over 6 weken |
| GitHub-issues uit comments | > 15 |

Bij score < 50% van targets: hertoetsen of vorm-factor van de launch klopt of dat de tool zelf te niche is.

Bij score > 150% van targets: overwegen of een v1.0 met desktop-wrapper sneller moet dan gepland (= traction sleept de roadmap mee).

---

## 11. Praktische timing

Voorstel-volgorde:

| Week | Werk |
|---|---|
| **-2** (voor launch) | v0.0 build van 3-4 dagen (PRD sectie 9) |
| **-1** | Demo-video opnemen, README polijsten, post-draft testen op 2-3 peers |
| **0** | LinkedIn-post 1 live (kies dag: dinsdag of woensdag 09:00 NL-tijd) |
| **0-1** | Comment-strategy actief, GitHub-issues bijhouden |
| **+1** | Post 2 met community-update |
| **+2** | Post 3 over skill-anatomie |
| **+3** | Post 4 over VNX-verschil |
| **+4-5** | Optioneel post 5 (case study) |
| **+5-6** | Post 6 met v0.5-release-bundel |

Aanrader voor de eerste post: dinsdag of woensdag, 09:00-10:00 Europe/Amsterdam tijd. Beste LinkedIn-impressie-momenten voor B2B/tech-content.

---

## 12. Cross-references

- **PRD**: `PRD.md` (productspec)
- **Launcher-kiem**: `claude-launcher-kiem.sh` (huidige bash-base)
- **VNX-link voor in posts**: `github.com/Vinix24/vnx-orchestration`
- **Consulting-link**: `vincentvandeth.nl`
- **Voice-rules**: `~/.claude/rules/voice-profile.md` + `anti-ai-tics.md`
- **Anti-marketing-rules**: `~/Desktop/BUSINESS/.claude/rules/anti-marketing-buzzwords.md`

---

## 13. Open beslissingen voor wanneer ik dit oppak

1. **Launch-datum**: hangt af van wanneer v0.0 klaar is (3-4 werkdagen)
2. **Demo-video toolchain**: Screen.studio, Loom, of native macOS screen-record? Eerst proefopname doen
3. **English-versie van post 1**: ja of nee? B2B dev-audience is mogelijk Engels. Twee versies of niet?
4. **Cross-poste naar X.com/Mastodon**: ja, met aanpassing per platform (X is korter)
5. **Hashtags**: top 3 #AI #OpenSource #ClaudeCode is OK, of bredere mix #Productiviteit #MKB?
6. **Welke peers tag ik in T+1u?** Lijstje voorbereiden: 5-8 mensen die thematisch passen
7. **Roadmap-publicatie**: GitHub Project Board met community-issues zichtbaar, of intern houden tot ik klaar ben?
