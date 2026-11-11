#!/usr/bin/env python3
"""Tool-outline preflight. No OpenSCAD, and paths go through pathlib."""
from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from check_tool_files import check_slot, main


class ToolFilePreflightTest(unittest.TestCase):
    def setUp(self) -> None:
        self.boxes = Path(__file__).resolve().parents[1]
        self.svg = "tests/fixtures/tool-rect-10x20.svg"
        self.dxf = "tests/fixtures/tool-rect-10x20.dxf"

    def test_no_args_exits_zero(self) -> None:
        self.assertEqual(main([]), 0)

    def test_disabled_missing_file_is_ok(self) -> None:
        code, lines = check_slot(1, False, "tools/does-not-exist.svg", 10, 20, 25.4, self.boxes)
        self.assertEqual(code, 0)
        self.assertEqual(lines, [])

    def test_svg_fixture_matches(self) -> None:
        code, lines = check_slot(1, True, self.svg, 10, 20, 25.4, self.boxes)
        self.assertEqual(code, 0, msg=lines)
        self.assertEqual(lines, [])

    def test_svg_size_mismatch(self) -> None:
        code, lines = check_slot(2, True, self.svg, 11, 20, 25.4, self.boxes)
        self.assertEqual(code, 2)
        self.assertIn("tool slot 2: file is 10.0 x 20.0 mm, Customizer says 11.0 x 20.0 mm", lines)

    def test_missing_file(self) -> None:
        code, lines = check_slot(1, True, "tools/wrench.svg", 10, 20, 25.4, self.boxes)
        self.assertEqual(code, 2)
        self.assertEqual(lines, ["tool slot 1: file not found: tools/wrench.svg"])

    def test_dxf_fixture_ignores_insunits(self) -> None:
        text = (self.boxes / self.dxf).read_text(encoding="utf-8")
        self.assertIn("$INSUNITS", text)
        self.assertNotIn("\nPOLYLINE\n", "\n" + text)
        code, lines = check_slot(1, True, self.dxf, 10, 20, 25.4, self.boxes)
        self.assertEqual(code, 0, msg=lines)

    def test_old_polyline_dxf_is_rejected(self) -> None:
        bad = "0\nSECTION\n2\nENTITIES\n0\nPOLYLINE\n8\n0\n0\nENDSEC\n0\nEOF\n"
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "bad.dxf"
            path.write_text(bad, encoding="utf-8")
            code, lines = check_slot(1, True, str(path), 10, 20, 25.4, self.boxes)
        self.assertEqual(code, 2)
        self.assertTrue(any("LWPOLYLINE" in line for line in lines), msg=lines)

    def test_many_svg_segments_warn_and_pass(self) -> None:
        commands = " ".join(f"L {i} 0" for i in range(2001))
        svg = (
            '<?xml version="1.0"?>'
            '<svg xmlns="http://www.w3.org/2000/svg" width="10mm" height="20mm">'
            f'<path d="M 0 0 {commands}" fill="black"/>'
            "</svg>"
        )
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "busy.svg"
            path.write_text(svg, encoding="utf-8")
            code, lines = check_slot(1, True, str(path), 10, 20, 25.4, self.boxes)
        self.assertEqual(code, 0, msg=lines)
        self.assertTrue(any("path segments, simplify in Inkscape" in line for line in lines), msg=lines)


if __name__ == "__main__":
    unittest.main()
