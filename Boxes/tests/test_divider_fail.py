#!/usr/bin/env python3
"""OpenSCAD asserts for bad divider shares and tool slots."""
from __future__ import annotations

import os
import subprocess
import unittest

from boxes_test_support import openscad_exe


MODES = {
    1: "a 0 must be trailing",
    2: "divider row 2 column 1",
    3: "divider row 3 height",
    4: "extends past the compartment: right edge 162 mm, compartment ends at 99.2 mm",
    5: "cut depth 29 mm leaves 0.5 mm of floor",
    6: "deeper than the 4 mm plate allows",
    7: "tool pocket plate 40 mm is taller than the interior allows (29.5 mm)",
    8: "still set to tools/_blank.svg",
    9: "tool insert row 4 does not exist; this layout has 2 rows",
    10: "crosses the divider at y=24",
    11: "clearance is -0.2 mm",
    12: "finger notch extends past the compartment",
    13: "width and height must be the Inkscape page size",
    14: "has a height share but no column widths",
    15: "dividerRow2Widths[1] is -1",
}


class DividerFailAssertTest(unittest.TestCase):
    def setUp(self) -> None:
        self.repo = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
        found = openscad_exe()
        if not found:
            self.skipTest("OpenSCAD executable not found")
        self.scad = found
        self.fail_file = os.path.join(self.repo, "Boxes", "tests", "rugged-box-divider-fail.scad")

    def _run(self, mode: int) -> str:
        proc = subprocess.run(
            [
                self.scad,
                "--hardwarnings",
                "-o",
                os.path.join(self.repo, "out", f"divider-fail-{mode}.stl"),
                "-D",
                f"fail_mode={mode}",
                self.fail_file,
            ],
            cwd=self.repo,
            capture_output=True,
            text=True,
            timeout=60,
        )
        blob = (proc.stdout or "") + "\n" + (proc.stderr or "")
        self.assertNotEqual(proc.returncode, 0, msg=blob)
        return blob

    def test_assert_messages(self) -> None:
        os.makedirs(os.path.join(self.repo, "out"), exist_ok=True)
        for mode, needle in MODES.items():
            with self.subTest(mode=mode):
                self.assertIn(needle, self._run(mode))


if __name__ == "__main__":
    unittest.main()
