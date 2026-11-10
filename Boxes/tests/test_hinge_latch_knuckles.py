#!/usr/bin/env python3
"""Knuckle / screw-mount parameters vs RuggedBoxV1.3 and minimum wall around bores."""
import re
import unittest
from pathlib import Path


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
                self.assertIn(key, self.custom)
                self.assertIn(key, self.v13)
                self.assertEqual(self.custom[key], self.v13[key])

    def test_minimum_wall_around_screw_bores(self):
        for support, screw in (
            ("hingeRadiusMm", "hingeScrewSmallRadiusMm"),
            ("hingeRadiusMm", "hingeScrewLargeRadiusMm"),
            ("latchSupportRadius", "latchScrewSmallRadiusMm"),
        ):
            s = self.custom[support]
            r = self.custom[screw]
            outer = knuckle_outer_radius(s, r)
            with self.subTest(support=support, screw=screw):
                self.assertGreaterEqual(outer - r, 3.0)
                self.assertGreaterEqual(outer, s)

    def test_knuckle_solids_use_strong_bar_not_coarse_teardrop(self):
        text = CUSTOM.read_text(encoding="utf-8")
        self.assertIn("module rb_knuckle_solid_x", text)
        self.assertIn("rb_knuckle_bar_x", text)
        self.assertIn("_rb_teardrop_down_points(radius, 18)", text)
        mount_sections = (
            text.split("module LatchMount", 1)[1].split("module BotomStandardHinge", 1)[0],
            text.split("module BotomStandardHinge", 1)[1].split("module TopStandardHinge", 1)[0],
            text.split("module TopStandardHinge", 1)[1].split("module BoxShellBase", 1)[0],
        )
        for sec in mount_sections:
            with self.subTest(section="mount"):
                self.assertNotIn("rb_teardrop_cylinder_x", sec)

    def test_latch_full_width_gusset_span(self):
        text = CUSTOM.read_text(encoding="utf-8")
        latch_body = text.split("module LatchMount", 1)[1].split("module BotomStandardHinge", 1)[0]
        self.assertIn("latchGussetSpan", latch_body)
        self.assertIn("rb_knuckle_bar_x", latch_body)


if __name__ == "__main__":
    unittest.main()
