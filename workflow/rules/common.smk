import pandas as pd
from snakemake.utils import validate

samples = (
    pd.read_csv(config["sample_sheet"], sep="\t", dtype=str)
    .set_index("sample", drop=False)
    .sort_index()
)
validate(samples, schema="../schemas/samples.schema.yaml")
validate(config, schema="../schemas/config.schema.yaml")

CHUNKS = list(range(1, int(config["chunk"]) + 1))
ENTRY = config["entrypoint"]
ALIGNER = config["aligner"]
PRIMERS = config["primers"]
FASTA = config["fasta"]
GTF = config.get("gtf") or ""


def sample_bam(sample):
    return samples.loc[sample, "bam"]


def sample_reads(sample):
    if (
        "reads" in samples.columns
        and pd.notna(samples.loc[sample, "reads"])
        and samples.loc[sample, "reads"]
    ):
        return samples.loc[sample, "reads"]
    return None


def lima_input_bam(wildcards):
    if ENTRY == "isoseq":
        return f"results/pbccs/{wildcards.sample}/{wildcards.sample}.chunk{wildcards.chunk}.bam"
    return f"results/picard/{wildcards.sample}/{wildcards.sample}.chunk{wildcards.chunk}.bam"


def refine_input_bam(wildcards):
    if ENTRY in ("isoseq", "lima"):
        return f"results/lima/{wildcards.sample}/{wildcards.sample}.chunk{wildcards.chunk}.demux.bam"
    return f"results/picard/{wildcards.sample}/{wildcards.sample}.chunk{wildcards.chunk}.bam"


def bamtools_input_bam(wildcards):
    if ENTRY == "bamtools_convert":
        return f"results/picard/{wildcards.sample}/{wildcards.sample}.chunk{wildcards.chunk}.bam"
    return f"results/isoseq3/{wildcards.sample}/{wildcards.sample}.chunk{wildcards.chunk}.bam"


def align_reads(wildcards):
    if ENTRY == "map":
        reads = sample_reads(wildcards.sample)
        if not reads:
            raise ValueError(
                "map entrypoint requires a reads column in the sample sheet"
            )
        return reads
    return f"results/gstama/{wildcards.sample}/{wildcards.sample}.chunk{wildcards.chunk}_gstama.fa.gz"


def align_bam(wildcards):
    if ALIGNER == "ultra":
        return f"results/ultra/{wildcards.sample}/{wildcards.sample}.chunk{wildcards.chunk}.bam"
    return f"results/minimap2/{wildcards.sample}/{wildcards.sample}.chunk{wildcards.chunk}.bam"


def pipeline_targets():
    return expand("results/gstama_merge/{sample}.bed", sample=samples["sample"])
