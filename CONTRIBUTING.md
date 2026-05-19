# Contributing

claude-launcher is een hobby-project van Vincent van Deth. Bijdragen zijn welkom maar niet verplicht, en de scope wordt strikt bewaakt.

## Wat ik wel accepteer

- Nieuwe skills voor bestaande workspaces (zie `templates/workspaces/<workspace>/.claude/skills/`)
- Bugfixes in de launcher CLI of het inbox-protocol
- Documentatie-verbeteringen
- Compatibility-fixes voor latere macOS-versies

## Wat ik niet accepteer

- Audit-trail of governance-features (zie [VNX Orchestration](https://github.com/Vinix24/vnx-orchestration) voor dat soort werk)
- Multi-track agent-hiërarchie
- Cloud-backend of telemetry
- Enterprise IAM/SSO
- Eigen LLM-routing (`claude` CLI subprocess is de enige route)
- Anthropic SDK-imports (cli-only constraint)

## PR-eisen

- Eén PR per feature
- Skill-PR's: complete `SKILL.md` met `description`, voorbeelden, en geen hardgecodeerde persoonsnamen
- Geen secrets, geen API-keys, geen `.env`-bestanden
- Output-skills: gebruik MIT/BSD-libraries, geen GPL

## Stijl

Markdown in dit project: Nederlandse documentatie waar relevant, Engelse code-comments, geen em-dashes, 1e persoon enkelvoud in user-facing tekst.

## Vraag of bug

Open een issue. Korte titel, één-regel-beschrijving, stappen om te reproduceren.
