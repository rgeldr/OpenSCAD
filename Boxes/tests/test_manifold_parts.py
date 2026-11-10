#!/usr/bin/env python3
"""Render rim, floor, and seal operands and reject non-closed or shallow meshes."""
import os
import subprocess
import unittest

from boxes_test_support import openscad_exe
from check_overhangs import check_triangles, load_triangles, mesh_signed_volume, strip_csg_coplanar_pairs
from openscad_log import has_failures


class ManifoldProbeTest(unittest.TestCase):
    def setUp(self) -> None:
        self.repo = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
        found = openscad_exe()
        if not found:
            self.skipTest("OpenSCAD executable not found (set OPENSCAD or install openscad)")
        self.scad = found
        self.probe = os.path.join(self.repo, "Boxes", "tests", "manifold-probe.scad")
        self.out = os.path.join(self.repo, "out")
        os.makedirs(self.out, exist_ok=True)

    def _render(self, part: str):
        stl = os.path.join(self.out, f"probe-{part}.stl")
        proc = subprocess.run(
            [self.scad, "--hardwarnings", "-D", f'part="{part}"', "-o", stl, self.probe],
            capture_output=True,
            text=True,
            timeout=90,
            cwd=self.repo,
        )
        merged = (proc.stdout or "") + "\n" + (proc.stderr or "")
        self.assertEqual(proc.returncode, 0, msg=merged)
        self.assertFalse(has_failures(merged), msg=merged)
        tris = load_triangles(stl)
        self.assertGreater(len(tris), 0)
        return tris

    def test_rim_corner_is_closed_and_reaches_outward(self) -> None:
        tris = self._render("corner")
        xs = [v[0] for tri in tris for v in tri]
        zs = [v[2] for tri in tris for v in tri]
        self.assertLess(min(xs), -2.5, msg="60° rim did not revolve outward")
        self.assertGreater(max(zs) - min(zs), 30)
        self.assertGreater(abs(mesh_signed_volume(tris)), 20)

    def test_side_wall_meets_overhang_rule(self) -> None:
        tris = self._render("side")
        fails = check_triangles(strip_csg_coplanar_pairs(tris))
        self.assertEqual(fails, [], msg=str(fails[:5]))

    def test_corner_seal_matches_straight_groove_not_the_inflated_profile(self) -> None:
        tris = self._render("seal")
        vol = abs(mesh_signed_volume(tris))
        # Symmetric 60° groove corner is ~4.5 mm^3. The old axis-shifted quad was ~9.4.
        self.assertGreater(vol, 3.0)
        self.assertLess(vol, 6.0)

    def test_bead_profile_revolves_as_a_closed_solid(self) -> None:
        tris = self._render("bead")
        self.assertGreater(abs(mesh_signed_volume(tris)), 5.0)


if __name__ == "__main__":
    unittest.main()
