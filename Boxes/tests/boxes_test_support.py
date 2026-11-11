#!/usr/bin/env python3
"""Helpers so Boxes/tests run on Linux and Windows (PowerShell 5.1 / 7)."""
from __future__ import annotations

import os
import re
import shutil
from typing import Dict, Optional

# CSI / OSC / short escapes. PowerShell 7 error views use more than SGR "m".
ANSI_ESCAPE = re.compile(
    r"\x1b(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~]|\].*?(?:\x07|\x1b\\))"
)


def strip_ansi(text: str) -> str:
    if not text:
        return ""
    return ANSI_ESCAPE.sub("", text)


def ps_output_variants(text: str) -> list[str]:
    """Forms that still match after ANSI color and console line wrapping."""
    cleaned = strip_ansi(text or "").replace("\r\n", "\n").replace("\r", "\n")
    collapsed = re.sub(r"\s+", " ", cleaned)
    unwrapped = cleaned.replace("\n", "")
    return [cleaned, collapsed, unwrapped]


def ps_output_matches(text: str, pattern: str) -> bool:
    flags = re.IGNORECASE | re.DOTALL
    return any(re.search(pattern, variant, flags) for variant in ps_output_variants(text))


def is_wsl_system_bash(path: str) -> bool:
    lowered = path.replace("/", "\\").lower()
    return lowered.endswith("\\windows\\system32\\bash.exe") or lowered.endswith(
        "\\windows\\sysnative\\bash.exe"
    ) or lowered.endswith("\\windows\\syswow64\\bash.exe")


def bash_for_render_tests() -> Optional[str]:
    """First bash on PATH that is not the WSL System32 shim. None if absent."""
    path_env = os.environ.get("PATH", "")
    names = ("bash", "bash.exe") if os.name == "nt" else ("bash",)
    seen = set()
    for directory in path_env.split(os.pathsep):
        if not directory:
            continue
        for name in names:
            candidate = os.path.join(directory, name)
            key = os.path.normcase(candidate)
            if key in seen:
                continue
            seen.add(key)
            if not os.path.isfile(candidate):
                continue
            if is_wsl_system_bash(candidate):
                continue
            return candidate
    return None


def fake_openscad_sh(repo: str) -> str:
    return os.path.join(repo, "Boxes", "tests", "fake-openscad-error.sh")


def fake_openscad_path(repo: str) -> str:
    """Fake executable for render-presets.ps1 (Win32 needs .cmd)."""
    if os.name == "nt":
        return os.path.join(repo, "Boxes", "tests", "fake-openscad-error.cmd")
    return fake_openscad_sh(repo)


def env_for_render_sh_tests(repo: str, fail_line: str) -> Dict[str, str]:
    env = os.environ.copy()
    env["OPENSCAD"] = fake_openscad_sh(repo)
    env["FAIL_LINE"] = fail_line
    env["RENDER_PRESETS_SKIP_UNITTEST"] = "1"
    return env


def powershell_exes() -> list[str]:
    """PowerShell 7 (pwsh) and, on Windows, Windows PowerShell 5.1 (powershell)."""
    names = ("pwsh", "powershell") if os.name == "nt" else ("pwsh",)
    found: list[str] = []
    for name in names:
        path = shutil.which(name)
        if path and path not in found:
            found.append(path)
    return found


def powershell_exe() -> Optional[str]:
    exes = powershell_exes()
    return exes[0] if exes else None


def openscad_exe() -> Optional[str]:
    explicit = os.environ.get("OPENSCAD")
    if explicit and os.path.isfile(explicit):
        return explicit
    for name in ("openscad", "openscad.com"):
        found = shutil.which(name)
        if found:
            return found
    return None


def env_for_render_ps_tests(repo: str, fail_line: str) -> Dict[str, str]:
    env = os.environ.copy()
    env["OPENSCAD"] = fake_openscad_path(repo)
    env["FAIL_LINE"] = fail_line
    env["RENDER_PRESETS_SKIP_UNITTEST"] = "1"
    env["NO_COLOR"] = "1"
    env["FORCE_COLOR"] = "0"
    env["TERM"] = "dumb"
    return env

