#!/usr/bin/env python3
"""Parse merged OpenSCAD stdout/stderr for hard failure lines."""
from __future__ import annotations

import re

_FAIL_RE = re.compile(r"(?:^|\s)(ERROR|WARNING):", re.MULTILINE)


def failure_lines(text: str) -> list[str]:
    return [ln.strip() for ln in text.splitlines() if re.search(r"(?:^|\s)(ERROR|WARNING):", ln)]


def has_failures(text: str) -> bool:
    return bool(_FAIL_RE.search(text))
