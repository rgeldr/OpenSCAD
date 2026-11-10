#!/usr/bin/env python3
"""Overhang gate for Rugged Box custom-divider exports (preset STLs).

Downward faces shallower than 60° from horizontal fail (n_z < -0.5),
which is the 30°-from-vertical rule. Bed faces and matched hollow-boolean
pairs are ignored by check_triangles / strip_csg_coplanar_pairs. There is
no rim-shelf or low-poly exemption.
"""
from __future__ import annotations

import sys
from typing import Sequence

from check_overhangs import check_triangles, load_triangles, strip_csg_coplanar_pairs


def main(argv: Sequence[str]) -> int:
    if len(argv) < 2:
        print("usage: check_rugged_overhangs.py <stl>...", file=sys.stderr)
        return 2
    any_fail = False
    for path in argv[1:]:
        tris = strip_csg_coplanar_pairs(load_triangles(path))
        fails = check_triangles(tris)
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
