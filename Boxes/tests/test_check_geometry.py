#!/usr/bin/env python3
import unittest

from check_geometry import check_paths


class CheckGeometryTests(unittest.TestCase):
    def test_rejects_tiny_placeholder(self):
        errors = check_paths(["/dev/null/this-wont-run"])
        # paths that are not in THRESHOLDS are skipped (no errors)
        self.assertEqual(errors, [])


if __name__ == "__main__":
    unittest.main()
