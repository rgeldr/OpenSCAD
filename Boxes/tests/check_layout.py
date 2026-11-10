#!/usr/bin/env python3
"""Geometry checks on rendered rugged-box STLs.

Bottom print frame: floor on z=0, opening at z=boxBottomHeight (32 with defaults).
Preset 2 on a 160x60 interior places a Y wall at y=26 and X walls at x=101.2 and x=120.4.
Divider tips are 0.5 mm under the opening. Closed, the lid tips sit 1.1 mm above the bottom tips.
"""
from __future__ import annotations

import sys
from typing import List, Sequence, Tuple

from check_overhangs import _cross, _norm, _sub, load_triangles

Tri = Tuple[Tuple[float, float, float], Tuple[float, float, float], Tuple[float, float, float]]


def _up_faces(tris: Sequence[Tri], z_lo: float, z_hi: float) -> List[Tuple[float, float, float]]:
    found = []
    for a, b, c in tris:
        n = _norm(_cross(_sub(b, a), _sub(c, a)))
        if n[2] < 0.9:
            continue
        cx = (a[0] + b[0] + c[0]) / 3.0
        cy = (a[1] + b[1] + c[1]) / 3.0
        cz = (a[2] + b[2] + c[2]) / 3.0
        if z_lo <= cz <= z_hi and 4 < cx < 160 and 4 < cy < 60:
            found.append((cx, cy, cz))
    return found


def _near(faces, x=None, y=None, tol=1.5) -> List[Tuple[float, float, float]]:
    out = []
    for cx, cy, cz in faces:
        if x is not None and abs(cx - x) > tol:
            continue
        if y is not None and abs(cy - y) > tol:
            continue
        out.append((cx, cy, cz))
    return out


def check_bottom_preset2(path: str) -> None:
    faces = _up_faces(load_triangles(path), 31.0, 32.0)
    assert _near(faces, y=26), "preset 2 bottom is missing the Y divider tip"
    assert _near(faces, x=101.2), "preset 2 bottom is missing the lower X divider tip"
    assert _near(faces, x=120.4), "preset 2 bottom is missing the upper X divider tip"
    for cx, cy, cz in faces:
        if abs(cy - 26) < 1.5 or abs(cx - 101.2) < 1.5 or abs(cx - 120.4) < 1.5:
            assert abs(cz - 31.5) < 0.05, f"divider tip at z={cz}, expected 31.5"


def check_bottom_preset0(path: str) -> None:
    faces = _up_faces(load_triangles(path), 31.0, 32.0)
    assert not _near(faces, y=26), "preset 0 bottom has a divider tip"


def check_closed(path: str) -> None:
    # viewBoxClosed lifts the assembly by the bottom height, so the opening
    # is at z=32. Bottom tips face up at 31.5; lid tips face down at 32.6.
    tris = load_triangles(path)
    low = _up_faces(tris, 31.0, 32.0)
    high = []
    for a, b, c in tris:
        n = _norm(_cross(_sub(b, a), _sub(c, a)))
        if n[2] > -0.9:
            continue
        cx = (a[0] + b[0] + c[0]) / 3.0
        cy = (a[1] + b[1] + c[1]) / 3.0
        cz = (a[2] + b[2] + c[2]) / 3.0
        if 32.2 <= cz <= 33.2 and 4 < cx < 160 and 4 < cy < 60:
            high.append((cx, cy, cz))
    assert _near(low, y=26), "closed bottom is missing the Y divider tip"
    assert _near(high, y=26), "closed lid Y divider does not meet the bottom wall"
    bottom_z = [cz for _, cy, cz in low if abs(cy - 26) < 1.5]
    lid_z = [cz for _, cy, cz in high if abs(cy - 26) < 1.5]
    gap = min(lid_z) - max(bottom_z)
    assert abs(gap - 1.1) < 0.05, f"closed divider gap is {gap}, expected 1.1"
    assert _near(low, x=101.2) and _near(high, x=101.2), "lower X divider is not shared"
    assert _near(low, x=120.4) and _near(high, x=120.4), "upper X divider is not shared"


def main(argv: Sequence[str]) -> int:
    if len(argv) != 4:
        print("usage: check_layout.py bottom0.stl bottom2.stl closed.stl", file=sys.stderr)
        return 2
    check_bottom_preset0(argv[1])
    check_bottom_preset2(argv[2])
    check_closed(argv[3])
    print("layout checks ok")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
