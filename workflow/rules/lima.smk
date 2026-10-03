rule lima:
    input:
        reads=lima_input_bam,
        primers=PRIMERS,
    output:
        bam="results/lima/{sample}/{sample}.chunk{chunk}.demux.bam",
        pbi="results/lima/{sample}/{sample}.chunk{chunk}.demux.bam.pbi",
        report="results/lima/{sample}/{sample}.chunk{chunk}.demux.lima.report",
        summary="results/lima/{sample}/{sample}.chunk{chunk}.demux.lima.summary",
        counts="results/lima/{sample}/{sample}.chunk{chunk}.demux.lima.counts",
    log:
        "logs/lima/{sample}.chunk{chunk}.log",
    wildcard_constraints:
        chunk="[0-9]+",
    conda:
        "../envs/lima.yaml"
    threads: config["threads"]
    params:
        extra=config["lima"].get("extra_params", "--isoseq --peek-guess"),
    script:
        "../scripts/lima.py"
