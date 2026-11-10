#!/usr/bin/env python3
"""Helpers so Boxes/tests run on Linux and Windows (PowerShell 5.1 / 7)."""
from __future__ import annotations

import os
import re
import shutil
from typing import Dict, Optional

ANSI_ESCAPE = re.compile(r"\x1b\[[0-9;]*m")


def strip_ansi(text: str) -> str:
    if not text:
        return ""
    return ANSI_ESCAPE.sub("", text)


def bash_for_render_tests() -> Optional[str]:
    bash = shutil.which("bash")
    if not bash:
        return None
    if os.name == "nt":
        norm = os.path.normcase(os.path.normpath(bash))
        if norm.endswith(os.path.normcase(r"\windows\system32\bash.exe")):
            return None
    return bash


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


def powershell_exe() -> Optional[str]:
    if os.name == "nt":
        return shutil.which("pwsh") or shutil.which("powershell")
    return shutil.which("pwsh")


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

