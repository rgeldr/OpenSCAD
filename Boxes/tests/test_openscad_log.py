#!/usr/bin/env python3
import unittest

from openscad_log import failure_lines, has_failures


class OpenscadLogTest(unittest.TestCase):
    def test_detects_error_with_leading_whitespace(self) -> None:
        log = "  ERROR: The given mesh is not closed!\nCGAL done\n"
        self.assertTrue(has_failures(log))
        self.assertEqual(len(failure_lines(log)), 1)

    def test_clean_log(self) -> None:
        self.assertFalse(has_failures("Geometries in cache: 3\nTotal rendering time: 0:00:01\n"))


if __name__ == "__main__":
    unittest.main()
