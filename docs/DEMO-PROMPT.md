# Demo-prompt — parallel clients, automatische vergelijking

De canonieke demo-prompt voor claude-launcher. Toont in één instructie dat dezelfde prompt naar twee verschillende workspaces compleet verschillende output produceert — gedreven door `CLAUDE.md`, `brand-voice.md` en `rules.md` per workspace, niet door slimme prompting.

## Vereiste setup

Eerst `./install.sh` draaien. Bij "Twee demo-klantworkspaces installeren?" → Enter (default Y). Dat installeert:

- `~/.claude-launcher/workspaces/clients/growthlab/` — performance marketing bureau, cijfers-eerst, B2B SaaS
- `~/.claude-launcher/workspaces/clients/studio-atlas/` — brand consultancy, klassiek Nederlands, verhalend

Beide hebben dezelfde skills (`blog-writer` + `blog-editor`) via symlink, maar elk hun eigen `CLAUDE.md`, `brand-voice.md` en `rules.md`.

## De prompt (copy-paste in de cockpit)

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
    Sla op in $CLAUDE_LAUNCHER_HOME/output/.

    Als ALLE deliverables (blog + editor-rapport) klaar zijn,
    schrijf als allerlaatste actie:
      echo '<korte samenvatting>' > $CLAUDE_LAUNCHER_HOME/output/$CLAUDE_LAUNCHER_TASK_ID.done

    Dat .done bestand is hoe de cockpit weet dat jij klaar bent."

2. Geen --headless. Spawn beide als nieuwe panes rechts van de cockpit.

3. Wacht tot beide <task-id>.done files verschijnen in
   $CLAUDE_LAUNCHER_HOME/output/. Poll elke 30 seconden via
   /loop 30s /cockpit-monitor.

4. Als beide done zijn:
   a. Lees beide blog-bestanden uit ~/.claude-launcher/output/
   b. Maak een side-by-side vergelijking met aandacht voor:
      - Openingszin (hook-stijl en lengte)
      - Woordkeus en jargon-gebruik (Engelse termen, performance-jargon)
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

## Wat er hoort te gebeuren

1. **Cockpit-Claude activeert `Skill(project-manager)`** als allereerste actie. Niet direct Bash.
2. Twee `cockpit launch`-calls **zonder** `--headless`. Twee nieuwe tmux-windows worden toegevoegd aan de cockpit-sessie (gelabeld met de task-id). Switch met `Ctrl-B + window-nummer` of `Ctrl-B w`.
3. Monitor armt op `~/.claude-launcher/inbox/*.ndjson` (of `/loop 60s` als fallback).
4. Per worker komt er een stroom events binnen: status (begonnen, brand-voice gelezen, outline klaar, draft 60%), uiteindelijk deliver + done.
5. Per worker volgt een tweede mini-flow: blog-editor leest het concept, schrijft een verdict-rapport (PASS / PASS WITH NOTES / FAIL), levert dat ook op.
6. Zodra de tweede worker `done` rapporteert, leest de cockpit-Claude zelf beide blog-`.md`-bestanden.
7. Vergelijkings-rapport wordt geschreven en in de cockpit getoond.

Totaal-runtime: meestal 4-7 minuten (afhankelijk van blog-lengte en model-latency).

## Wat je in de output mag verwachten

Bij identieke prompt produceren de twee workspaces wezenlijk verschillende blogs:

**GrowthLab-blog** opent waarschijnlijk met:
- Een statistiek of percentage in de eerste twee zinnen
- Engelse jargon zonder uitleg (CAC, LTV, MRR, churn, cohort)
- Korte zinnen, em-dashes als signatuur, bullets met `—`
- Authority-punt over experimenten of MRR-lift
- CTA: "plan een audit", concreet, gemeten

**Studio Atlas-blog** opent waarschijnlijk met:
- Een observatie, paradox, of beeldspraak
- Klassiek Nederlands, geen Engelse marketing-jargon
- Lange ademende zinnen, puntkomma's, geen em-dashes
- Authority-punt over decennia ervaring of het boek "Het merk als ritueel"
- CTA: uitnodigend, geen urgentie, "wanneer u op een kruispunt staat"

Beide blogs slagen voor hun eigen blog-editor, maar zouden falen voor de andere — precies omdat de `rules.md` per client streng zijn.

De vergelijkings-rapport maakt deze verschillen expliciet voor wie de blogs niet woord voor woord wil naast elkaar leggen.

## Variant: één klant

Als je liever één spawn doet:

```
Spawn voor clients/growthlab een blog over de toekomst van marketing,
supporting article, 1000-1500 woorden, FAQ erin. Blog-editor erna.
```

Of:

```
Spawn voor clients/studio-atlas dezelfde prompt.
```

## Variant: andere business-vraag

De vergelijking werkt voor elk onderwerp dat raakt aan marketing-strategie. Vervang `de toekomst van marketing` door:

- `het einde van de marketingfunnel`
- `attributie in 2027`
- `merkbouw versus performance`
- `AI in B2B marketing`

Hoe meer het onderwerp in beide kampen relevant is, hoe scherper de tegenstelling.

## Troubleshooting

**De cockpit-Claude schreef de blog zelf in plaats van te dispatchen.** De project-manager skill activeerde niet. Restart de cockpit (`cockpit start`) of begin de prompt expliciet met "Activeer eerst de project-manager skill, daarna ...".

**Geen nieuwe tmux-windows zichtbaar.** Check eerst of je `cockpit start` hebt gedaan (anders draait er geen sessie om in te splitsen, en valt cockpit launch terug op losse sessie + osascript). Als de sessie wel actief is maar workers verschijnen niet als windows: cockpit-Claude voegde mogelijk `--headless` toe. Restart en zeg expliciet "geen --headless".

**Monitor mist events.** Zelden, maar mogelijk bij oudere cockpit-versies zonder pre-create van inbox-file. Workaround: gebruik `/loop 60s /cockpit-monitor` expliciet in plaats van Monitor.

**Workers blijven hangen op een question-event.** Cockpit-Claude moet de vraag oppakken en aan jou voorleggen. Als hij dat niet doet, type zelf: "wat vraagt de werker en wat is mijn antwoord?". Cockpit moet dan de inbox lezen en de question surfacen.

**De vergelijking is generiek of vlak.** De prompt was te kort. Vraag specifiek: "vergelijk de openingszinnen woord voor woord", "tel hoeveel Engelse jargon-termen elk gebruikt", "welke alinea uit GrowthLab zou onmogelijk in Studio Atlas kunnen staan".

## Voor de LinkedIn-launch-video

Deze prompt is wat je in de demo-video laat zien. Zie `docs/DEMO-SCRIPT.md` voor de regie-noten (camera, ondertiteling, timing).

Ideale opname: één terminal-venster met de cockpit-tmux-sessie. Demonstreer het window-switchen met `Ctrl-B w` zodat kijkers zien dat de drie sessies (cockpit + 2 workers) in één terminal zitten. Aan het eind toont de cockpit het vergelijkings-rapport. Totale screentijd 60-90 seconden, eventueel met versnelde tussen-stukken waar de workers schrijven.
