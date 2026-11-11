#!/usr/bin/env python3
import os
import subprocess
import unittest

from boxes_test_support import openscad_exe
from openscad_log import has_failures


class CgalExportsTest(unittest.TestCase):
    def setUp(self) -> None:
        self.repo = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
        found = openscad_exe()
        if not found:
            self.skipTest("OpenSCAD executable not found (set OPENSCAD or install openscad)")
        self.scad = found
        self.product = os.path.join(self.repo, "Boxes", "RuggedBoxCustomeDividersV1.0.scad")
        self.off = [
            "-D", "generateGasket=false",
            "-D", "generateFeetIfSetInSettings=false",
            "--hardwarnings",
        ]

    def _render(self, extra: list[str], outfile: str) -> str:
        proc = subprocess.run(
            [self.scad, "-o", outfile, *self.off, *extra, self.product],
            capture_output=True,
            text=True,
            timeout=180,
            cwd=self.repo,
        )
        merged = (proc.stdout or "") + "\n" + (proc.stderr or "")
        self.assertEqual(proc.returncode, 0, msg=merged)
        self.assertFalse(has_failures(merged), msg=merged)
        return merged

    def test_bottom_and_lid_export_clean(self) -> None:
        out = os.path.join(self.repo, "out")
        os.makedirs(out, exist_ok=True)
        self._render(
            [
                "-D", "dividerRowHeights=[0,0,0,0,0,0]",
                "-D", "generateBoxTop=false",
                "-D", "generateLatches=false",
                "-D", "generateHandle=false",
            ],
            os.path.join(out, "unittest-bottom-preset-0.stl"),
        )
        self._render(
            [
                "-D", "dividerRowHeights=[0,0,0,0,0,0]",
                "-D", "generateBoxBottom=false",
                "-D", "generateBoxTop=true",
                "-D", "generateLatches=false",
                "-D", "generateHandle=false",
            ],
            os.path.join(out, "unittest-lid-preset-0.stl"),
        )


if __name__ == "__main__":
    unittest.main()
