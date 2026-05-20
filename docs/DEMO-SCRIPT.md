# 90-seconden demo-script — claude-launcher LinkedIn launch

Voor de eerste LinkedIn-post in de launch-serie. Geen voice-over, ondertiteling in Nederlands. Echt scherm-werk, geen mockup.

## Pre-flight

Voor opname:

- iTerm-vensters op één scherm, niet op laptop-display (groter is beter voor leesbaarheid)
- Lettergrootte op 14-16pt minimum
- Theme: hoog contrast (dark mode of light mode, niet halfweg)
- Geluid uit
- Notifications uit
- Clean inbox: `cockpit kill --all` voor begin
- Pre-vul `~/.claude-launcher/workspaces/marketing/brand-voice.md` met je eigen voice (zodat de output direct goed klinkt)

## Sec 0-5 — Splash

```
Vijf experts in mijn cockpit. Eén instructie volstaat.
```

Statisch frame. Zwarte achtergrond, witte tekst, één regel.

## Sec 5-15 — Cockpit-terminal

Cockpit-tab (links, 60% breedte) is al open en wacht op input.

Type langzaam:

> "schrijf een blog over AI-impact op MKB-marketing voor LinkedIn"

Enter.

## Sec 15-25 — Cockpit denkt zichtbaar

Cockpit toont (zichtbaar in de terminal):

- "Intent: blog-creatie"
- "Workspace match: marketing"
- "Skill match: blog-writer"
- "Spawn task-id: blog-2026-05-20-ai-mkb-marketing"

Dan: tmux split-screen opent rechts (40% breedte) met een tweede Claude-sessie die net begonnen is.

## Sec 25-50 — Worker werkt

Worker-tab toont:

- "[status] brand-voice gelezen, start onderzoek"
- "[status] outline klaar (5 H2s)"
- "[status] draft 30%..."
- "[status] draft 80%..."
- "[deliver] output/2026-05-20-ai-mkb-marketing.md (1.247 woorden)"
- "[done] blog klaar, supporting article, 1247 woorden"

In de cockpit-tab (links) verschijnt parallel:

- "blog-2026-05-20: outline klaar"
- "blog-2026-05-20: draft 80%"
- "blog-2026-05-20: deliver: output/2026-05-20-ai-mkb-marketing.md"

## Sec 50-60 — Cockpit surfaced

Cockpit zegt (in chat):

> "Blog klaar. 1.247 woorden, supporting article. Open? Edit? Export naar docx?"

Type:

> "perfect, maak er ook een pptx-pitch deck van"

Enter.

## Sec 60-75 — Tweede worker, pptx

Cockpit toont:

- "Intent: pitch deck"
- "Output-skill: pptx"
- "Spawn: pitch-2026-05-20"

Nieuwe tmux-window opent. Status-events flikkeren langs in de cockpit:

- "outline klaar (8 slides)"
- "deliver: output/2026-05-20-pitch.pptx"
- "done"

Snel terminal-command:

```bash
open ~/.claude-launcher/output/2026-05-20-pitch.pptx
```

PowerPoint opent in Keynote/PPT. Eerste slide zichtbaar: titel + auteur.

## Sec 75-90 — Outro

Snelle cut tussen:

- Blog (`~/.claude-launcher/output/2026-05-20-ai-mkb-marketing.md` in een markdown-preview)
- Pitch-deck (eerste 3 slides flikkerend)

Tekst overlay:

```
Open source. MIT.
github.com/Vinix24/claude-launcher

Setup: 30 seconden.
```

Eindframe (statisch, 2 sec):

```
claude-launcher
Vijf experts. Eén cockpit. Geen tab-chaos.
```

## Praktisch

- **Opname-tool**: Screen.studio (Mac, betaalde subscription) of native macOS Cmd+Shift+5
- **Editing**: keep cuts kort, max 0.5s tussen acties. Versnel intuïtieve typing tot ~2x speed
- **Ondertiteling**: alleen waar tekst niet direct leesbaar is (cockpit-output is meestal duidelijk genoeg)
- **Geluid**: subtiele tikgeluiden voor enter-presses, of stilte. Geen muziek.

## Wat NIET tonen in de video

- Echte API-keys, account-namen, of credentials
- Live consultancy-werk van klanten
- Niet-gepubliceerde bedrijfsstrategieën
- Bug-meldingen of crashes (record opnieuw als het misgaat)

## Backup-takes

Neem 3-4 takes op:

1. Volledig clean (geen typo's, direct succes)
2. Met een question-event ("welke lengte: 800 of 1500w?") — toont de interactiviteit
3. Met een snelle correctie ("nee, langer maken")
4. Korter (60 sec) — voor X/Twitter cross-post

## Distributie

- LinkedIn: 60-90 sec, native upload (geen YouTube-link)
- X/Twitter: 60 sec versie, native upload, 2-3 thread-tweets eronder
- Reddit r/ClaudeAI of r/MachineLearning: link naar GitHub + 60 sec video gif
- Hacker News: link-only "Show HN: claude-launcher, lightweight Claude Code orchestrator"
