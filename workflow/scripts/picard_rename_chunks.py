#!/usr/bin/env python3
"""Rename Picard SplitSamByNumberOfReads shards to {prefix}.chunk{n}.bam."""
from __future__ import annotations

import glob
import os
import shutil
import sys


def main(outdir: str, prefix: str, nfiles: int) -> None:
    candidates = sorted(glob.glob(os.path.join(outdir, f"{prefix}_*.bam")))
    if not candidates:
        candidates = sorted(glob.glob(os.path.join(outdir, "shard_*.bam")))
    if len(candidates) < nfiles:
        raise SystemExit(f"expected {nfiles} split BAMs under {outdir}, found {candidates}")
    for i, src in enumerate(candidates[:nfiles], start=1):
        dest = os.path.join(outdir, f"{prefix}.chunk{i}.bam")
        if os.path.abspath(src) != os.path.abspath(dest):
            shutil.move(src, dest)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], int(sys.argv[3]))
