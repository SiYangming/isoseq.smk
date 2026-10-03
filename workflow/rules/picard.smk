# Picard queryname sort (official wrapper) + SplitSamByNumberOfReads (local).

PICARD_WRAPPER = "v5.8.2/bio/picard/sortsam"
_picard_img = config.get("picard", {}).get(
    "docker_image", "quay.io/biocontainers/picard:3.5.0--hdfd78af_0"
)
if not str(_picard_img).startswith(("docker://", "oras://")):
    PICARD_CONTAINER = f"docker://{_picard_img}"
else:
    PICARD_CONTAINER = _picard_img


rule picard_sortsam:
    input:
        bam=lambda wc: sample_bam(wc.sample),
    output:
        bam="results/picard/{sample}/{sample}.queryname.bam",
    log:
        "logs/picard/{sample}.sortsam.log",
    conda:
        "../envs/picard.yaml"
    container:
        PICARD_CONTAINER
    threads: 2
    params:
        extra="SORT_ORDER=queryname",
    wrapper:
        PICARD_WRAPPER


rule picard_split:
    input:
        bam="results/picard/{sample}/{sample}.queryname.bam",
    output:
        bams=expand(
            "results/picard/{{sample}}/{{sample}}.chunk{n}.bam",
            n=CHUNKS,
        ),
    log:
        "logs/picard/{sample}.split.log",
    conda:
        "../envs/picard.yaml"
    params:
        nfiles=len(CHUNKS),
        outdir=lambda wc: f"results/picard/{wc.sample}",
        prefix=lambda wc: wc.sample,
    shell:
        """
        mkdir -p {params.outdir} "$(dirname {log})"
        picard SplitSamByNumberOfReads \
            I={input.bam} \
            O={params.outdir} \
            OUT_PREFIX={params.prefix} \
            SPLIT_TO_N_FILES={params.nfiles} \
            >{log} 2>&1
        python workflow/scripts/picard_rename_chunks.py \
            {params.outdir} {params.prefix} {params.nfiles}
        """
