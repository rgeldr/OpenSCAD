#!/usr/bin/env python3
import io
import struct
import math
import unittest

from check_overhangs import check_triangles, load_triangles, mesh_signed_volume


def _binary_stl(triangles):
    buf = io.BytesIO()
    buf.write(b"solid test" + b"\x00" * (80 - 10))
    buf.write(struct.pack("<I", len(triangles)))
    for v0, v1, v2 in triangles:
        buf.write(struct.pack("<3f", 0.0, 0.0, 1.0))
        for v in (v0, v1, v2):
            buf.write(struct.pack("<3f", *v))
        buf.write(struct.pack("<H", 0))
    return buf.getvalue()


def _box_tris():
    return [
        ((0, 0, 0), (0, 10, 0), (10, 10, 0)),
        ((0, 0, 0), (10, 10, 0), (10, 0, 0)),
        ((0, 0, 5), (0, 10, 5), (10, 10, 5)),
        ((0, 0, 5), (10, 10, 5), (10, 0, 5)),
        ((0, 0, 0), (0, 10, 0), (0, 10, 5)),
        ((0, 0, 0), (0, 10, 5), (0, 0, 5)),
        ((10, 0, 0), (10, 10, 5), (10, 10, 0)),
        ((10, 0, 0), (10, 0, 5), (10, 10, 5)),
        ((0, 10, 0), (10, 10, 0), (10, 10, 5)),
        ((0, 10, 0), (10, 10, 5), (0, 10, 5)),
        ((0, 0, 0), (10, 0, 0), (10, 0, 5)),
        ((0, 0, 0), (10, 0, 5), (0, 0, 5)),
    ]


class CheckOverhangsTests(unittest.TestCase):
    def test_box_passes(self):
        self.assertEqual(len(check_triangles(_box_tris())), 0)

    def test_reversed_winding_passes_after_flip(self):
        tris = [(a, c, b) for a, b, c in _box_tris()]
        self.assertNotEqual(mesh_signed_volume(tris), mesh_signed_volume(_box_tris()))
        self.assertEqual(len(check_triangles(tris)), 0)

    def test_downward_at_height_fails(self):
        tris = [((0, 0, 2), (0, 1, 2), (1, 0, 2))]
        fails = check_triangles(tris)
        self.assertEqual(len(fails), 1)
        self.assertLess(fails[0][1], -0.5)

    def test_downward_on_bed_passes(self):
        tris = [((0, 0, 0), (1, 0, 0), (0.5, 1, 0))]
        self.assertEqual(len(check_triangles(tris)), 0)

    def test_shallow_chamfer_at_bed_fails(self):
        # ~45° from horizontal at z>0 (must not use bed exclusion)
        tris = [((0, 0, 1), (2, 0, 0), (0, -1, 1))]
        fails = check_triangles(tris)
        self.assertEqual(len(fails), 1)
        self.assertLess(fails[0][1], -0.5)

    def test_nz_040_passes(self):
        tris = [((0, 0, 2), (2, 0, 2.4), (1, 2, 2))]
        self.assertEqual(len(check_triangles(tris)), 0)

    def test_nz_050_passes(self):
        tris = [((0, 0, 2), (2, 0, 2 + math.sqrt(3)), (1, 2, 2))]
        self.assertEqual(len(check_triangles(tris)), 0)

    def test_nz_just_under_limit_passes(self):
        # Tessellated 60° faces can land slightly under -0.5 (seen: -0.500137).
        nz = -0.5 - 1.4e-4
        run = 2.0
        rise = run * math.sqrt(max(0.0, 1.0 / (nz * nz) - 1.0))
        tris = [((0, 0, 2), (0, run, 2), (run, 0, 2 - rise))]
        self.assertEqual(len(check_triangles(tris)), 0)

    def test_nz_060_fails(self):
        tris = [((0, 0, 2), (2, 2, 2), (2, 0, 2.15))]
        self.assertEqual(len(check_triangles(tris)), 1)

    def test_upward_passes(self):
        tris = [((0, 0, 5), (1, 0, 5), (0.5, 1, 6))]
        self.assertEqual(len(check_triangles(tris)), 0)

    def test_stored_normal_is_ignored(self):
        # Binary STL stores a +Z normal on a face that actually points down.
        data = _binary_stl([((0, 0, 2), (0, 1, 2), (1, 0, 2))])
        import os
        import tempfile

        with tempfile.NamedTemporaryFile(suffix=".stl", delete=False) as f:
            f.write(data)
            path = f.name
        try:
            tris = load_triangles(path)
            fails = check_triangles(tris)
            self.assertEqual(len(fails), 1)
            self.assertLess(fails[0][1], -0.9)
        finally:
            os.unlink(path)

    def test_load_binary_round_trip(self):
        import os
        import tempfile

        data = _binary_stl(_box_tris())
        with tempfile.NamedTemporaryFile(suffix=".stl", delete=False) as f:
            f.write(data)
            path = f.name
        try:
            tris = load_triangles(path)
            self.assertEqual(len(tris), len(_box_tris()))
        finally:
            os.unlink(path)


if __name__ == "__main__":
    unittest.main()
