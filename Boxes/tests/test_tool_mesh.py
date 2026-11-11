#!/usr/bin/env python3
"""Mesh checks for tool pockets. The 10x20 fixture sits in the front band so it does not cross the screenshot wall at y=24."""
from __future__ import annotations

import os
import subprocess
import unittest

from boxes_test_support import openscad_exe
from check_layout import check_closed
from check_overhangs import _cross, _norm, _sub, load_triangles
from openscad_log import has_failures


def _centroids(tris, z_lo, z_hi, pred):
    found = []
    for a, b, c in tris:
        n = _norm(_cross(_sub(b, a), _sub(c, a)))
        cx = (a[0] + b[0] + c[0]) / 3.0
        cy = (a[1] + b[1] + c[1]) / 3.0
        cz = (a[2] + b[2] + c[2]) / 3.0
        if z_lo <= cz <= z_hi and pred(n, cx, cy, cz):
            found.append((cx, cy, cz))
    return found


def _in_pocket(cx, cy) -> bool:
    return 21.5 <= cx <= 32.5 and 3.5 <= cy <= 24.5


class ToolMeshTest(unittest.TestCase):
    def setUp(self) -> None:
        self.repo = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
        found = openscad_exe()
        if not found:
            self.skipTest("OpenSCAD executable not found")
        self.scad = found
        self.product = os.path.join(self.repo, "Boxes", "RuggedBoxCustomeDividersV1.0.scad")
        self.out = os.path.join(self.repo, "out")
        os.makedirs(self.out, exist_ok=True)

    def _render(self, outfile: str, extra: list[str]) -> str:
        proc = subprocess.run(
            [self.scad, "--hardwarnings", "-o", outfile, *extra, self.product],
            cwd=self.repo,
            capture_output=True,
            text=True,
            timeout=300,
        )
        blob = (proc.stdout or "") + "\n" + (proc.stderr or "")
        self.assertEqual(proc.returncode, 0, msg=blob)
        self.assertFalse(has_failures(blob), msg=blob)
        return blob

    def _slot(self, filename: str) -> list[str]:
        # y=2 keeps the 20 mm outline inside the front band (wall at interior y=24).
        return [
            "-D", "toolInsertEnabled=true",
            "-D", "tool1Enabled=true",
            "-D", f'tool1File="{filename}"',
            "-D", "tool1WidthMm=10",
            "-D", "tool1HeightMm=20",
            "-D", "tool1XMm=20",
            "-D", "tool1YMm=2",
            "-D", "tool1CutDepthMm=5",
            "-D", "tool1ClearanceMm=0",
            "-D", "generateGasket=false",
            "-D", "generateFeetIfSetInSettings=false",
            "-D", "generateLatches=false",
            "-D", "generateHandle=false",
        ]

    def _pocket_floor(self, path: str):
        tris = load_triangles(path)
        pierced = _centroids(
            tris, 0.4, 1.6, lambda n, cx, cy, cz: _in_pocket(cx, cy)
        )
        self.assertFalse(pierced, msg=f"shell floor opened: {pierced[:3]}")
        floor = _centroids(
            tris, 26.2, 26.8, lambda n, cx, cy, cz: n[2] > 0.9 and _in_pocket(cx, cy)
        )
        self.assertTrue(floor, msg="pocket floor missing")
        return floor

    def test_svg_and_dxf_pockets_match(self) -> None:
        svg = os.path.join(self.out, "bottom-tool-svg.stl")
        dxf = os.path.join(self.out, "bottom-tool-dxf.stl")
        common = ["-D", "generateBoxTop=false"]
        self._render(svg, self._slot("tests/fixtures/tool-rect-10x20.svg") + common)
        self._render(dxf, self._slot("tests/fixtures/tool-rect-10x20.dxf") + common)
        a = self._pocket_floor(svg)
        b = self._pocket_floor(dxf)
        ax = sum(p[0] for p in a) / len(a)
        ay = sum(p[1] for p in a) / len(a)
        bx = sum(p[0] for p in b) / len(b)
        by = sum(p[1] for p in b) / len(b)
        self.assertLess(abs(ax - bx), 0.5)
        self.assertLess(abs(ay - by), 0.5)
        from check_layout import check_bottom_screenshot
        check_bottom_screenshot(svg)

    def test_lid_has_no_pocket_and_plain_lid_drops_dividers(self) -> None:
        mirror = os.path.join(self.out, "lid-tool-mirror.stl")
        plain = os.path.join(self.out, "lid-tool-plain.stl")
        self._render(
            mirror,
            self._slot("tests/fixtures/tool-rect-10x20.svg")
            + ["-D", "generateBoxBottom=false", "-D", "generateBoxTop=true", "-D", "toolLid=0"],
        )
        self._render(
            plain,
            [
                "-D", "toolLid=1",
                "-D", "generateBoxBottom=false",
                "-D", "generateBoxTop=true",
                "-D", "generateGasket=false",
                "-D", "generateFeetIfSetInSettings=false",
                "-D", "generateLatches=false",
                "-D", "generateHandle=false",
            ],
        )
        self.assertGreater(len(load_triangles(mirror)), len(load_triangles(plain)))
        # The pocket is bottom-only, so the mirrored lid matches a lid rendered with the insert off.
        bare = os.path.join(self.out, "lid-tool-bare.stl")
        self._render(
            bare,
            [
                "-D", "generateBoxBottom=false",
                "-D", "generateBoxTop=true",
                "-D", "generateGasket=false",
                "-D", "generateFeetIfSetInSettings=false",
                "-D", "generateLatches=false",
                "-D", "generateHandle=false",
            ],
        )
        self.assertEqual(len(load_triangles(mirror)), len(load_triangles(bare)))

    def test_closed_gap_stays_1_1(self) -> None:
        path = os.path.join(self.out, "closed-tool.stl")
        self._render(
            path,
            self._slot("tests/fixtures/tool-rect-10x20.svg") + ["-D", "viewBoxClosed=true"],
        )
        check_closed(path)

    def test_disabled_slot_does_not_import_missing_file(self) -> None:
        path = os.path.join(self.out, "bottom-tool-missing-off.stl")
        blob = self._render(
            path,
            [
                "-D", "toolInsertEnabled=false",
                "-D", "tool1Enabled=true",
                "-D", 'tool1File="tools/does-not-exist.svg"',
                "-D", "generateBoxTop=false",
                "-D", "generateLatches=false",
                "-D", "generateHandle=false",
                "-D", "generateGasket=false",
                "-D", "generateFeetIfSetInSettings=false",
            ],
        )
        self.assertNotIn("Can't open file", blob)

    def test_enabled_missing_file_is_an_openscad_error(self) -> None:
        proc = subprocess.run(
            [
                self.scad,
                "--hardwarnings",
                "-o",
                os.path.join(self.out, "bottom-tool-missing.stl"),
                "-D", "toolInsertEnabled=true",
                "-D", "tool1Enabled=true",
                "-D", 'tool1File="tools/does-not-exist.svg"',
                "-D", "tool1WidthMm=10",
                "-D", "tool1HeightMm=20",
                "-D", "tool1XMm=20",
                "-D", "tool1YMm=2",
                "-D", "tool1CutDepthMm=5",
                "-D", "tool1ClearanceMm=0",
                "-D", "generateBoxTop=false",
                "-D", "generateGasket=false",
                "-D", "generateFeetIfSetInSettings=false",
                "-D", "generateLatches=false",
                "-D", "generateHandle=false",
                self.product,
            ],
            cwd=self.repo,
            capture_output=True,
            text=True,
            timeout=120,
        )
        blob = (proc.stdout or "") + "\n" + (proc.stderr or "")
        # OpenSCAD 2021.01 prints the import error and can still exit 0 when the
        # rest of the box renders. The render scripts treat that log line as failure.
        self.assertIn("Can't open file", blob)
        self.assertTrue(has_failures(blob), msg=blob)


if __name__ == "__main__":
    unittest.main()
