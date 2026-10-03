rule lima:
    input:
        reads=lima_input_bam,
        primers=PRIMERS
    output:
        bam="results/lima/{sample}/{sample}.chunk{chunk}.demux.bam",
        pbi="results/lima/{sample}/{sample}.chunk{chunk}.demux.bam.pbi",
        report="results/lima/{sample}/{sample}.chunk{chunk}.demux.lima.report",
        summary="results/lima/{sample}/{sample}.chunk{chunk}.demux.lima.summary",
        counts="results/lima/{sample}/{sample}.chunk{chunk}.demux.lima.counts"
    params:
        extra=config["lima"].get("extra_params", "--isoseq --peek-guess")
    conda:
        "../envs/lima.yaml"
    log:
        "logs/lima/{sample}.chunk{chunk}.log"
    threads:
        config["threads"]
    wildcard_constraints:
        chunk="[0-9]+"
    script:
        "../scripts/lima.py"
