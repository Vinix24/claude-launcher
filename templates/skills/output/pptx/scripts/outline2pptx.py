#!/usr/bin/env python3
"""
outline2pptx.py — convert a slide outline (markdown with --- separators)
into a PowerPoint deck via python-pptx.

Usage:
  python3 outline2pptx.py <input.md> <output.pptx>

Outline format:
  - Slides are separated by `---` on its own line.
  - First slide is the title slide: `# Title` + optional meta lines (subtitle).
  - Subsequent slides: `# Title` + bullets (`- ...`) or paragraphs.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

try:
    from pptx import Presentation
    from pptx.util import Inches, Pt
except ImportError:
    sys.exit(
        "python-pptx ontbreekt. Installeer met:\n    pip3 install python-pptx"
    )


SEP_RE = re.compile(r"^---\s*$")
TITLE_RE = re.compile(r"^#\s+(.*)")
BULLET_RE = re.compile(r"^[-*+]\s+(.*)")


def parse_outline(text: str) -> list[dict]:
    """Split the outline into a list of slide dicts."""
    slides: list[dict] = []
    current: list[str] = []

    for line in text.splitlines():
        if SEP_RE.match(line):
            if current:
                slides.append(_build_slide(current))
                current = []
        else:
            current.append(line)
    if current:
        slides.append(_build_slide(current))
    return slides


def _build_slide(lines: list[str]) -> dict:
    title = ""
    meta_lines: list[str] = []
    bullets: list[str] = []

    seen_title = False
    for line in lines:
        stripped = line.rstrip()
        if not stripped.strip():
            continue
        if not seen_title:
            m = TITLE_RE.match(stripped)
            if m:
                title = m.group(1).strip()
                seen_title = True
                continue
        m = BULLET_RE.match(stripped)
        if m:
            bullets.append(m.group(1).strip())
        else:
            meta_lines.append(stripped.strip())

    return {"title": title, "meta": meta_lines, "bullets": bullets}


def build_pptx(slides: list[dict], output_path: Path) -> None:
    prs = Presentation()
    prs.slide_width = Inches(13.33)   # 16:9 widescreen
    prs.slide_height = Inches(7.5)

    title_layout = prs.slide_layouts[0]
    content_layout = prs.slide_layouts[1]
    section_layout = prs.slide_layouts[2] if len(prs.slide_layouts) > 2 else prs.slide_layouts[5]

    for idx, slide_data in enumerate(slides):
        is_first = (idx == 0)
        has_bullets = bool(slide_data["bullets"])

        if is_first:
            layout = title_layout
        elif has_bullets:
            layout = content_layout
        else:
            layout = section_layout

        slide = prs.slides.add_slide(layout)

        if slide.shapes.title is not None:
            slide.shapes.title.text = slide_data["title"] or ""
            for para in slide.shapes.title.text_frame.paragraphs:
                for run in para.runs:
                    run.font.size = Pt(40) if is_first else Pt(32)

        # subtitle / meta for title slide
        if is_first and slide_data["meta"]:
            for ph in slide.placeholders:
                if ph.placeholder_format.idx == 1:
                    ph.text = "\n".join(slide_data["meta"])
                    for para in ph.text_frame.paragraphs:
                        for run in para.runs:
                            run.font.size = Pt(18)
                    break

        # bullets for content slide
        if has_bullets and not is_first:
            body = None
            for ph in slide.placeholders:
                if ph.placeholder_format.idx == 1:
                    body = ph
                    break
            if body is not None:
                tf = body.text_frame
                tf.text = slide_data["bullets"][0]
                tf.paragraphs[0].font.size = Pt(20)
                for bullet in slide_data["bullets"][1:]:
                    p = tf.add_paragraph()
                    p.text = bullet
                    p.font.size = Pt(20)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    prs.save(output_path)


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit("usage: outline2pptx.py <input.md> <output.pptx>")

    md_path = Path(sys.argv[1]).expanduser().resolve()
    pptx_path = Path(sys.argv[2]).expanduser().resolve()

    if not md_path.exists():
        sys.exit(f"input bestaat niet: {md_path}")

    text = md_path.read_text(encoding="utf-8")
    slides = parse_outline(text)
    if not slides:
        sys.exit("geen slides gevonden in outline")

    build_pptx(slides, pptx_path)
    print(f"OK: {len(slides)} slides -> {pptx_path}")


if __name__ == "__main__":
    main()
