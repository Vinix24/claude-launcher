#!/usr/bin/env python3
"""
md2docx.py — convert a markdown file into a docx via python-docx.

Usage:
  python3 md2docx.py <input.md> <output.docx>

Supports: H1/H2/H3, paragraphs, bold, italic, bullets, numbered lists,
horizontal rules. YAML frontmatter at the top of the file is stripped.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

try:
    from docx import Document
    from docx.shared import Pt
except ImportError:
    sys.exit(
        "python-docx ontbreekt. Installeer met:\n    pip3 install python-docx"
    )


FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---\n", re.DOTALL)
BOLD_RE = re.compile(r"\*\*(.+?)\*\*")
ITALIC_RE = re.compile(r"(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)")
BULLET_RE = re.compile(r"^[-*+]\s+(.*)")
NUMBERED_RE = re.compile(r"^(\d+)\.\s+(.*)")
HEADING_RE = re.compile(r"^(#{1,6})\s+(.*)")
HR_RE = re.compile(r"^---\s*$|^\*\*\*\s*$|^___\s*$")


def strip_frontmatter(text: str) -> str:
    return FRONTMATTER_RE.sub("", text, count=1)


def add_runs(paragraph, text: str) -> None:
    """Parse inline bold/italic and add runs to the paragraph."""
    parts: list[tuple[str, set[str]]] = [(text, set())]

    def split(parts, regex, style):
        out: list[tuple[str, set[str]]] = []
        for chunk, styles in parts:
            if style in styles:
                out.append((chunk, styles))
                continue
            idx = 0
            for m in regex.finditer(chunk):
                if m.start() > idx:
                    out.append((chunk[idx:m.start()], styles))
                out.append((m.group(1), styles | {style}))
                idx = m.end()
            if idx < len(chunk):
                out.append((chunk[idx:], styles))
        return out

    parts = split(parts, BOLD_RE, "bold")
    parts = split(parts, ITALIC_RE, "italic")

    for chunk, styles in parts:
        if not chunk:
            continue
        run = paragraph.add_run(chunk)
        if "bold" in styles:
            run.bold = True
        if "italic" in styles:
            run.italic = True


def convert(md_path: Path, docx_path: Path) -> None:
    text = md_path.read_text(encoding="utf-8")
    text = strip_frontmatter(text)

    doc = Document()
    # baseline document defaults
    style = doc.styles["Normal"]
    style.font.name = "Calibri"
    style.font.size = Pt(11)

    in_list = False
    for raw_line in text.splitlines():
        line = raw_line.rstrip()

        if not line.strip():
            in_list = False
            continue

        if HR_RE.match(line):
            doc.add_page_break()
            continue

        m = HEADING_RE.match(line)
        if m:
            level = min(len(m.group(1)), 3)
            p = doc.add_heading(level=level)
            add_runs(p, m.group(2))
            continue

        m = BULLET_RE.match(line)
        if m:
            p = doc.add_paragraph(style="List Bullet")
            add_runs(p, m.group(1))
            in_list = True
            continue

        m = NUMBERED_RE.match(line)
        if m:
            p = doc.add_paragraph(style="List Number")
            add_runs(p, m.group(2))
            in_list = True
            continue

        p = doc.add_paragraph()
        add_runs(p, line)

    docx_path.parent.mkdir(parents=True, exist_ok=True)
    doc.save(docx_path)


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit("usage: md2docx.py <input.md> <output.docx>")

    md_path = Path(sys.argv[1]).expanduser().resolve()
    docx_path = Path(sys.argv[2]).expanduser().resolve()

    if not md_path.exists():
        sys.exit(f"input bestaat niet: {md_path}")

    convert(md_path, docx_path)
    print(f"OK: {md_path.name} -> {docx_path}")


if __name__ == "__main__":
    main()
