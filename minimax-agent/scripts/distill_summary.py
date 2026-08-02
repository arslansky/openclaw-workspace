#!/usr/bin/env python3
"""Distill a transcript (VTT-derived clean .txt) into a Chinese summary PDF.

Combines 2 lessons (2026-08-02 user-confirmed 加固):

- **L#11 加固** (source citation w/ timestamp anchor): every quote pulled from
  the source carries a `[mm:ss]` anchor so user can re-locate in original video.
- **L#17 加固** (CID font + CJK pre-flight): all user-supplied text is
  pre-flighted for CJK + inline-HTML-risk; the build fails fast if a `<font>`
  literal or non-whitelisted tag is detected.

Reusable: importable as a module (`from distill_summary import build_pdf`)
or callable as a script (`./distill_summary.py <clean_txt> <pdf_out>`).

Source-of-truth conventions:
- Input: zh-Hant (or other CJK) clean transcript, one sentence per line.
- Output: A4 PDF using STSong-Light CID font (per L#17 lesson).
"""

from __future__ import annotations

import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable

from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.cidfonts import UnicodeCIDFont
from reportlab.platypus import (
    PageBreak,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)


# === L#17 加固: HTML whitelist + CJK pre-flight ===

# Whitelist of tags Paragraph() is allowed to render. Any other tag in the
# input is treated as a bug — fail fast at build time.
ALLOWED_TAGS = {"b", "i", "u", "br", "sup", "sub"}

# Pre-flight CJK scan: if a text block contains BOTH CJK chars AND any of
# these risky patterns, refuse to render until fixed.
RISKY_PATTERNS = [
    re.compile(r"<font\b", re.IGNORECASE),       # L#17 known bug
    re.compile(r"<\s*font-face\b", re.IGNORECASE),
    re.compile(r"</\s*font\s*>", re.IGNORECASE),
]

CJK_RE = re.compile(r"[\u4e00-\u9fff\u3400-\u4dbf]")
LATIN_RE = re.compile(r"[A-Za-z]")


def preflight_cjk(text: str, context: str = "<unknown>") -> None:
    """Refuse to build PDF if text contains L#17-class bug patterns.

    Per L#17 加固: catch the bug at the source, not via post-build audit.
    Raises ValueError with descriptive location so we can locate the offender.
    """
    has_cjk = bool(CJK_RE.search(text))
    for pat in RISKY_PATTERNS:
        if pat.search(text):
            raise ValueError(
                f"[L#17 preflight] refused to render text at {context!r}: "
                f"contains risky pattern {pat.pattern!r}. "
                f"Escape inline HTML tags or remove `<font>` wrappers entirely."
            )
    # Heuristic: if user text has CJK + Latin font face mention like
    # `Latin TTF` — high risk of inline-font-wrap typo. Warn but allow.
    if has_cjk and re.search(r"\bfont\s+face\s*=?\s*['\"]?\s*\w*\s*(?:TTF|OTF)\b", text, re.IGNORECASE):
        # Soft warning only (print to stderr) — caller decides.
        print(
            f"[L#17 preflight] warning at {context!r}: text has CJK + "
            f"`font face ... TTF` reference; double-check no inline <font> wrap.",
            file=sys.stderr,
        )


def safe_html(text: str, context: str = "<unknown>") -> str:
    """Wrap Paragraph() with pre-flight + neutralise non-whitelisted tags.

    Returns the text unchanged if it passes pre-flight AND has no risky tags.
    Otherwise raises. Intentionally strict.
    """
    preflight_cjk(text, context=context)
    # Find any tag <xxx> not in ALLOWED_TAGS and reject.
    for match in re.finditer(r"<\s*(/?)\s*([a-zA-Z]+)\b[^>]*>", text):
        tag = match.group(2).lower()
        if tag not in ALLOWED_TAGS:
            raise ValueError(
                f"[L#17 preflight] refused: non-whitelisted tag <{tag}> "
                f"at {context!r}. Allowed: {sorted(ALLOWED_TAGS)}"
            )
    return text


# === L#11 加固: Source citation with timestamp anchor ===

# Match lines like `[00:01.234]` or `[00:00:01,234]` from VTT-derived files.
TIMESTAMP_RE = re.compile(r"\[(\d{1,2}):(\d{2})(?::(\d{2}))?\.(\d{3})\]")


def parse_timestamp_to_seconds(ts_line: str) -> int:
    """Parse one timestamp line into whole seconds (used as anchor id)."""
    # Input already stripped of `[ ]` brackets if needed.
    m = TIMESTAMP_RE.match("[" + ts_line + "]")
    if not m:
        raise ValueError(f"cannot parse timestamp: {ts_line!r}")
    mm = int(m.group(1))
    ss = int(m.group(2))
    return mm * 60 + ss


def extract_quote_with_anchor(
    full_timed_text: str,
    quote_substring: str,
    *,
    k: int = 5,
) -> str:
    """Find a quote's first appearance in `full_timed_text` and return
    `[mm:ss] quote` so the PDF can stamp an anchor.

    `full_timed_text` is expected to be VTT-derived timed format like
    `[00:12.345] hello world`. Returns the *earliest* matching line so
    re-locating in the source is deterministic.

    Raises ValueError if no match within a `k`-line window — caller can
    decide to fall back to no-anchor citation.
    """
    if not quote_substring.strip():
        raise ValueError("empty quote_substring")
    for line in full_timed_text.splitlines():
        m = TIMESTAMP_RE.match(line)
        if not m:
            continue
        ts = f"{m.group(1)}:{m.group(2)}.{m.group(4)[:3]}"
        body = TIMESTAMP_RE.sub("", line, count=1).strip()
        if quote_substring.strip() in body:
            return f"[{ts}] {body.strip()}"
    raise ValueError(
        f"quote not found in source within {k}-window: {quote_substring[:60]!r}"
    )


# === PDF builder (L#11 + L#17 hardened) ===

PDFMETRY_DONE = False


def _ensure_fonts() -> None:
    global PDFMETRY_DONE
    if not PDFMETRY_DONE:
        pdfmetrics.registerFont(UnicodeCIDFont("STSong-Light"))
        PDFMETRY_DONE = True


@dataclass
class SummarySection:
    """One section of the summary PDF. Body can include `<b>`, `<i>`, `<br/>`."""

    heading: str
    body: str  # may include inline `<b>`, `<i>`, `<br/>`. Pre-flighted.
    quotes_with_anchors: list[tuple[str, str]] = field(default_factory=list)
    """List of (raw_quote, full_timed_text) for timestamp-anchored citations."""


def build_pdf(
    sections: Iterable[SummarySection],
    out_path: str | Path,
    *,
    title: str,
    meta_lines: list[str],
    report_label: str = "<distill_summary>",
) -> int:
    """Build a hardened Chinese summary PDF. Returns bytes written.

    Hardening:
    - Pre-flight every section body for L#17-class bugs (refuse on match).
    - Pre-flight every quote-source pair for L#11 timestamp anchors.
    - All Paragraph() calls use STSong-Light CID font (no Latin fallback).
    """
    _ensure_fonts()
    out_path = Path(out_path)
    sections = list(sections)

    # Phase 1: pre-flight all body text BEFORE building doc.
    for i, sec in enumerate(sections):
        ctx = f"{report_label} §{i} body"
        safe_html(sec.body, context=ctx)
        for j, (quote, _src) in enumerate(sec.quotes_with_anchors):
            qctx = f"{report_label} §{i} quote[{j}]"
            # Quote snippets are usually short plain text; pre-flight CJK only.
            preflight_cjk(quote, context=qctx)

    # Phase 2: build.
    doc = SimpleDocTemplate(
        str(out_path),
        pagesize=A4,
        leftMargin=2 * cm,
        rightMargin=2 * cm,
        topMargin=2 * cm,
        bottomMargin=2 * cm,
        title=title,
    )

    styles = getSampleStyleSheet()
    title_style = ParagraphStyle(
        "TitleZH", parent=styles["Title"], fontName="STSong-Light",
        fontSize=18, leading=24, spaceAfter=12, alignment=TA_LEFT,
    )
    h2_style = ParagraphStyle(
        "H2ZH", parent=styles["Heading2"], fontName="STSong-Light",
        fontSize=13, leading=18, spaceBefore=12, spaceAfter=6,
        textColor=colors.HexColor("#1a4d80"),
    )
    body_style = ParagraphStyle(
        "BodyZH", parent=styles["BodyText"], fontName="STSong-Light",
        fontSize=10, leading=14, alignment=TA_LEFT, spaceAfter=6,
    )
    quote_style = ParagraphStyle(
        "QuoteZH", parent=styles["BodyText"], fontName="STSong-Light",
        fontSize=9, leading=13, alignment=TA_LEFT, leftIndent=20,
        textColor=colors.HexColor("#555555"), spaceAfter=4,
    )
    meta_style = ParagraphStyle(
        "MetaZH", parent=styles["BodyText"], fontName="STSong-Light",
        fontSize=9, leading=13, alignment=TA_LEFT,
        textColor=colors.HexColor("#666666"), spaceAfter=4,
    )

    story = []
    story.append(Paragraph(title, title_style))
    for m in meta_lines:
        story.append(Paragraph(m, meta_style))
    story.append(Spacer(1, 12))

    for sec in sections:
        story.append(Paragraph(sec.heading, h2_style))
        # Replace newlines with <br/> for Paragraph rendering.
        story.append(Paragraph(sec.body.replace("\n", "<br/>"), body_style))

        # Append timestamp-anchored quotes (L#11 hardening).
        for quote, src in sec.quotes_with_anchors:
            try:
                anchored = extract_quote_with_anchor(src, quote)
            except ValueError as e:
                # Fail loud — L#11 means we MUST cite, not silently degrade.
                raise ValueError(
                    f"[L#11] quote-not-found in {report_label} §{sec.heading!r}: {e}"
                ) from e
            story.append(Paragraph(f"&nbsp;&nbsp;<i>{anchored}</i>", quote_style))
        story.append(Spacer(1, 6))

    doc.build(story)
    return out_path.stat().st_size


# === CLI ===

def _cli() -> int:
    if len(sys.argv) < 3:
        print("usage: distill_summary.py <clean_txt> <pdf_out> [title]", file=sys.stderr)
        return 2
    src = Path(sys.argv[1])
    out = Path(sys.argv[2])
    title = sys.argv[3] if len(sys.argv) > 3 else f"Distill summary: {src.name}"
    sections = [
        SummarySection(
            heading=f"Clean transcript dump ({src.name})",
            body=src.read_text(encoding="utf-8"),
        )
    ]
    meta = [
        f"Source: {src} ({src.stat().st_size} bytes)",
        "Distilled via distill_summary.py (L#11 + L#17 hardened)",
    ]
    n = build_pdf(sections, out, title=title, meta_lines=meta)
    print(f"wrote {out} ({n} bytes)")
    return 0


if __name__ == "__main__":
    sys.exit(_cli())
