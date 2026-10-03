rule gstama_polyacleanup:
    input:
        fasta="results/bamtools/{sample}/{sample}.chunk{chunk}.fasta",
    output:
        fasta="results/gstama/{sample}/{sample}.chunk{chunk}_gstama.fa.gz",
        report="results/gstama/{sample}/{sample}.chunk{chunk}_gstama_polya_flnc_report.txt.gz",
        tails="results/gstama/{sample}/{sample}.chunk{chunk}_gstama_tails.fa.gz",
    log:
        "logs/gstama/{sample}.chunk{chunk}.polyacleanup.log",
    wildcard_constraints:
        chunk="[0-9]+",
    conda:
        "../envs/gstama.yaml"
    params:
        prefix=lambda wildcards, output: output.fasta.replace(".fa.gz", ""),
    script:
        "../scripts/gstama_polyacleanup.py"


rule gstama_collapse:
    input:
        bam=align_bam,
        reference=FASTA,
    output:
        bed="results/gstama_collapse/{sample}/{sample}.chunk{chunk}_gstama_collapsed.bed",
    log:
        "logs/gstama_collapse/{sample}.chunk{chunk}.log",
    wildcard_constraints:
        chunk="[0-9]+",
    conda:
        "../envs/gstama.yaml"
    params:
        args=config["gstama"].get(
            "collapse_args", "-x no_cap -a 100 -z 100 -sj sj_priority -sjt 20 -lde 5"
        ),
        prefix=lambda wildcards, output: output.bed.replace("_collapsed.bed", ""),
    script:
        "../scripts/gstama_collapse.py"


rule gstama_filelist:
    input:
        beds=lambda wc: expand(
            "results/gstama_collapse/{sample}/{sample}.chunk{n}_gstama_collapsed.bed",
            sample=[wc.sample],
            n=CHUNKS,
        ),
    output:
        filelist="results/gstama_filelist/{sample}/filelist.tsv",
    log:
        "logs/gstama_filelist/{sample}.log",
    conda:
        "../envs/gstama.yaml"
    params:
        cap=config["gstama"].get(
            "filelist_cap", "capped" if config.get("capped") else "no_cap"
        ),
    script:
        "../scripts/gstama_filelist.py"


rule gstama_merge:
    input:
        filelist="results/gstama_filelist/{sample}/filelist.tsv",
        beds=lambda wc: expand(
            "results/gstama_collapse/{sample}/{sample}.chunk{n}_gstama_collapsed.bed",
            sample=[wc.sample],
            n=CHUNKS,
        ),
    output:
        bed="results/gstama_merge/{sample}.bed",
    log:
        "logs/gstama_merge/{sample}.log",
    conda:
        "../envs/gstama.yaml"
    params:
        args=config["gstama"].get("merge_args", "-a 100 -z 100 -m 20 -d merge_dup"),
        prefix=lambda wildcards, output: output.bed.replace(".bed", ""),
    script:
        "../scripts/gstama_merge.py"
