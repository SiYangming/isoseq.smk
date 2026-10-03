"""Snakemake wrapper for TAMA merge."""

import os

from snakemake.shell import shell

import tama_remote

log = snakemake.log_fmt_shell(stdout=True, stderr=True)
explicit = snakemake.config.get("gstama", {}).get("gstama_merge_bin", "")
rel = "tama_merge.py"
script = tama_remote.resolve_tama_script(
    rel, explicit if explicit and os.path.isfile(explicit) else None
)
tool = str(script) if script.is_file() else rel
prefix = str(snakemake.params.prefix)
args = snakemake.params.get("args", "")
os.makedirs(os.path.dirname(str(snakemake.output.bed)), exist_ok=True)
filelist = str(snakemake.input.filelist)
if not os.path.isfile(filelist) or os.path.getsize(filelist) == 0:
    open(str(snakemake.output.bed), "a").close()
else:
    shell(f"python {tool} -f {filelist} -p {prefix} {args} {log}")
