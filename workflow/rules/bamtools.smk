rule bamtools_convert:
    input:
        bam=bamtools_input_bam
    output:
        out="results/bamtools/{sample}/{sample}.chunk{chunk}.fasta",
        versions="results/bamtools/{sample}/{sample}.chunk{chunk}.versions.yml"
    params:
        format=config["bamtools"].get("format", "fasta"),
        extra=config["bamtools"].get("extra", "")
    conda:
        "../envs/bamtools.yaml"
    log:
        "logs/bamtools/{sample}.chunk{chunk}.log"
    wildcard_constraints:
        chunk="[0-9]+"
    script:
        "../scripts/bamtools_convert.py"
