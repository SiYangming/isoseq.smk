rule gnu_sort_gtf:
    input:
        unsorted=GTF
    output:
        sorted="results/reference/annotation.sorted.gtf"
    conda:
        "../envs/coreutils.yaml"
    log:
        "logs/gnu_sort_gtf.log"
    shell:
        "mkdir -p $(dirname {output.sorted}) $(dirname {log}) && "
        "sort -k1,1 -k4,4n {input.unsorted} > {output.sorted} 2> {log}"


rule ultra_index:
    input:
        fasta=FASTA,
        gtf="results/reference/annotation.sorted.gtf"
    output:
        done=touch("results/ultra/INDEX/done")
    params:
        index_dir="results/ultra/INDEX",
        args=config["ultra"].get("index_args", "--disable_infer")
    conda:
        "../envs/ultra.yaml"
    log:
        "logs/ultra_index.log"
    threads:
        config["threads"]
    script:
        "../scripts/ultra_index.py"


rule ultra_align:
    input:
        reads=align_reads,
        genome=FASTA,
        index_done="results/ultra/INDEX/done"
    output:
        bam="results/ultra/{sample}/{sample}.chunk{chunk}.bam"
    params:
        prefix=lambda wc: f"{wc.sample}.chunk{wc.chunk}",
        args=config["ultra"].get("align_args", "--isoseq"),
        sort_args=config.get("samtools", {}).get("sort_args", "")
    conda:
        "../envs/ultra.yaml"
    log:
        "logs/ultra/{sample}.chunk{chunk}.log"
    threads:
        config["threads"]
    wildcard_constraints:
        chunk="[0-9]+"
    script:
        "../scripts/ultra_align.py"


rule minimap2_align:
    input:
        reads=align_reads,
        reference=FASTA
    output:
        bam="results/minimap2/{sample}/{sample}.chunk{chunk}.bam",
        bai="results/minimap2/{sample}/{sample}.chunk{chunk}.bam.bai",
        versions="results/minimap2/{sample}/{sample}.chunk{chunk}.versions.yml"
    params:
        extra=config["minimap2"].get("args", "-x splice -uf -k14"),
        cigar_bam=config["minimap2"].get("cigar_bam", False)
    conda:
        "../envs/minimap2.yaml"
    log:
        "logs/minimap2/{sample}.chunk{chunk}.log"
    threads:
        config["threads"]
    wildcard_constraints:
        chunk="[0-9]+"
    script:
        "../scripts/minimap2_align.py"
