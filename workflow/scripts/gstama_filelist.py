"""Build TAMA merge filelist.tsv from per-chunk collapsed BED files."""

import os
import re
from pathlib import Path

sample = str(snakemake.wildcards.sample)
cap = str(snakemake.params.cap)
out = str(snakemake.output.filelist)
os.makedirs(os.path.dirname(out), exist_ok=True)
beds = [
    p
    for p in snakemake.input.beds
    if Path(p).parent.name == sample
]
with open(out, "w") as out_f:
    for bed_path in beds:
        if not os.path.exists(bed_path) or os.path.getsize(bed_path) == 0:
            continue
        m = re.search(r"chunk(\d+)", os.path.basename(bed_path))
        n = m.group(1) if m else "1"
        order_str = f"{n},{n},{n}"
        out_f.write(f"{bed_path}\t{cap}\t{order_str}\t{sample}:chunk{n}\n")
