#!/usr/bin/env python3
"""Hinge and latch screw mounts vs V1.3 strength, wall thickness, and alignment."""
import math
import os
import re
import subprocess
import unittest
from pathlib import Path

from boxes_test_support import openscad_exe
from check_overhangs import _cross, _norm, _sub, load_triangles
from openscad_log import has_failures


REPO = Path(__file__).resolve().parents[2]
CUSTOM = REPO / "Boxes/RuggedBoxCustomeDividersV1.0.scad"
V13 = REPO / "Boxes/RuggedBoxV1.3.scad"


def parse_assignments(scad_path: Path) -> dict[str, float]:
    text = scad_path.read_text(encoding="utf-8")
    out: dict[str, float] = {}
    for m in re.finditer(r"^(\w+)\s*=\s*([-0-9.]+)\s*;", text, re.MULTILINE):
        try:
            out[m.group(1)] = float(m.group(2))
        except ValueError:
            pass
    return out


def knuckle_outer_radius(support_radius: float, screw_radius: float, min_wall: float = 3) -> float:
    return max(support_radius, screw_radius + min_wall)


class HingeLatchKnuckleTests(unittest.TestCase):
    def setUp(self):
        self.custom = parse_assignments(CUSTOM)
        self.v13 = parse_assignments(V13)
        self.text = CUSTOM.read_text(encoding="utf-8")

    def test_v13_reference_radii_unchanged_in_custom(self):
        pairs = [
            "hingeRadiusMm",
            "hingeOutsideWidth",
            "hingeScrewSmallRadiusMm",
            "hingeScrewLargeRadiusMm",
            "latchSupportRadius",
            "latchSupportWidth",
            "latchScrewSmallRadiusMm",
            "latchScrewLargeRadiusMm",
        ]
        for key in pairs:
            with self.subTest(key=key):
                self.assertEqual(self.custom[key], self.v13[key])

    def test_outer_radius_clears_screw_and_v13_cylinder(self):
        for support, screw in (
            ("hingeRadiusMm", "hingeScrewSmallRadiusMm"),
            ("hingeRadiusMm", "hingeScrewLargeRadiusMm"),
            ("latchSupportRadius", "latchScrewSmallRadiusMm"),
        ):
            outer = knuckle_outer_radius(self.custom[support], self.custom[screw])
            with self.subTest(support=support, screw=screw):
                self.assertGreaterEqual(outer - self.custom[screw], 3.0)
                self.assertGreaterEqual(outer, self.custom[support])

    def test_barrel_contains_full_circle_and_gusset_matches_knuckle_width(self):
        self.assertIn("function rb_strong_barrel_points", self.text)
        self.assertIn("function rb_screw_bore_points", self.text)
        self.assertIn("module rb_full_width_gusset", self.text)
        latch = self.text.split("module LatchMount", 1)[1].split("module BotomStandardHinge", 1)[0]
        bottom = self.text.split("module BotomStandardHinge", 1)[1].split("module TopStandardHinge", 1)[0]
        top = self.text.split("module TopStandardHinge", 1)[1].split("module BoxShellBase", 1)[0]
        # Coarse teardrop solids were the thin wedge Jason saw.
        for sec in (latch, bottom, top):
            self.assertNotIn("rb_teardrop_cylinder_x", sec)
            self.assertIn("rb_knuckle_bar_x", sec)
            self.assertIn("rb_full_width_gusset", sec)
        self.assertIn(
            "rb_full_width_gusset(latchMountX-(latchSupportWidth+latchToloerance), latchSupportWidth",
            latch,
        )
        self.assertIn(
            "rb_full_width_gusset(hingeX-(hingeOutsideWidth+hingeToleranceMm), hingeOutsideWidth",
            bottom,
        )
        self.assertIn(
            "rb_full_width_gusset(hingeX, hingeInsideWidthMm",
            top,
        )
        # Bore and barrel share one axis variable per mount.
        self.assertIn("latchAxisY", latch)
        self.assertIn("hingeAxisY", bottom)
        self.assertIn("hingeAxisY", top)

    def test_rendered_barrel_wall_and_closed_hinge_axis(self):
        scad = openscad_exe()
        if not scad:
            self.skipTest("OpenSCAD executable not found")
        out = REPO / "out"
        out.mkdir(exist_ok=True)
        probe = out / "knuckle-wall-probe.scad"
        probe.write_text(
            "use <../Boxes/RuggedBoxCustomeDividersV1.0.scad>\n"
            "difference() {\n"
            "  rb_knuckle_bar_x(8, rb_knuckle_outer_radius(4, 1.45));\n"
            "  translate([-0.2, 0, 0]) rb_screw_hole_x(8.4, 1.45);\n"
            "}\n",
            encoding="utf-8",
        )
        stl = out / "knuckle-wall-probe.stl"
        self._render(scad, probe, stl)
        self.assertGreaterEqual(self._min_radial_wall(stl), 2.95)

        product = REPO / "Boxes/RuggedBoxCustomeDividersV1.0.scad"
        off = [
            "-D", "generateLatches=false",
            "-D", "generateHandle=false",
            "-D", "generateGasket=false",
            "-D", "generateFeetIfSetInSettings=false",
            "-D", "viewBoxClosed=true",
        ]
        bottom_stl = out / "hinge-closed-bottom.stl"
        lid_stl = out / "hinge-closed-lid.stl"
        self._render(scad, product, bottom_stl, off + ["-D", "generateBoxTop=false"])
        self._render(scad, product, lid_stl, off + ["-D", "generateBoxBottom=false"])
        # Same numbers the mount modules use for the screw axis.
        y = (
            self.custom["rimWidthMm"]
            + (self.custom["internalboxLengthYMm"] + 2 * self.custom["boxWallWidthMm"])
            + self.custom["hingeRadiusMm"]
            + self.custom["openingTolerance"]
        )
        z = (
            self.custom["internalboxBottomHeightZMm"]
            + self.custom["boxWallWidthMm"]
            + self.custom["openingTolerance"] / 2
        )
        self._assert_bore(bottom_stl, y, z, self.custom["hingeScrewSmallRadiusMm"])
        self._assert_bore(lid_stl, y, z, self.custom["hingeScrewLargeRadiusMm"])
        # Latch screws stay on one Y, one screw-offset below and above the opening.
        latch_y = -(self.custom["latchSupportRadius"] + self.custom["rimWidthMm"])
        opening_z = self.custom["internalboxBottomHeightZMm"] + self.custom["boxWallWidthMm"]
        self._assert_bore(
            bottom_stl,
            latch_y,
            opening_z - self.custom["latchScrewOffsetMm"],
            self.custom["latchScrewSmallRadiusMm"],
        )
        self._assert_bore(
            lid_stl,
            latch_y,
            opening_z + self.custom["latchScrewOffsetMm"] + self.custom["openingTolerance"],
            self.custom["latchScrewSmallRadiusMm"],
        )

    def _render(self, scad, src, dest, extra=None):
        proc = subprocess.run(
            [scad, "--hardwarnings", "-o", str(dest), *(extra or []), str(src)],
            capture_output=True,
            text=True,
            timeout=120,
            cwd=REPO,
        )
        merged = (proc.stdout or "") + "\n" + (proc.stderr or "")
        self.assertEqual(proc.returncode, 0, msg=merged)
        self.assertFalse(has_failures(merged), msg=merged)

    def _min_radial_wall(self, stl: Path) -> float:
        bins: dict[int, list] = {}
        for a, b, c in load_triangles(stl):
            n = _norm(_cross(_sub(b, a), _sub(c, a)))
            cx = (a[0] + b[0] + c[0]) / 3
            cy = (a[1] + b[1] + c[1]) / 3
            cz = (a[2] + b[2] + c[2]) / 3
            if not 1 < cx < 7:
                continue
            ang = int(round(math.degrees(math.atan2(cz, cy)) / 15.0) * 15)
            rad = math.hypot(cy, cz)
            slot = 0 if (n[1] * cy + n[2] * cz) > 0 else 1
            bins.setdefault(ang, [None, None])
            prev = bins[ang][slot]
            if prev is None or (slot == 0 and rad < prev) or (slot == 1 and rad > prev):
                bins[ang][slot] = rad
        gaps = [outer - inner for outer, inner in bins.values() if outer and inner]
        self.assertTrue(gaps, "no knuckle cross-section sampled")
        return min(gaps)

    def _assert_bore(self, stl: Path, y: float, z: float, radius: float):
        inside = 0
        on_wall = 0
        for tri in load_triangles(stl):
            for p in tri:
                dist = math.hypot(p[1] - y, p[2] - z)
                if dist < radius * 0.55:
                    inside += 1
                elif abs(dist - radius) < 0.45:
                    on_wall += 1
        self.assertEqual(inside, 0, f"{stl.name} bore blocked at y={y:.2f} z={z:.2f}")
        self.assertGreater(on_wall, 12, f"{stl.name} missing screw wall at the shared axis")


if __name__ == "__main__":
    unittest.main()
