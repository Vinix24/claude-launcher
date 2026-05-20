---
name: blog-writer
description: >
  Write SEO-optimized blog posts in markdown with frontmatter.
  Use this skill whenever the user wants to write a blog, create a blog post, draft an article,
  or mentions "blog", "artikel", "post schrijven", "pillar page", or "supporting article".
  This skill handles the full blog writing process: research, outline, writing, frontmatter, and image placeholders.
---

# Blog Writer Skill

Je schrijft SEO-georiënteerde blogposts in markdown. Stem, doelgroep en authority-punten lees je uit `../brand-voice.md` in de workspace-root. Dat is verplicht — lees het bestand altijd vóór je begint.

De output is een `.md` bestand met YAML-frontmatter, klaar voor pipelines die Hugo, Jekyll, Astro, Strapi of vergelijkbare static-/headless-systemen voeden.

## Output-locatie

Schrijf de blog naar `$CLAUDE_LAUNCHER_HOME/output/YYYY-MM-DD-<slug>.md` waar `<slug>` een kebab-case beschrijving is van het onderwerp. Roep daarna `cockpit msg deliver <pad> --format markdown` aan.

Voorbeeld: `~/.claude-launcher/output/2026-05-19-ai-impact-mkb-marketing.md`

## Frontmatter

Elke blog start met een YAML-blok. De velden hieronder zijn een generieke baseline. Pas aan op de doel-pipeline van de gebruiker (vraag als onduidelijk).

```yaml
---
title: "Volledige blog titel"
slug: "kebab-case-slug"
excerpt: "1-2 zin samenvatting voor blog-cards en SEO. 150-250 tekens."
published: YYYY-MM-DD
categories:
  - category-slug
author: "<auteur-naam>"
coverImage: images/cover.png
coverImageAlt: "Beschrijvende alt-tekst voor de cover"
seo:
  metaTitle: "SEO-titel | <merk>"
  metaDescription: "Meta description voor zoekresultaten. 150-160 tekens."
  keywords: "primair keyword, secundair keyword, tertiair keyword"
  openGraphTitle: "Social sharing titel"
  openGraphImage: images/cover.png
language: nl
status: draft
---
```

### Frontmatter-regels

- **title**: helder, met het primaire keyword natuurlijk verwerkt
- **slug**: kebab-case, max 60 tekens
- **excerpt**: zelfstandige samenvatting die werkt op een listing-card. 150-250 tekens
- **published**: geplande publicatiedatum
- **categories**: vraag de gebruiker welke categorieën zijn pipeline kent als je het niet weet
- **author**: uit `brand-voice.md`
- **coverImage**: laat `images/cover.png` als placeholder staan — een images-skill kan dit later genereren
- **seo.metaTitle**: max 60 tekens, primair keyword vooraan, eindigend op `| <merk>`
- **seo.metaDescription**: action-oriented, primair keyword erin, 150-160 tekens
- **seo.keywords**: comma-separated, primair eerst, daarna 2-4 secundair
- **language**: `nl` of `en` afhankelijk van doelgroep (zie brand-voice)
- **status**: altijd `draft` — de gebruiker reviewt voor publicatie

## Blog-structuur

### 1. Opening hook (geen heading, eerste paragraaf na frontmatter)

Begin met een herkenbare situatie, sterke claim, of feit dat raakt aan de doelgroep. De eerste 2 zinnen verschijnen in Google-snippets en moeten op zichzelf staan.

### 2. Probleem-erkenning (## heading)

Beschrijf het probleem dat de lezer ervaart. Spreek de lezer direct aan. De lezer moet denken: "ja, dat herken ik."

### 3. Kern-content (## headings per sectie)

Het vlees van het artikel. Structuur hangt af van het blog-type:

- **How-to**: genummerde stappen met heldere instructies
- **Pillar page**: complete gids met meerdere subsecties (2000-3000 woorden)
- **Thought leadership**: persoonlijke ervaring + frameworks + lessen
- **List post**: genummerde items met uitleg

### 4. Praktische takeaway

Concrete actie die de lezer NU kan nemen. Niet vaag.

### 5. FAQ-sectie (indien van toepassing)

Voeg FAQ toe wanneer:

- Het een informational/guide blog is (richt op "People Also Ask" queries)
- Het een how-to is (veel-gestelde proces-vragen)
- Het een product/tool-analyse is (bezwaren + beslissingsvragen)

```markdown
## Veelgestelde vragen

### [Vraag zoals mensen 'm zoeken]?

[Concieze antwoord in 2-4 zinnen. Begin met het directe antwoord, voeg context toe.
Verwerk relevante keywords natuurlijk.]
```

Regels:

- 5-8 FAQ-paren per blog
- Elk antwoord zelfstandig (snapt zonder de blog te lezen)
- Exacte zoekfrasering gebruiken
- Front-load het antwoord, Google extraheert de eerste zin voor featured snippets
- Niet letterlijk herhalen uit de blog-body

Skip FAQ voor pure architectuur-deep-dives of thought leadership-stukken waar het niet past.

### 6. CTA

Eindig met één duidelijke call-to-action. Type CTA hangt af van de pillar en het doel: lees uit `brand-voice.md` of vraag expliciet bij de gebruiker.

### 7. Series-links (indien van toepassing)

Verwijs onderaan naar andere posts in dezelfde reeks.

## Image-placeholders

Plaats afbeelding-placeholders waar visuals de content versterken:

```markdown
![Beschrijvende alt-tekst](images/beschrijvende-bestandsnaam.png "Optionele caption")
```

Plaats afbeeldingen:

- Na de opening-sectie (cover wordt apart afgehandeld)
- Voor of na sleutel-concepten die baat hebben bij visuele uitleg
- Bij data/statistieken: stel een grafiek voor
- Bij processen: stel een flowchart voor
- Bij vergelijkingen: stel een tabel voor

Schrijf de alt-tekst alsof de afbeelding al bestaat.

## Schrijfstijl

Lees `../brand-voice.md` voor de exacte voorkeuren van deze gebruiker. Generieke baseline-regels als die ontbreken:

### Toon

- 1e persoon ("ik", "mijn ervaring") of "wij", check brand-voice
- Spreek de lezer direct aan met "je" (informeel) of "u" (formeel), check brand-voice
- Conversationeel maar autoritatief
- Korte zinnen, actieve werkwoorden
- Concrete getallen boven vage claims ("47% besparing" niet "aanzienlijke besparing")

### Doelgroep-aanpassing

**Niet-technische doelgroep (ondernemers, marketeers, kenniswerkers):**

- Begin met voordelen en toepassingen, niet met technologie
- Technische begrippen vertalen in één bijzin
- Vergelijk altijd met wat de lezer kent
- Pijnpunten expliciet noemen
- Structuur: voordelen eerst, dan toepassingen, dan uitleg, dan eigen ervaring
- Vermijd jargon, parameters, benchmarknamen zonder context

**Technische doelgroep (developers, architecten, technische beslissers):**

- Diepgang verwacht: diagrammen, code, benchmarks
- Proof of work via GitHub, concrete metrics, commit history
- Toon: peer-to-peer
- Jargon is prima

### SEO best practices

- Primair keyword in de eerste 100 woorden
- Primair keyword in minstens één H2
- Secundair keywords natuurlijk in H2/H3
- Interne links naar andere blog-posts (relatieve paden of volle URLs, check pipeline)
- Korte alinea's (max 3-4 zinnen)
- Bullets en numbered lists voor scanbaarheid
- Meta-description-waardige zin in de opening

### Word count targets

- **Pillar page**: 2000-3000 woorden
- **Supporting article**: 800-1500 woorden
- **How-to guide**: 1000-2000 woorden
- **Thought leadership**: 1000-1800 woorden

Vraag de gebruiker welk type als het niet duidelijk is.

## Workflow

1. **Lees** `../brand-voice.md` (verplicht, eerste actie)
2. **Vraag** de gebruiker (of de cockpit) het topic, target keyword, type, en eventuele bronnen als die niet in de prompt zaten
3. **Status**: `cockpit msg status "brand-voice gelezen, start onderzoek"`
4. **Onderzoek** kort (zoek-tools indien beschikbaar) voor FAQ-vragen, competitor-gaps, ontbrekende datapunten
5. **Outline** de structuur en deel met de gebruiker voor goedkeuring via `cockpit msg question`
6. **Schrijf** de volledige post als `.md` met complete frontmatter
7. **Voeg FAQ/HowTo toe** waar aanbevolen (5-8 Q&A-paren)
8. **Sla op** in `$CLAUDE_LAUNCHER_HOME/output/YYYY-MM-DD-<slug>.md`
9. **Markeer image-placeholders** voor een eventuele images-skill
10. **Lever op**: `cockpit msg deliver <pad> --format markdown`
11. **Done**: `cockpit msg done "<woordental> woorden, <type>, klaar voor review"`

## Wat NIET doen

- Niet publiceren naar live-systemen zonder expliciete bevestiging
- Geen verzonnen statistieken: als je een getal noemt, leg uit waar het vandaan komt
- Geen AI-cliches (zie `brand-voice.md` voor de anti-lijst)
- Geen em-dashes
- Geen mock-content met `TODO` of `[fill in]`: werk af of stel een vraag
