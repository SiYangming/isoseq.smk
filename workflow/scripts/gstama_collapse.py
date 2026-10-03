"""Snakemake wrapper for TAMA collapse."""

from __future__ import annotations

import os

from snakemake.shell import shell

import tama_remote

log = snakemake.log_fmt_shell(stdout=True, stderr=True)
explicit = snakemake.config.get("gstama", {}).get("gstama_collapse_bin", "")
rel = "tama_collapse.py"
script = tama_remote.resolve_tama_script(
    rel, explicit if explicit and os.path.isfile(explicit) else None
)
tool = str(script) if script.is_file() else rel
prefix = str(snakemake.params.prefix)
args = snakemake.params.get("args", "")
os.makedirs(os.path.dirname(str(snakemake.output.bed)), exist_ok=True)
shell(
    f"python {tool} -s {snakemake.input.bam} -f {snakemake.input.reference} "
    f"-p {prefix} -b BAM {args} {log}"
)
