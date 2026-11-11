#!/usr/bin/env python3
"""Hinge and latch mounts match RuggedBoxV1.3 shape, size, and closed alignment."""
import math
import re
import subprocess
import unittest
from pathlib import Path

from boxes_test_support import openscad_exe
from check_overhangs import load_triangles
from openscad_log import has_failures


REPO = Path(__file__).resolve().parents[2]
CUSTOM = REPO / "Boxes/RuggedBoxCustomeDividersV1.0.scad"
V13 = REPO / "Boxes/RuggedBoxV1.3.scad"
MODULES = ("LatchMount", "BotomStandardHinge", "TopStandardHinge")


def parse_assignments(scad_path: Path) -> dict[str, float]:
    text = scad_path.read_text(encoding="utf-8")
    out: dict[str, float] = {}
    for m in re.finditer(r"^(\w+)\s*=\s*([-0-9.]+)\s*;", text, re.MULTILINE):
        try:
            out[m.group(1)] = float(m.group(2))
        except ValueError:
            pass
    return out


def module_body(text: str, name: str) -> str:
    start = text.index(f"module {name}(")
    i = text.index("{", start)
    depth = 0
    for j in range(i, len(text)):
        if text[j] == "{":
            depth += 1
        elif text[j] == "}":
            depth -= 1
            if depth == 0:
                return text[start : j + 1]
    raise AssertionError(f"unbalanced module {name}")


def normalize(src: str) -> str:
    src = re.sub(r"//.*?$", "", src, flags=re.MULTILINE)
    return re.sub(r"\s+", "", src)


class HingeLatchKnuckleTests(unittest.TestCase):
    def setUp(self):
        self.custom = parse_assignments(CUSTOM)
        self.v13 = parse_assignments(V13)
        self.text = CUSTOM.read_text(encoding="utf-8")
        self.v13_text = V13.read_text(encoding="utf-8")

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

    def test_mounts_match_v13_modules(self):
        for name in ("rb_knuckle_bar_x", "rb_full_width_gusset", "rb_strong_barrel_points", "rb_screw_hole_x"):
            self.assertNotIn(name, self.text)
        for name in MODULES:
            with self.subTest(module=name):
                self.assertEqual(
                    normalize(module_body(self.text, name)),
                    normalize(module_body(self.v13_text, name)),
                )

    def test_rendered_cylinder_radius_and_closed_alignment(self):
        scad = openscad_exe()
        if not scad:
            self.skipTest("OpenSCAD executable not found")
        out = REPO / "out"
        out.mkdir(exist_ok=True)
        product = CUSTOM
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
        radius = self.custom["hingeRadiusMm"]
        self._assert_cylinder(bottom_stl, y, z, radius)
        self._assert_cylinder(lid_stl, y, z, radius)
        self._assert_bore(bottom_stl, y, z, self.custom["hingeScrewSmallRadiusMm"])
        self._assert_bore(lid_stl, y, z, self.custom["hingeScrewLargeRadiusMm"])

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
        self._assert_cylinder(bottom_stl, latch_y, opening_z - self.custom["latchScrewOffsetMm"], radius)
        self._assert_cylinder(
            lid_stl,
            latch_y,
            opening_z + self.custom["latchScrewOffsetMm"] + self.custom["openingTolerance"],
            radius,
        )

    def _render(self, scad, src, dest, extra=None):
        proc = subprocess.run(
            [scad, "--hardwarnings", "-o", str(dest), *(extra or []), str(src)],
            capture_output=True,
            text=True,
            timeout=180,
            cwd=REPO,
        )
        merged = (proc.stdout or "") + "\n" + (proc.stderr or "")
        self.assertEqual(proc.returncode, 0, msg=merged)
        self.assertFalse(has_failures(merged), msg=merged)

    def _assert_cylinder(self, stl: Path, y: float, z: float, radius: float):
        on_circle = 0
        for tri in load_triangles(stl):
            for p in tri:
                dist = math.hypot(p[1] - y, p[2] - z)
                if abs(dist - radius) < 0.08:
                    on_circle += 1
        self.assertGreater(
            on_circle,
            16,
            f"{stl.name} missing V1.3 cylinder of radius {radius} at y={y:.2f} z={z:.2f}",
        )

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
