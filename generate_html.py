#!/usr/bin/env python3
"""Generate an HTML5 document from XML data and an XSLT template."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path


def _resolve_css_path(css_ref: str, xml_path: Path, xslt_path: Path) -> Path | None:
    """Resolve a CSS path declared in XML, supporting absolute and relative paths."""
    candidate = Path(css_ref).expanduser()
    if candidate.is_absolute() and candidate.exists():
        return candidate

    search_roots = [
        xml_path.parent,
        xslt_path.parent,
        Path.cwd(),
    ]
    for root in search_roots:
        resolved = (root / candidate).resolve()
        if resolved.exists():
            return resolved
    return None


def _inline_css(output_doc, xml_doc, xml_path: Path, xslt_path: Path) -> None:
    """Inline the CSS referenced by /report/meta/theme/@css into the HTML <head>."""
    try:
        from lxml import etree
    except ImportError:
        return

    css_ref = xml_doc.xpath("string(/report/meta/theme/@css)").strip()
    if not css_ref:
        return

    css_path = _resolve_css_path(css_ref, xml_path, xslt_path)
    if css_path is None:
        raise FileNotFoundError(
            f"CSS file referenced in XML not found: {css_ref}"
        )

    css_content = css_path.read_text(encoding="utf-8")

    html_root = output_doc.getroot()
    if html_root is None:
        return

    head = html_root.find("head")
    if head is None:
        return

    for link in list(head.findall("link")):
        rel = (link.get("rel") or "").strip().lower()
        if rel == "stylesheet":
            head.remove(link)

    style = etree.Element("style")
    style.set("data-inline-source", str(css_path))
    style.text = "\n" + css_content + "\n"
    head.append(style)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Generate an HTML file from XML + XSLT.",
    )
    parser.add_argument(
        "--xml",
        required=True,
        help="Path to the XML data file.",
    )
    parser.add_argument(
        "--xslt",
        required=True,
        help="Path to the XSLT template file.",
    )
    parser.add_argument(
        "--out",
        required=True,
        help="Path to the generated HTML output file.",
    )
    return parser


def generate(xml_path: Path, xslt_path: Path, out_path: Path) -> None:
    try:
        from lxml import etree
    except ImportError as exc:
        raise RuntimeError(
            "Missing dependency: lxml. Install it with: pip install lxml"
        ) from exc

    if not xml_path.exists():
        raise FileNotFoundError(f"XML file not found: {xml_path}")
    if not xslt_path.exists():
        raise FileNotFoundError(f"XSLT file not found: {xslt_path}")

    xml_doc = etree.parse(str(xml_path))
    xslt_doc = etree.parse(str(xslt_path))
    transform = etree.XSLT(xslt_doc)
    output_doc = transform(xml_doc)
    _inline_css(output_doc, xml_doc, xml_path, xslt_path)

    out_path.parent.mkdir(parents=True, exist_ok=True)
    html_bytes = etree.tostring(
        output_doc,
        pretty_print=True,
        method="html",
        encoding="utf-8",
        doctype="<!DOCTYPE html>",
    )
    out_path.write_bytes(html_bytes)


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    xml_path = Path(args.xml).expanduser().resolve()
    xslt_path = Path(args.xslt).expanduser().resolve()
    out_path = Path(args.out).expanduser().resolve()

    try:
        generate(xml_path, xslt_path, out_path)
    except Exception as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1

    print(f"OK: HTML generated -> {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
