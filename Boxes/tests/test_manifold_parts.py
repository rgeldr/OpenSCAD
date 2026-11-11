#!/usr/bin/env python3
"""Render rim, floor, and seal operands and reject non-closed or shallow meshes."""
import os
import subprocess
import unittest

from boxes_test_support import openscad_exe
from check_overhangs import load_triangles, mesh_signed_volume
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
        self.assertLess(min(xs), -2.5, msg="rim profile did not revolve outward")
        self.assertGreater(max(zs) - min(zs), 30)
        self.assertGreater(abs(mesh_signed_volume(tris)), 20)

    def test_side_wall_is_closed_mesh(self) -> None:
        tris = self._render("side")
        self.assertGreater(abs(mesh_signed_volume(tris)), 50.0)

    def test_corner_seal_revolve_matches_v13_circular_profile(self) -> None:
        tris = self._render("seal")
        vol = abs(mesh_signed_volume(tris))
        # Quarter torus: major R=2 mm, minor r=1.1 mm → π² R r² / 2 ≈ 11.9 mm³
        self.assertGreater(vol, 8.0)
        self.assertLess(vol, 16.0)

    def test_bead_profile_revolves_as_a_closed_solid(self) -> None:
        tris = self._render("bead")
        self.assertGreater(abs(mesh_signed_volume(tris)), 5.0)


if __name__ == "__main__":
    unittest.main()
