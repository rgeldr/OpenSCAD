#!/usr/bin/env python3
"""Fail if exported STLs look truncated (CGAL dropped operands) or lack key features."""
from __future__ import annotations

import math
import sys
from typing import Dict, List, Sequence, Tuple

from check_overhangs import load_triangles

Vec3 = Tuple[float, float, float]
Bounds = Tuple[Vec3, Vec3]


def _bounds_from_tris(tris: Sequence) -> Bounds:
    mins = [math.inf, math.inf, math.inf]
    maxs = [-math.inf, -math.inf, -math.inf]
    for v0, v1, v2 in tris:
        for x, y, z in (v0, v1, v2):
            mins[0] = min(mins[0], x)
            mins[1] = min(mins[1], y)
            mins[2] = min(mins[2], z)
            maxs[0] = max(maxs[0], x)
            maxs[1] = max(maxs[1], y)
            maxs[2] = max(maxs[2], z)
    return ((mins[0], mins[1], mins[2]), (maxs[0], maxs[1], maxs[2]))


def _read_stl(path: str) -> Tuple[int, Bounds]:
    tris = load_triangles(path)
    return len(tris), _bounds_from_tris(tris)


def _span(b: Bounds, axis: int) -> float:
    return b[1][axis] - b[0][axis]


# Minimum triangle counts / axis spans for default Rugged Box preset geometry.
# Broken CGAL exports were ~2400 bottom / ~1764 lid triangles.
# ext_* keys check that rim, hinge, and latch geometry is actually in the mesh.
THRESHOLDS: Dict[str, Dict[str, float]] = {
    "bottom-preset-0.stl": {
        "min_tris": 4500, "min_x": 160, "min_y": 80, "min_z": 34,
        "ext_min_x_le": -1.5, "ext_min_y_le": -5, "ext_max_y_ge": 70, "ext_max_z_ge": 34,
    },
    "bottom-preset-2.stl": {
        "min_tris": 4600, "min_x": 160, "min_y": 80, "min_z": 34,
        "ext_min_x_le": -1.5, "ext_min_y_le": -5, "ext_max_y_ge": 70, "ext_max_z_ge": 34,
    },
    "lid-preset-0.stl": {
        "min_tris": 3000, "min_x": 160, "min_y": 80, "min_z": 20,
        "ext_min_x_le": -1.5, "ext_max_z_ge": 19,
    },
    "lid-preset-2.stl": {
        "min_tris": 3100, "min_x": 160, "min_y": 80, "min_z": 20,
        "ext_min_x_le": -1.5, "ext_max_z_ge": 19,
    },
    "latch.stl": {"min_tris": 1200, "min_x": 20, "min_y": 30, "min_z": 14},
    "handle.stl": {"min_tris": 80, "min_x": 75, "min_y": 80, "min_z": 8},
    "closed-preset-2.stl": {"min_tris": 7500, "min_x": 160, "min_y": 80, "min_z": 45},
}


def check_paths(paths: Sequence[str]) -> List[str]:
    errors: List[str] = []
    for path in paths:
        name = path.rsplit("/", 1)[-1].rsplit("\\", 1)[-1]
        spec = THRESHOLDS.get(name)
        if spec is None:
            continue
        try:
            tris, bounds = _read_stl(path)
        except OSError as e:
            errors.append(f"{name}: cannot read ({e})")
            continue
        if tris < spec["min_tris"]:
            errors.append(f"{name}: {tris} triangles < min {spec['min_tris']:.0f}")
        for axis, key in enumerate(("min_x", "min_y", "min_z")):
            span = _span(bounds, axis)
            need = spec[key]
            if span < need:
                errors.append(f"{name}: axis {axis} span {span:.2f} mm < min {need:.2f} mm")
        if "ext_min_x_le" in spec and bounds[0][0] > spec["ext_min_x_le"]:
            errors.append(f"{name}: rim missing (min x {bounds[0][0]:.2f} > {spec['ext_min_x_le']})")
        if "ext_min_y_le" in spec and bounds[0][1] > spec["ext_min_y_le"]:
            errors.append(f"{name}: front latch/rim missing (min y {bounds[0][1]:.2f})")
        if "ext_max_y_ge" in spec and bounds[1][1] < spec["ext_max_y_ge"]:
            errors.append(f"{name}: hinge missing (max y {bounds[1][1]:.2f} < {spec['ext_max_y_ge']})")
        if "ext_max_z_ge" in spec and bounds[1][2] < spec["ext_max_z_ge"]:
            errors.append(f"{name}: height short (max z {bounds[1][2]:.2f} < {spec['ext_max_z_ge']})")
    by_name = {}
    for path in paths:
        name = path.rsplit("/", 1)[-1].rsplit("\\", 1)[-1]
        if name in THRESHOLDS:
            try:
                by_name[name] = _read_stl(path)[0]
            except OSError:
                pass
    for base in ("bottom", "lid"):
        a, b = f"{base}-preset-0.stl", f"{base}-preset-2.stl"
        if a in by_name and b in by_name and by_name[b] <= by_name[a]:
            errors.append(f"{b}: dividers missing ({by_name[b]} triangles <= {a} {by_name[a]})")
    return errors


def main(argv: Sequence[str]) -> int:
    if len(argv) < 2:
        print("usage: check_geometry.py <stl>...", file=sys.stderr)
        return 2
    errors = check_paths(argv[1:])
    if errors:
        for e in errors:
            print(e, file=sys.stderr)
        return 1
    print("geometry checks ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
