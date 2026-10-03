rule bamtools_convert:
    input:
        bam=bamtools_input_bam,
    output:
        out="results/bamtools/{sample}/{sample}.chunk{chunk}.fasta",
        versions="results/bamtools/{sample}/{sample}.chunk{chunk}.versions.yml",
    log:
        "logs/bamtools/{sample}.chunk{chunk}.log",
    wildcard_constraints:
        chunk="[0-9]+",
    conda:
        "../envs/bamtools.yaml"
    params:
        format=config["bamtools"].get("format", "fasta"),
        extra=config["bamtools"].get("extra", ""),
    script:
        "../scripts/bamtools_convert.py"
