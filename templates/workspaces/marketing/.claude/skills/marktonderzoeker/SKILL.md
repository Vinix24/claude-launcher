---
name: marktonderzoeker
description: >
  Use this skill when the user asks for "marktonderzoek", "doelgroepanalyse",
  "target audience research", "kooptriggers", "klantpijnen", or wants to understand
  their ideal customer profile, buying triggers, and market dynamics.
---

# Marktonderzoeker

Research de doelgroep en bouw een compleet beeld van de ideale klant. Lees eerst `../brand-voice.md` voor de positionering en het ICP-fundament.

## Input

- Business-info van de gebruiker (sector, product/dienst, eventuele bestaande klanten)
- Diepte-niveau (Simpel of Uitgebreid)
- Optionele bronnen: bestaande klantinterviews, sales-data, eerder onderzoek

## Output-locatie

Schrijf naar `$CLAUDE_LAUNCHER_HOME/output/YYYY-MM-DD-marktonderzoek-<topic>.md`. Lever op met `cockpit msg deliver <pad> --format markdown`.

## Deliverables

### Doelgroepprofiel

- Demographics (leeftijd, functie, bedrijfsgrootte, sector)
- Online gedrag (waar consumeren ze content, welke platforms)
- Beslissingsproces (wie beslist, hoe lang duurt het, wie beïnvloedt)

### Pijnen en frustraties

- Identificeer de belangrijkste pijnen met onderbouwing
- Rangschik op impact (welke pijn kost het meest, financieel of mentaal)
- Beschrijf hoe de pijn zich uit in dagelijks werk

### Behoeften en wensen

- Wat willen ze bereiken (outcomes, niet features)
- Wat is de droom-situatie
- Verschil tussen wat ze zeggen te willen en wat ze echt nodig hebben

### Kooptriggers

- Welke events of momenten zetten hen aan tot actie
- Seizoensgebonden triggers
- Pain threshold: wanneer wordt het urgent genoeg om te handelen

### Kanalen en communities

- Waar bevinden ze zich online
- Welke events/conferenties bezoeken ze
- Wie volgen ze, wie beïnvloedt hen

### Verwachte bezwaren

- Lijst van redenen waarom ze NIET zouden kopen
- Rangschik van meest naar minst voorkomend
- Noteer de onderliggende angst achter elk bezwaar

## Toon

Schrijf als een onderzoeker die bevindingen presenteert. Feitelijk, specifiek, evidence-based. Geen vage claims. Als iets een aanname is, label het expliciet als "aanname" en geef aan hoe je het zou kunnen valideren.

## Diepte-niveau

**Simpel (~600-800 woorden):**

- 1 doelgroep-segment, hoofdpijnen, top-5 kooptriggers, 3-5 bezwaren
- Geschikt voor snelle validatie of een eerste pitch

**Uitgebreid (~1500-2500 woorden):**

- 2-3 doelgroep-segmenten met aparte profielen
- Pijnen + behoeften + triggers + kanalen + bezwaren per segment
- Bronnen en aannames expliciet
- Aanbevolen onderzoeksvolgvragen onderaan

## Workflow

1. **Lees** `../brand-voice.md` voor positionering en bestaande ICP-aannames
2. **Status**: `cockpit msg status "brand-voice gelezen, start research"`
3. **Vraag** als info ontbreekt: sector, product, bestaande klanten, niveau
4. **Onderzoek** (zoek-tools indien beschikbaar) en collect concrete signalen
5. **Markeer** aannames apart van geverifieerde claims
6. **Schrijf** het rapport in markdown
7. **Sla op** in `$CLAUDE_LAUNCHER_HOME/output/YYYY-MM-DD-marktonderzoek-<topic>.md`
8. **Lever op**: `cockpit msg deliver <pad> --format markdown`
9. **Done**: `cockpit msg done "marktonderzoek klaar voor [topic], [niveau], [woordental] woorden"`

## Cross-reference

Dit is de eerste rol in een marketing-pipeline. Er zijn nog geen eerdere outputs om naar te verwijzen. Flag wel actief welke aanvullende info je nodig hebt van de gebruiker voordat vervolgrollen (positionering, copywriting, lead-magnets) zinvol verder kunnen.
