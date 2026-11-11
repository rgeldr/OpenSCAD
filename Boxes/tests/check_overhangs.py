#!/usr/bin/env python3
"""STL overhang checker: downward faces shallower than 60° from horizontal fail (n_z < -0.5)."""
from __future__ import annotations

import argparse
import math
import struct
import sys
from typing import Iterable, List, Sequence, Tuple

Tri = Tuple[Tuple[float, float, float], Tuple[float, float, float], Tuple[float, float, float]]


def _cross(a: Sequence[float], b: Sequence[float]) -> Tuple[float, float, float]:
    return (
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
    )


def _sub(a: Sequence[float], b: Sequence[float]) -> Tuple[float, float, float]:
    return (a[0] - b[0], a[1] - b[1], a[2] - b[2])


def _norm(v: Sequence[float]) -> Tuple[float, float, float]:
    ln = math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2])
    if ln < 1e-15:
        return (0.0, 0.0, 0.0)
    return (v[0] / ln, v[1] / ln, v[2] / ln)


def _area(v0, v1, v2) -> float:
    c = _cross(_sub(v1, v0), _sub(v2, v0))
    return 0.5 * math.sqrt(c[0] * c[0] + c[1] * c[1] + c[2] * c[2])


def _centroid(v0, v1, v2) -> Tuple[float, float, float]:
    return ((v0[0] + v1[0] + v2[0]) / 3.0, (v0[1] + v1[1] + v2[1]) / 3.0, (v0[2] + v1[2] + v2[2]) / 3.0)


def parse_ascii_stl(data: bytes) -> List[Tri]:
    text = data.decode("latin-1", errors="replace")
    tris: List[Tri] = []
    lines = text.splitlines()
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if line.lower().startswith("facet normal"):
            i += 1
            if i >= len(lines) or not lines[i].strip().lower().startswith("outer loop"):
                raise ValueError("expected outer loop")
            i += 1
            verts: List[Tuple[float, float, float]] = []
            for _ in range(3):
                vl = lines[i].strip()
                if not vl.lower().startswith("vertex"):
                    raise ValueError("expected vertex")
                parts = vl.split()
                verts.append((float(parts[1]), float(parts[2]), float(parts[3])))
                i += 1
            if i >= len(lines) or not lines[i].strip().lower().startswith("endloop"):
                raise ValueError("expected endloop")
            i += 1
            if i >= len(lines) or not lines[i].strip().lower().startswith("endfacet"):
                raise ValueError("expected endfacet")
            tris.append((verts[0], verts[1], verts[2]))
        i += 1
    return tris


def parse_binary_stl(data: bytes) -> List[Tri]:
    if len(data) < 84:
        raise ValueError("binary STL too short")
    tri_count = struct.unpack_from("<I", data, 80)[0]
    tris: List[Tri] = []
    offset = 84
    record = 50
    need = offset + tri_count * record
    if len(data) < need:
        raise ValueError("binary STL truncated")
    for _ in range(tri_count):
        # skip stored normal (12 bytes)
        off = offset + 12
        verts = []
        for _v in range(3):
            x, y, z = struct.unpack_from("<fff", data, off)
            verts.append((x, y, z))
            off += 12
        tris.append((verts[0], verts[1], verts[2]))
        offset += record
    return tris


def load_triangles(path: str) -> List[Tri]:
    with open(path, "rb") as f:
        data = f.read()
    head = data[:2048]
    if b"facet normal" in head.lower():
        return parse_ascii_stl(data)
    return parse_binary_stl(data)


def _is_horizontal_triangle(v0, v1, v2, z_eps: float = 0.02) -> bool:
    zs = (v0[2], v1[2], v2[2])
    return max(zs) - min(zs) <= z_eps


def strip_csg_coplanar_pairs(
    triangles: Sequence[Tri], z_eps: float = 0.02, area_eps: float = 0.35
) -> List[Tri]:
    """Drop matched +Z / -Z horizontal pairs (typical OpenSCAD hollow boolean artifacts)."""
    from collections import defaultdict

    buckets: dict[int, Tuple[List[Tuple[int, float]], List[Tuple[int, float]]]] = defaultdict(
        lambda: ([], [])
    )
    for i, tri in enumerate(triangles):
        if not _is_horizontal_triangle(*tri, z_eps=z_eps):
            continue
        n = _norm(_cross(_sub(tri[1], tri[0]), _sub(tri[2], tri[0])))
        if abs(abs(n[2]) - 1.0) > 0.05:
            continue
        a = _area(*tri)
        if a < 1e-12:
            continue
        z_key = int(round(_centroid(*tri)[2] / z_eps))
        pos, neg = buckets[z_key]
        if n[2] > 0:
            pos.append((i, a))
        else:
            neg.append((i, a))

    drop: set[int] = set()
    for pos, neg in buckets.values():
        pos.sort(key=lambda x: x[1])
        neg.sort(key=lambda x: x[1])
        used: set[int] = set()
        for ni, na in neg:
            best: int | None = None
            best_rel = area_eps + 1.0
            for pi, pa in pos:
                if pi in used:
                    continue
                rel = abs(na - pa) / na
                if rel < area_eps and rel < best_rel:
                    best_rel = rel
                    best = pi
            if best is not None:
                used.add(best)
                drop.add(ni)
                drop.add(best)

    return [tri for i, tri in enumerate(triangles) if i not in drop]


def mesh_signed_volume(triangles: Iterable[Tri]) -> float:
    vol = 0.0
    for v0, v1, v2 in triangles:
        vol += (
            v0[0] * (v1[1] * v2[2] - v2[1] * v1[2])
            + v1[0] * (v2[1] * v0[2] - v0[1] * v2[2])
            + v2[0] * (v0[1] * v1[2] - v1[1] * v0[2])
        )
    return vol / 6.0


def check_triangles(
    triangles: Sequence[Tri],
    z_bed_eps: float = 0.05,
    nz_limit: float = -0.5,
    rim_shelf_z: float | None = None,
    rim_shelf_eps: float = 0.75,
) -> List[Tuple[Tuple[float, float, float], float, float]]:
    vol = mesh_signed_volume(triangles)
    flip = len(triangles) >= 4 and abs(vol) > 1e-6 and vol < 0
    failures: List[Tuple[Tuple[float, float, float], float, float]] = []
    for v0, v1, v2 in triangles:
        if _area(v0, v1, v2) < 1e-12:
            continue
        n = _norm(_cross(_sub(v1, v0), _sub(v2, v0)))
        if flip:
            n = (-n[0], -n[1], -n[2])
        # ASCII STL rounding of an exact 60° face can land ~1.4e-4 under -0.5.
        if n[2] >= nz_limit - 2e-4:
            continue
        cz = _centroid(v0, v1, v2)[2]
        if cz <= z_bed_eps and n[2] < -0.99:
            continue
        if (
            rim_shelf_z is not None
            and n[2] < -0.99
            and abs(cz - rim_shelf_z) <= rim_shelf_eps
        ):
            continue
        failures.append((_centroid(v0, v1, v2), n[2], cz))
    return failures


def main(argv: Sequence[str] | None = None) -> int:
    p = argparse.ArgumentParser(description="Check STL for downward overhangs steeper than 30° from vertical.")
    p.add_argument("stl", nargs="+", help="STL files")
    p.add_argument("--z-bed-eps", type=float, default=0.05)
    p.add_argument(
        "--keep-csg-pairs",
        action="store_true",
        help="Keep matched horizontal coplanar pairs from hollow boolean exports",
    )
    p.add_argument(
        "--rim-shelf-z",
        type=float,
        default=None,
        help="Ignore downward horizontals at this Z (mm) from hollow rim groove CSG (e.g. 29 for default bottom)",
    )
    p.add_argument(
        "--report-only",
        action="store_true",
        help="Print results but always exit 0 (informational; render scripts use this)",
    )
    args = p.parse_args(argv)

    any_fail = False
    for path in args.stl:
        try:
            tris = load_triangles(path)
        except (OSError, ValueError) as e:
            print(f"{path}: parse error: {e}", file=sys.stderr)
            return 2
        if not args.keep_csg_pairs:
            tris = strip_csg_coplanar_pairs(tris)
        fails = check_triangles(
            tris, z_bed_eps=args.z_bed_eps, rim_shelf_z=args.rim_shelf_z
        )
        if fails:
            any_fail = True
            print(f"{path}: {len(fails)} overhang triangle(s)")
            for c, nz, cz in fails[:10]:
                print(f"  centroid=({c[0]:.4f},{c[1]:.4f},{c[2]:.4f}) n_z={nz:.4f} z={cz:.4f}")
            if len(fails) > 10:
                print(f"  ... and {len(fails) - 10} more")
        else:
            print(f"{path}: ok ({len(tris)} triangles)")
    if args.report_only:
        return 0
    return 1 if any_fail else 0


if __name__ == "__main__":
    sys.exit(main())
