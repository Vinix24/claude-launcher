# claude-launcher

> Vijf experts in mijn cockpit. Eén instructie volstaat.

Een lichte orchestrator bovenop Claude Code. Eén centrale cockpit-sessie waar ik werkers in spawn voor voor-geconfigureerde workspaces (marketing, sales, finance, etc.). Elke werker heeft domeinspecifieke skills en rapporteert resultaten terug.

Geen copy-paste tussen tabs. Geen brand-voice opnieuw uitleggen. Geen prompt-engineering-werk meer in mijn hoofd.

## Status

Dit is **v0.0** — een leuk speeltje, geen polished product. Bewust rauwe randjes, bewust open source, bewust local-first.

Volledige README volgt in commit 7. Voor nu: zie `docs/PRD.md` voor de productspec.

## Vereisten

- macOS
- tmux
- Python 3.10+
- Node 18+ (voor de output-skills docx en pptx)
- Claude Code CLI (`claude`)

## Snelle install

Komt in commit 7:

```bash
curl -fsSL https://raw.githubusercontent.com/Vinix24/claude-launcher/main/install.sh | bash
```

## License

MIT. Zie [LICENSE](LICENSE).
