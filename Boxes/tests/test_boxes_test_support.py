#!/usr/bin/env python3
import os
import unittest

from boxes_test_support import (
    bash_for_render_tests,
    env_for_render_ps_tests,
    fake_openscad_path,
    strip_ansi,
)


class BoxesTestSupportTest(unittest.TestCase):
    def test_strip_ansi(self) -> None:
        self.assertEqual(strip_ansi("plain"), "plain")
        self.assertEqual(strip_ansi("\x1b[31mERROR:\x1b[0m msg"), "ERROR: msg")

    def test_fake_openscad_path_uses_cmd_on_nt(self) -> None:
        repo = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
        if os.name == "nt":
            self.assertTrue(fake_openscad_path(repo).lower().endswith(".cmd"))
        else:
            self.assertTrue(fake_openscad_path(repo).endswith(".sh"))

    def test_env_for_render_ps_sets_no_color(self) -> None:
        repo = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
        env = env_for_render_ps_tests(repo, "ERROR: x")
        self.assertEqual(env["NO_COLOR"], "1")
        self.assertTrue(os.path.isfile(env["OPENSCAD"]))

    def test_bash_skip_system32_on_nt(self) -> None:
        if os.name != "nt":
            self.skipTest("WSL System32 bash guard is Windows-specific")
        # If only System32 bash exists, helper returns None; otherwise a real path.
        result = bash_for_render_tests()
        if result:
            self.assertNotRegex(result, r"(?i)system32\\bash\.exe$")


if __name__ == "__main__":
    unittest.main()
