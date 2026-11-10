#!/usr/bin/env python3
"""The preset renderers must fail when OpenSCAD prints ERROR or WARNING."""
import os
import subprocess
import unittest

from boxes_test_support import (
    bash_for_render_tests,
    env_for_render_ps_tests,
    env_for_render_sh_tests,
    fake_openscad_path,
    powershell_exe,
    strip_ansi,
)


class RenderScriptFailureTest(unittest.TestCase):
    def setUp(self) -> None:
        self.repo = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
        self.fake = fake_openscad_path(self.repo)
        if not self.fake.endswith(".cmd"):
            os.chmod(self.fake, 0o755)

    def _assert_fails_ps(self, cmd: list, line: str) -> None:
        proc = subprocess.run(
            cmd,
            cwd=self.repo,
            env=env_for_render_ps_tests(self.repo, line),
            capture_output=True,
            text=True,
            timeout=60,
        )
        blob = strip_ansi((proc.stdout or "") + "\n" + (proc.stderr or ""))
        self.assertNotEqual(proc.returncode, 0, msg=blob)
        self.assertIn(line.split(":", 1)[0] + ":", blob)

    def _assert_fails_sh(self, cmd: list, line: str) -> None:
        proc = subprocess.run(
            cmd,
            cwd=self.repo,
            env=env_for_render_sh_tests(self.repo, line),
            capture_output=True,
            text=True,
            timeout=60,
        )
        blob = (proc.stdout or "") + "\n" + (proc.stderr or "")
        self.assertNotEqual(proc.returncode, 0, msg=blob)
        self.assertIn(line.split(":", 1)[0] + ":", blob)

    def _require_bash(self) -> str:
        bash = bash_for_render_tests()
        if not bash:
            self.skipTest("bash is not available (or only WSL System32 bash on Windows)")
        return bash

    def _require_powershell(self) -> str:
        ps = powershell_exe()
        if not ps:
            self.skipTest("PowerShell is not installed")
        return ps

    def test_bash_fails_on_error(self) -> None:
        bash = self._require_bash()
        self._assert_fails_sh(
            [bash, "Boxes/tests/render-presets.sh"],
            "ERROR: The given mesh is not closed! Unable to convert to CGAL_Nef_Polyhedron.",
        )

    def test_bash_fails_on_warning(self) -> None:
        bash = self._require_bash()
        self._assert_fails_sh(
            [bash, "Boxes/tests/render-presets.sh"],
            "WARNING: ignoring this would hide a bad mesh",
        )

    def test_powershell_uses_5_1_compatible_process_launch(self) -> None:
        ps1 = os.path.join(self.repo, "Boxes", "tests", "render-presets.ps1")
        with open(ps1, encoding="utf-8") as fh:
            text = fh.read()
        self.assertIsNone(
            __import__("re").search(r"\.ArgumentList\b", text),
            msg="ProcessStartInfo.ArgumentList is null on Windows PowerShell 5.1",
        )
        self.assertIn("Start-Process", text)
        self.assertIn('ErrorActionPreference = "Continue"', text)
        self.assertIn("Invoke-Native", text)
        self.assertRegex(text, r"Failing line")
        self.assertRegex(text, r"PSVersion\.Major -lt 6")

    def test_fake_openscad_windows_cmd_emits_both_streams(self) -> None:
        if os.name != "nt":
            self.skipTest("Windows .cmd fake is only required on nt")
        if not os.path.isfile(self.fake):
            self.skipTest("fake-openscad-error.cmd missing")
        out = os.path.join(self.repo, "out", "_fake-out.log")
        err = os.path.join(self.repo, "out", "_fake-err.log")
        os.makedirs(os.path.dirname(out), exist_ok=True)
        line = "WARNING: win32 fake probe"
        env = os.environ.copy()
        env["FAIL_LINE"] = line
        try:
            proc = subprocess.run(
                [self.fake],
                cwd=self.repo,
                env=env,
                capture_output=True,
                text=True,
                timeout=30,
            )
            self.assertEqual(proc.returncode, 0, msg=proc.stderr)
            merged = (proc.stdout or "") + (proc.stderr or "")
            self.assertIn("WARNING:", merged)
            self.assertIn(line, merged)
        finally:
            for path in (out, err):
                if os.path.isfile(path):
                    os.remove(path)

    def test_powershell_fails_on_error_and_warning(self) -> None:
        ps = self._require_powershell()
        self._assert_fails_ps(
            [ps, "-NoProfile", "-File", "Boxes/tests/render-presets.ps1"],
            "ERROR: The given mesh is not closed! Unable to convert to CGAL_Nef_Polyhedron.",
        )
        self._assert_fails_ps(
            [ps, "-NoProfile", "-File", "Boxes/tests/render-presets.ps1"],
            "WARNING: ignoring this would hide a bad mesh",
        )

    def test_powershell_failure_includes_stack_trace(self) -> None:
        ps = self._require_powershell()
        proc = subprocess.run(
            [ps, "-NoProfile", "-File", "Boxes/tests/render-presets.ps1"],
            cwd=self.repo,
            env=env_for_render_ps_tests(self.repo, "ERROR: simulated failure for stack trace test"),
            capture_output=True,
            text=True,
            timeout=60,
        )
        blob = strip_ansi((proc.stdout or "") + "\n" + (proc.stderr or ""))
        self.assertNotEqual(proc.returncode, 0)
        self.assertRegex(blob, r"(?is)script.{0,120}stack trace")
        self.assertRegex(blob, r"Invoke-OpenSCAD")
        self.assertRegex(blob, r"Failing line \d+:")
        self.assertRegex(blob, r"(?is)render-presets\.ps1:\d+\s+char:\d+")

    def test_native_stderr_does_not_hide_exit_code(self) -> None:
        """stderr plus a non-zero exit must surface the exit code (PS 5.1 NativeCommandError)."""
        ps = self._require_powershell()
        probe = r"""
$ErrorActionPreference = 'Stop'
if ($PSVersionTable.PSVersion.Major -ge 7) { $PSStyle.OutputRendering = 'PlainText' }
$env:RENDER_PRESETS_LIBRARY = '1'
. ./Boxes/tests/render-presets.ps1
$py = $null
foreach ($c in @('python','python3','py')) {
    if (Get-Command $c -ErrorAction SilentlyContinue) { $py = $c; break }
}
if (-not $py) { throw 'python not found for native stderr probe' }
$ok = Invoke-Native $py @('-c', 'import sys; print("progress-on-stderr", file=sys.stderr); print("stdout-line"); raise SystemExit(0)')
if ($ok.Code -ne 0) { throw "exit 0 with stderr became $($ok.Code)" }
$joined = $ok.Lines -join "`n"
if ($joined -notmatch 'progress-on-stderr') { throw "stderr was dropped: $joined" }
if ($joined -notmatch 'stdout-line') { throw "stdout was dropped: $joined" }
$bad = Invoke-Native $py @('-c', 'import sys; print("checker-failed", file=sys.stderr); raise SystemExit(4)')
if ($bad.Code -ne 4) { throw "expected exit 4, got $($bad.Code)" }
$quoted = ConvertTo-CommandLine @('a', 'b c', 'd"e')
if ($quoted -ne 'a "b c" "d\"e"') { throw "quoting failed: $quoted" }
Write-Output 'native-ok'
"""
        proc = subprocess.run(
            [ps, "-NoProfile", "-Command", probe],
            cwd=self.repo,
            capture_output=True,
            text=True,
            timeout=60,
        )
        blob = strip_ansi((proc.stdout or "") + "\n" + (proc.stderr or ""))
        self.assertEqual(proc.returncode, 0, msg=blob)
        self.assertIn("native-ok", blob)

    def test_script_parses_without_ps7_only_syntax(self) -> None:
        ps = self._require_powershell()
        probe = r"""
if ($PSVersionTable.PSVersion.Major -ge 7) { $PSStyle.OutputRendering = 'PlainText' }
$tokens = $null
$errs = $null
$path = (Resolve-Path './Boxes/tests/render-presets.ps1').Path
$ast = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$errs)
if ($errs -and $errs.Count -gt 0) {
    $errs | ForEach-Object { Write-Output $_.ToString() }
    exit 1
}
foreach ($tok in $tokens) {
    if ($tok.Text -in @('&&', '||', '??', '?.')) {
        Write-Output ("forbidden token " + $tok.Text)
        exit 2
    }
}
$bad = $ast.FindAll({
    param($node)
    $node.GetType().Name -match 'Ternary|NullCoalescing|PipelineChain'
}, $true)
if ($bad) {
    $bad | ForEach-Object { Write-Output $_.GetType().Name }
    exit 3
}
Write-Output 'parse-ok'
"""
        proc = subprocess.run(
            [ps, "-NoProfile", "-Command", probe],
            cwd=self.repo,
            capture_output=True,
            text=True,
            timeout=60,
        )
        blob = strip_ansi((proc.stdout or "") + "\n" + (proc.stderr or ""))
        self.assertEqual(proc.returncode, 0, msg=blob)
        self.assertIn("parse-ok", blob)


if __name__ == "__main__":
    unittest.main()
