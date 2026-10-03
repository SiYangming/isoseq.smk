"""Resolve gs-tama scripts: builtin cache, then GitHub raw, then PATH."""

from __future__ import annotations

import os
import sys
import urllib.request
from pathlib import Path

GS_TAMA_RAW = "https://raw.githubusercontent.com/SiYangming/gs-tama/master"
CACHE_ROOT = (
    Path(os.environ.get("BIOSKILLS_CACHE", Path.home() / ".cache" / "bioskills"))
    / "gs-tama"
)


def _builtin_path(rel: str) -> Path:
    return Path(__file__).resolve().parent / "gs-tama" / rel


def _download_to_cache(rel: str) -> Path:
    cached = CACHE_ROOT / rel
    url = f"{GS_TAMA_RAW}/{rel}"
    CACHE_ROOT.mkdir(parents=True, exist_ok=True)
    cached.parent.mkdir(parents=True, exist_ok=True)
    print(f"[INFO] download gs-tama {url} -> {cached}", file=sys.stderr)
    urllib.request.urlretrieve(url, cached)
    if not cached.is_file() or cached.stat().st_size == 0:
        raise RuntimeError(f"empty download: {cached}")
    cached.chmod(cached.stat().st_mode | 0o111)
    return cached


def resolve_tama_script(rel: str, explicit: str | None = None) -> Path:
    if explicit:
        p = Path(os.path.expanduser(explicit))
        if p.is_file():
            return p
    builtin = _builtin_path(rel)
    if builtin.is_file():
        return builtin
    cached = CACHE_ROOT / rel
    if cached.is_file():
        return cached
    try:
        return _download_to_cache(rel)
    except Exception as exc:  # noqa: BLE001
        print(f"[WARN] gs-tama download failed ({exc})", file=sys.stderr)
        return Path()
