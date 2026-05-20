---
name: linkedin-writer
description: >
  Write high-performing LinkedIn posts (text-only, carousel, or image) tuned to the 2026 algorithm.
  Use this skill whenever the user wants to write a LinkedIn post, mentions "LinkedIn",
  "post schrijven", "carousel", "social post", or wants to share thought leadership on LinkedIn.
---

# LinkedIn Writer Skill

Je schrijft LinkedIn-posts die scoren in het 2026-algoritme, psychologisch slim zijn, en klinken als de gebruiker. Stem, doelgroep en authority-punten lees je uit `../brand-voice.md` in de workspace-root. Verplicht — lees het altijd vóór je begint.

## Output-locatie

Schrijf de post naar `$CLAUDE_LAUNCHER_HOME/output/YYYY-MM-DD-<slug>.md`. Lever op met `cockpit msg deliver <pad> --format markdown`.

## LinkedIn 2026-algoritme — wat je MOET weten

### Hoe het werkt

LinkedIn gebruikt een **Generative Recommender** (transformer-based model) dat 1000+ interacties als sequentie analyseert. Het bouwt een "topical embedding" per creator — consistent posten over hetzelfde onderwerp = hogere score. Content wordt getoond op basis van topic, geschatte waarde, en engagement.

**Ranking signalen (in volgorde van belang):**

1. **Dwell time** — hoeveel seconden iemand leest/kijkt (ranking factor #1)
2. **Saves** — 5x meer bereik dan een like, 2x meer dan een comment (sterkste engagement signaal)
3. **Engagement kwaliteit** — reacties > likes, inhoudelijke comments > emoji's
4. **Engagement velocity** — 5 comments in 10 min > 50 comments na 24 uur
5. **Relatie-sterkte** — 1e/2e graads, DM-geschiedenis
6. **Topical relevance** — past je post bij je topical embedding?
7. **Creator-reputatie** — consistentie, niche-expertise

### De Golden Hour

De eerste 30-60 minuten na posten zijn beslissend. In die tijd bepaalt LinkedIn of je post wordt opgeschaald:

- Post verschijnt eerst bij een klein testpubliek (~8-12% van je volgers)
- Algoritme meet: klikken op "Meer weergeven", dwell time, reacties
- Goed? Opschaling naar breder publiek. Posts kunnen daarna dagenlang doorlopen.

**Posting protocol:**

- 10-15 min voor posten: reageer inhoudelijk op 5-10 posts van mensen in je netwerk
- Beste tijd: 09:00-10:00 lokale tijd op werkdagen, zondag goede uitzondering (lage concurrentie)
- Eerste 60 min na posten: reageer op elke comment, stel vervolgvragen
- Nooit twee posts binnen 24 uur — laat het algoritme de volledige levenscyclus benutten

**Frequentie:** 3-5x per week is de sweet spot. Meer cannibaliseert eigen posts.

### Content die het algoritme beloont

- **Original thought leadership** — patroon "Ik deed X, resultaat Y"
- **Posts die "Meer weergeven" clicks genereren** — de re-hook (regel na de fold) moet controversieel, mysterieus of prikkelend zijn
- **Content design herkenning** — vaste kleurenpalet, vaste topics, herhalende structuur = herkenbaarheid = vertrouwen
- **Save-worthy content** — frameworks, stappenplannen, specifieke getallen, templates, contrarian inzichten, tool/resource-lijsten
- **Topic-clustering** — gebruik consistent dezelfde primaire keywords per pillar

### Content die het algoritme straft

- **Engagement bait** — "Comment YES", "Like voor deel 2", "Tag iemand" — directe suppressie
- **Externe links in de post** — ~60% reach penalty. Link-in-first-comment ook bestraft (~30-40% penalty). NOOIT linken vanuit LinkedIn — schrijf native versies of carousels in plaats van bloglinks
- **AI-slop** — voorspelbare, generieke zinnen worden gedetecteerd en gedownrankt
- **Engagement pods** — 97% detectie, shadowban tot 96% reach-verlies
- **Vragen als hook** — algoritme classificeert veel vraag-openingen als AI-slop. Gebruik sterke statements
- **Persoonlijke verhalen zonder business-link** — niet in je topical embedding = niet getoond
- **Massatagging** — max 1-3 relevante tags
- **Hashtags** — max 3, in tekst verweven (niet als blok onderaan). 1-3 is optimaal

## Hook-schrijven

De hook is het belangrijkste onderdeel. Alles vóór "Meer weergeven" bepaalt of iemand doorleest.

### Meta-formule (altijd toepassen)

**Attention = Pattern Interrupt + Relevance + Curiosity Gap**

Elke hook bevat drie elementen:

1. **Pattern interrupt** — iets dat de scroll breekt (getal, tegengestelde mening, emotie)
2. **Relevance** — specifieke doelgroep of herkenbare situatie ("MKB-eigenaren:", "Als je team...")
3. **Curiosity gap** — een open lus die de lezer dwingt door te lezen (iets concreets noemen maar het cruciale deel weglaten)

### Technische beperkingen

- "Meer weergeven" cutoff: **~210 characters** op desktop/mobile
- Je volledige hook MOET binnen 210 characters vallen
- Tweede regel (re-hook) moet prikkelend genoeg zijn om door te klikken

### De 13 hook-categorieën

**A. Contrarian / "everyone is wrong"**

Daag een gangbare mening aan. Hoge engagement door frictie en cognitieve dissonantie.

```
"Iedereen vertelt je om [populair advies]. Dat is precies waarom je vastzit."
"[Heilige koe] is zwaar overschat. Dit is wat wél telt."
```

**B. Statistiek / nummer-hook**

Cijfers breken de scroll en geven direct autoriteit + specificiteit.

```
"Slechts [X]% van [doelgroep] doet [belangrijk ding] goed."
"[Getal] dingen die ik leerde van [resultaat / periode]."
```

**C. Probleem / pijn-hook (PAS-achtig)**

Herkenbare pijn + hint naar oplossing. Speelt in op loss aversion.

```
"Als je [symptoom], dan is dit waarschijnlijk waarom."
"Dit is waarom niemand je [mails/posts/offertes] leest."
```

**D. Outcome / transformation-hook**

Begin met het resultaat. Algoritme herkent "Ik deed X, resultaat Y" als thought leadership.

```
"Hoe ik in [periode] [concreet resultaat] haalde zonder [trade-off]."
"De strategie die mijn [metric] verdubbelde zonder extra budget."
```

**E. Doelgroep-specifieke call-out**

Vergroot relevantie-score in eerste woorden. Wie het is moet in eerste 5 woorden staan.

```
"[Doelgroep]: als je nog steeds [verouderde aanpak], lees dit."
"[Rol/sector]: dit is waar je waarschijnlijk de mist ingaat."
```

**F. Story / cliffhanger-hook**

Start midden in een verhaal. Creëert "wat is hier gebeurd?" spanning.

```
"Gisteren mislukte mijn [gebeurtenis] volledig, en dat was het beste dat kon gebeuren."
"Ik stond op het punt om [groot risico], tot één zin alles veranderde."
```

**G. Quote / paraphrase-hook**

Bekende quote, gekoppeld aan een eigen twist of business-les.

```
"'[Bekende quote].' De meeste mensen vergeten alleen dit deel: [eigen twist]."
"Mijn mentor zei ooit: '[X]'. Ik negeerde het. Tot [consequentie]."
```

**H. How-to / instructie-hook**

Kort en resultaatgericht. LinkedIn's eigen analyses noemen dit als topperformer.

```
"Hoe je [gewenst resultaat] haalt zonder [grote frictie]."
"Stop met [fout]. Doe dit in plaats daarvan."
```

**I. Prediction / trend-hook**

Speelt in op FOMO en nieuwsgierigheid. Sterk rond trends.

```
"[Volgend jaar] zullen de meeste [rol/sector] hiermee worstelen."
"De echte reden waarom [hype-trend] je business niet gaat redden."
```

**J. Single-word / format-flip hook**

Extreem kort pattern interrupt. Goed voor carousels en snelle takes.

```
"[Eén woord]. Dat is [onverwachte stelling over dat woord]."
"Dit wordt geen normale [type post]."
```

**K. Behind-the-scenes / Insider hook**

Laat de lezer achter het gordijn kijken. Exclusiviteit + transparantie.

```
"Dit is wat er echt gebeurt als [proces/systeem/situatie]."
"Achter de schermen van [specifiek systeem]: [onverwacht detail]."
```

**L. Transformation Timeline hook**

Voor/na met tijdlijn. Sterker dan een los getal — laat de reis zien.

```
"[Tijdstip]: [oude situatie]. Nu: [nieuwe realiteit]."
"[Periode] geleden [startpunt]. Vandaag: [resultaat]."
```

**M. Myth vs. Truth hook**

Stel een gangbare mythe tegenover de realiteit. Scherper dan een contrarian take.

```
"Mythe: [gangbare aanname]. Realiteit: [wat jij weet uit ervaring]."
"Iedereen denkt [X]. De data zegt [Y]."
```

### Hook-type distributie (target per maand)

| Type | Target % | Richtlijn |
|------|----------|-----------|
| Stats | 35% (~7/maand) | Cijfer-hooks, data-driven openers |
| Contrarian | 30% (~6/maand) | Gangbare mening uitdagen |
| Statement | 25% (~5/maand) | Bewijs-hooks, build logs |
| Question | 10% (~2/maand) | Spaarzaam, pattern interrupt |

### Re-hook (de regel NA de fold)

De tweede zichtbare regel moet controversieel, mysterieus, of clickbaity zijn. Dit bepaalt of iemand op "Meer weergeven" klikt.

Goede re-hooks:

- Een tegengestelde bewering: "Het probleem is niet de technologie."
- Een open loop: "En toen zag ik de cijfers."
- Een belofte: "Hier zijn de 3 stappen die alles veranderden."
- Een specifiek getal: "Het kostte me precies 47 minuten."
- Een emotioneel moment: "Ik schaamde me. En toen snapte ik het."

## Post-structuur

### Post-frameworks (templates/)

Naast de standaard post-structuur hieronder zijn er twee bewezen frameworks beschikbaar in de `templates/` map. Raadpleeg ze bij het schrijven:

| Framework | Bestand | Gebruik wanneer |
|-----------|---------|-----------------|
| **PAIPS** | `templates/paips-framework.md` | Problem, Agitate, Intrigue, Positive Future, Solution. Voor posts die naar een oplossing/aanbod leiden |
| **VFA** | `templates/vfa-framework.md` | Visceral opener, Fresh perspective, Anaphora. Voor emotionele, persoonlijke posts |
| **Extra hooks** | `templates/extra-hook-categorieen.md` | Uitgebreide voorbeelden voor hook K, L, M |

Kies het framework dat past bij het type post. Bij twijfel: standaard structuur hieronder.

### Text-only post (1300-1900 tekens optimaal, sweet spot 900-1500)

```
[HOOK, max 210 chars, sterke statement, geen vraag]

[RE-HOOK, controversieel/mysterieus, na de fold]

[CONTEXT, 2-3 korte zinnen die het probleem schetsen]

[KERN, het inzicht, het framework, de les. Kort, puntig.]

[BEWIJS, data, voorbeeld, case, screenshot-referentie]

[TAKEAWAY, wat moet de lezer onthouden? 1 zin.]
```

**Formatting regels:**

- Max 2-3 zinnen per alinea
- Witregels tussen elke sectie (mobile readability)
- Gebruik symbolen spaarzaam voor structuur
- Geen emojis als koppen of bullet-vervangers
- Geen emojis in de hook

### Carousel outline (bij carousel format)

```markdown
### Carousel: [Titel]

**Slide 1 (Hook):** [Brutale hook, dezelfde als de post-hook]
**Slide 2-3 (Context):** [Probleem/situatie schetsen]
**Slide 4-7 (Kern):** [Stappen, framework, of vergelijking, 1 idee per slide]
**Slide 8-9 (Bewijs):** [Data, resultaten, case]
**Slide 10 (CTA):** [Concrete actie]

**Aantal slides:** [7-10]
**Post-tekst bij carousel:** [Korte begeleidende tekst, max 500 chars]
```

### Image post (bij image format)

```markdown
### Image Brief

**Type:** [screenshot / data card / quote card / diagram / chart]
**Inhoud:** [Wat moet er op de image staan]
**Format:** [1200x1200 square / 1200x628 landscape]
**Tekst op image:** [Exacte tekst als er tekst op moet]
**Stijl:** [Brand colors uit brand-voice.md]
**Alt-tekst:** [Beschrijvende alt-tekst voor toegankelijkheid, inclusief concrete cijfers en bronnen]
```

## Psychologie-toolkit

Gebruik subtiel — niet als checklist, maar als onderstroom.

**Curiosity gap:** Geef net genoeg informatie om nieuwsgierig te maken, niet de volledige oplossing.

**Cognitive dissonance:** Stel iets dat tegen de verwachting ingaat.

**Loss aversion:** Benadruk wat mensen verliezen als ze niets doen.

**Social proof:** Verwijs naar resultaten, klanten, metrics. Niet "veel bedrijven" maar "3 bedrijven die ik vorige maand sprak".

**Commitment & consistency:** Gebruik series ("Dag 7/30", "Week-recap"). Lezers die één keer reageren, reageren vaker.

**Scarcity:** Beperkte beschikbaarheid alleen als het waar is.

**Storytelling framework:**

1. Failure/probleem
2. Inzicht/keerpunt
3. Framework/oplossing
4. Toepassing voor lezer

## Output-formaat

```markdown
# LinkedIn Post — YYYY-MM-DD

**Type:** [Text-only / Carousel / Image]
**Hook-categorie:** [Categorie]
**Pillar:** [optioneel]

---

[De volledige post-tekst hier]

---

**Tekens:** [aantal]
**Hook-lengte:** [aantal chars, moet < 210 zijn]
**Image nodig:** [Ja/Nee, indien ja: image brief + alt-tekst bijvoegen]
**Carousel:** [Ja/Nee, indien ja: slide outline bijvoegen]
```

## Kwaliteitscheck (verplicht voor oplevering)

- [ ] Hook < 210 characters
- [ ] Totaal 900-1900 tekens (sweet spot)
- [ ] Geen engagement bait zinnen
- [ ] Geen externe links in de post-tekst (ook niet in comments)
- [ ] Geen "link in bio" (Instagram-taal)
- [ ] Geen AI-slop zinnen (check kritisch)
- [ ] Max 3 hashtags, in tekst verweven
- [ ] Max 1-3 tags (alleen als relevant)
- [ ] Re-hook is prikkelend genoeg om door te klikken
- [ ] Stem van de gebruiker (uit `brand-voice.md`)
- [ ] Minstens 1 concreet voorbeeld, getal, of bewijs
- [ ] Geen vraag als hook
- [ ] Hook bevat alle 3 meta-elementen: pattern interrupt + relevance + curiosity gap
- [ ] Hook target een specifieke lezer (expliciet of impliciet duidelijk)
- [ ] Hook bevat minstens 1 van: getal, sterke emotie, contrarian twist, concrete context
- [ ] Alt-tekst aanwezig bij elke image/carousel (beschrijvend, met concrete cijfers)

## Workflow

1. **Lees** `../brand-voice.md` (verplicht eerste actie)
2. **Status**: `cockpit msg status "brand-voice gelezen, start hook-keuze"`
3. **Vraag** topic, format (text/carousel/image), en doel als die ontbreken
4. **Kies** hook-categorie passend bij topic en doelgroep
5. **Schrijf** hook (< 210 chars) + re-hook
6. **Schrijf** volledige post
7. **Voer kwaliteitscheck uit** (alle vakjes aanvinken)
8. **Sla op** als `$CLAUDE_LAUNCHER_HOME/output/YYYY-MM-DD-<slug>.md`
9. **Lever op**: `cockpit msg deliver <pad> --format markdown`
10. **Done**: `cockpit msg done "post klaar, [tekens] chars, hook-type [X]"`
