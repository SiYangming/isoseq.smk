"""Snakemake wrapper for TAMA FLNC polyA cleanup."""

import os
import sys

from snakemake.shell import shell

import tama_remote

log = snakemake.log_fmt_shell(stdout=True, stderr=True)
explicit = snakemake.config.get("gstama", {}).get("gstama_bin", "")
rel = "tama_go/sequence_cleanup/tama_flnc_polya_cleanup.py"
script = tama_remote.resolve_tama_script(
    rel, explicit if explicit and os.path.isfile(explicit) else None
)
tool = str(script) if script.is_file() else rel
prefix = str(snakemake.params.prefix)
os.makedirs(os.path.dirname(str(snakemake.output.fasta)), exist_ok=True)
shell(f"python {tool} -f {snakemake.input.fasta} -p {prefix} {log}")
for f in (
    f"{prefix}.fa",
    f"{prefix}_polya_flnc_report.txt",
    f"{prefix}_tails.fa",
):
    if os.path.isfile(f):
        shell(f"gzip -f {f}")
