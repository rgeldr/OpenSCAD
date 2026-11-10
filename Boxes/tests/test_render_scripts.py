#!/usr/bin/env python3
"""The preset renderers must fail when OpenSCAD prints ERROR or WARNING."""
import os
import shutil
import subprocess
import unittest


class RenderScriptFailureTest(unittest.TestCase):
    def setUp(self) -> None:
        self.repo = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
        self.fake = os.path.join(self.repo, "Boxes", "tests", "fake-openscad-error.sh")
        os.chmod(self.fake, 0o755)

    def _env(self, line: str) -> dict:
        env = os.environ.copy()
        env["OPENSCAD"] = self.fake
        env["FAIL_LINE"] = line
        env["RENDER_PRESETS_SKIP_UNITTEST"] = "1"
        return env

    def _assert_fails(self, cmd: list, line: str) -> None:
        proc = subprocess.run(
            cmd,
            cwd=self.repo,
            env=self._env(line),
            capture_output=True,
            text=True,
            timeout=60,
        )
        blob = (proc.stdout or "") + "\n" + (proc.stderr or "")
        self.assertNotEqual(proc.returncode, 0, msg=blob)
        self.assertIn(line.split(":", 1)[0] + ":", blob)

    def test_bash_fails_on_error(self) -> None:
        self._assert_fails(
            ["bash", "Boxes/tests/render-presets.sh"],
            "ERROR: The given mesh is not closed! Unable to convert to CGAL_Nef_Polyhedron.",
        )

    def test_bash_fails_on_warning(self) -> None:
        self._assert_fails(
            ["bash", "Boxes/tests/render-presets.sh"],
            "WARNING: ignoring this would hide a bad mesh",
        )

    def test_powershell_fails_on_error_and_warning(self) -> None:
        pwsh = shutil.which("pwsh")
        if not pwsh:
            self.fail("pwsh is not installed; cannot verify render-presets.ps1")
        self._assert_fails(
            [pwsh, "-NoProfile", "-File", "Boxes/tests/render-presets.ps1"],
            "ERROR: The given mesh is not closed! Unable to convert to CGAL_Nef_Polyhedron.",
        )
        self._assert_fails(
            [pwsh, "-NoProfile", "-File", "Boxes/tests/render-presets.ps1"],
            "WARNING: ignoring this would hide a bad mesh",
        )


if __name__ == "__main__":
    unittest.main()
