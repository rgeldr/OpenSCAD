#!/usr/bin/env python3
import unittest

from check_overhangs import check_triangles, strip_csg_coplanar_pairs


class StripCsgPairsTests(unittest.TestCase):
    def test_opposite_horizontal_pair_is_stripped_before_check(self):
        tri_up = ((0, 0, 29), (1, 0, 29), (0, 1, 29))
        tri_dn = ((0, 0, 29), (0, 1, 29), (1, 0, 29))
        other = ((0, 0, 2), (1, 0, 2.5), (0, 1, 2))
        tris = [tri_up, tri_dn, other]
        self.assertEqual(len(check_triangles(tris)), 1)
        cleaned = strip_csg_coplanar_pairs(tris)
        self.assertEqual(len(check_triangles(cleaned)), 0)


if __name__ == "__main__":
    unittest.main()
