#!/usr/bin/env python3
"""Preflight tool-outline files before OpenSCAD import().

OpenSCAD cannot turn a missing import() into an assert. This script names the
slot. Paths are relative to the Boxes directory (the .scad file's directory).
No arguments means no enabled slot: exit 0.
"""
from __future__ import annotations

import argparse
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


SEGMENT_WARN = 2000


def boxes_dir() -> Path:
    return Path(__file__).resolve().parents[1]


def _local(tag: str) -> str:
    return tag.rsplit("}", 1)[-1]


def _length_mm(text: str, dpi: float) -> float | None:
    raw = text.strip()
    mm = re.fullmatch(r"([+-]?\d+(?:\.\d+)?)\s*mm", raw, flags=re.IGNORECASE)
    if mm:
        return float(mm.group(1))
    px = re.fullmatch(r"([+-]?\d+(?:\.\d+)?)(?:\s*px)?", raw, flags=re.IGNORECASE)
    if px:
        return float(px.group(1)) * 25.4 / dpi
    return None


def svg_size_mm(path: Path, dpi: float) -> tuple[float, float]:
    root = ET.parse(path).getroot()
    if _local(root.tag) != "svg":
        raise ValueError("root is not svg")
    width = root.attrib.get("width")
    height = root.attrib.get("height")
    if width is None or height is None:
        raise ValueError("svg has no width/height")
    w = _length_mm(width, dpi)
    h = _length_mm(height, dpi)
    if w is None or h is None:
        raise ValueError(f"svg width/height {width!r} {height!r} are not mm or px")
    return w, h


def svg_segments(path: Path) -> int:
    root = ET.parse(path).getroot()
    count = 0
    for el in root.iter():
        d = el.attrib.get("d")
        if not d:
            continue
        count += len(re.findall(r"[MLCQTAHVZ]", d, flags=re.IGNORECASE))
    return count


def _pairs(text: str) -> list[tuple[str, str]]:
    lines = text.splitlines()
    out = []
    i = 0
    while i + 1 < len(lines):
        out.append((lines[i].strip(), lines[i + 1].strip()))
        i += 2
    return out


def dxf_size_mm(path: Path) -> tuple[float, float]:
    pairs = _pairs(path.read_text(encoding="utf-8", errors="replace"))
    saw_polyline = False
    xs: list[float] = []
    ys: list[float] = []
    closed = False
    in_poly = False
    for code, val in pairs:
        if code == "0" and val == "POLYLINE":
            saw_polyline = True
        if code == "0" and val == "LWPOLYLINE":
            in_poly = True
            continue
        if code == "0" and in_poly and val not in ("VERTEX", "SEQEND"):
            in_poly = False
        if not in_poly:
            continue
        if code == "10":
            xs.append(float(val))
        elif code == "20":
            ys.append(float(val))
        elif code == "70" and val not in ("0",):
            closed = True
    if saw_polyline and not xs:
        raise ValueError("DXF needs a closed LWPOLYLINE, found POLYLINE")
    if not xs or not ys:
        raise ValueError("DXF needs a closed LWPOLYLINE")
    if not closed:
        raise ValueError("DXF LWPOLYLINE is not closed")
    return max(xs) - min(xs), max(ys) - min(ys)


def check_slot(
    slot: int,
    enabled: bool,
    file_rel: str,
    width: float | None,
    height: float | None,
    dpi: float,
    root: Path | None = None,
) -> tuple[int, list[str]]:
    """Return (exit code, lines). Warnings alone stay at 0."""
    if not enabled:
        return 0, []
    root = root or boxes_dir()
    path = Path(file_rel)
    if not path.is_absolute():
        path = root / file_rel
    lines: list[str] = []
    if not path.is_file():
        return 2, [f"tool slot {slot}: file not found: {file_rel}"]
    suffix = path.suffix.lower()
    try:
        if suffix == ".svg":
            got_w, got_h = svg_size_mm(path, dpi)
            segments = svg_segments(path)
        elif suffix == ".dxf":
            got_w, got_h = dxf_size_mm(path)
            segments = 0
        else:
            return 2, [f"tool slot {slot}: not an svg or dxf: {file_rel}"]
    except (ET.ParseError, OSError, ValueError) as exc:
        return 2, [f"tool slot {slot}: {exc}"]
    if segments > SEGMENT_WARN:
        lines.append(f"tool slot {slot}: {segments} path segments, simplify in Inkscape")
    if width is None or height is None:
        lines.append(f"tool slot {slot}: file is {got_w:.1f} x {got_h:.1f} mm, Customizer size was not given")
        return 2, lines
    if abs(got_w - width) > 0.5 or abs(got_h - height) > 0.5:
        lines.append(
            f"tool slot {slot}: file is {got_w:.1f} x {got_h:.1f} mm, "
            f"Customizer says {width:.1f} x {height:.1f} mm"
        )
        return 2, lines
    return 0, lines


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Check one enabled tool-outline file.")
    parser.add_argument("--slot", type=int)
    parser.add_argument("--enabled", action="store_true")
    parser.add_argument("--file", default="")
    parser.add_argument("--width", type=float)
    parser.add_argument("--height", type=float)
    parser.add_argument("--dpi", type=float, default=25.4)
    args = parser.parse_args(argv)
    if args.slot is None and not args.enabled and not args.file:
        return 0
    slot = args.slot if args.slot is not None else 1
    code, lines = check_slot(slot, args.enabled, args.file, args.width, args.height, args.dpi)
    for line in lines:
        print(line)
    return code


if __name__ == "__main__":
    sys.exit(main())
