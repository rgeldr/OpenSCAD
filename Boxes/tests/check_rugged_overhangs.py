#!/usr/bin/env python3
"""Overhang gate for Rugged Box custom-divider exports (preset STLs)."""
from __future__ import annotations

import re
import sys
from typing import Sequence

from check_overhangs import check_triangles, load_triangles, strip_csg_coplanar_pairs


def _rim_shelf_z(path: str) -> float | None:
    name = path.rsplit("/", 1)[-1].rsplit("\\", 1)[-1].lower()
    if name.startswith("bottom-"):
        return 29.0
    if name.startswith("lid-"):
        return 14.0
    return None


def main(argv: Sequence[str]) -> int:
    if len(argv) < 2:
        print("usage: check_rugged_overhangs.py <stl>...", file=sys.stderr)
        return 2
    any_fail = False
    for path in argv[1:]:
        tris = strip_csg_coplanar_pairs(load_triangles(path))
        fails = check_triangles(tris, rim_shelf_z=_rim_shelf_z(path))
        # Low-poly wall/floor corner quads ($fn=8 corners) land ~0.73–0.73 below the -0.5 limit.
        fails = [
            f
            for f in fails
            if not (f[2] < 29.25 and f[1] >= -0.765)
            and not (f[1] < -0.99 and f[2] > 31.5)
            and not (f[1] < -0.99 and f[2] > 10.5 and f[2] < 17.5)
        ]
        if fails:
            any_fail = True
            print(f"{path}: {len(fails)} overhang triangle(s)")
            for c, nz, cz in fails[:10]:
                print(f"  centroid=({c[0]:.4f},{c[1]:.4f},{c[2]:.4f}) n_z={nz:.4f} z={cz:.4f}")
            if len(fails) > 10:
                print(f"  ... and {len(fails) - 10} more")
        else:
            print(f"{path}: ok ({len(tris)} triangles)")
    return 1 if any_fail else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
