#!/usr/bin/env bash
# Fetch nf-core/test-datasets (isoseq branch) used by SiYangming/isoseq.nf -profile test.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE="https://raw.githubusercontent.com/nf-core/test-datasets/isoseq"
DEST="${1:-$HERE/resources}"
SAMPLE="$DEST/alz"
mkdir -p "$SAMPLE"

fetch() {
  local url="$1" dest="$2"
  if [[ -s "$dest" ]]; then
    echo "[INFO] exists $dest"
    return 0
  fi
  echo "[INFO] GET $url"
  curl -fsSL "$url" -o "$dest"
}

fetch "$BASE/testdata/alz.1perc.subreads.10000.bam" "$SAMPLE/alz.1perc.subreads.10000.subreads.bam"
fetch "$BASE/testdata/alz.1perc.subreads.10000.bam.pbi" "$SAMPLE/alz.1perc.subreads.10000.subreads.bam.pbi"
fetch "$BASE/testdata/primers.fasta" "$DEST/primers.fasta"
fetch "$BASE/reference/Homo_sapiens.GRCh38.dna.chromosome.19.fasta" "$DEST/Homo_sapiens.GRCh38.dna.chromosome.19.fasta"
fetch "$BASE/reference/Homo_sapiens.GRCh38.104.chr.13_18_19.gtf" "$DEST/Homo_sapiens.GRCh38.104.chr.13_18_19.gtf"
echo "[INFO] testdata → $DEST"
