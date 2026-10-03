rule pbccs:
    input:
        subreads=lambda wc: sample_bam(wc.sample)
    output:
        bam="results/pbccs/{sample}/{sample}.chunk{chunk}.bam",
        pbi="results/pbccs/{sample}/{sample}.chunk{chunk}.bam.pbi",
        report="results/pbccs/{sample}/{sample}.chunk{chunk}.report.txt",
        report_json="results/pbccs/{sample}/{sample}.chunk{chunk}.report.json",
        metrics="results/pbccs/{sample}/{sample}.chunk{chunk}.metrics.json.gz"
    params:
        chunk_total=config["chunk"],
        min_rq=config["pbccs"]["min_rq"],
        min_passes=config["pbccs"]["min_passes"],
        min_snr=config["pbccs"]["min_snr"],
        min_length=config["pbccs"]["min_length"],
        max_length=config["pbccs"]["max_length"],
        top_passes=config["pbccs"]["top_passes"],
        extra=config["pbccs"].get("ccs_extra_params", "")
    conda:
        "../envs/pbccs.yaml"
    log:
        "logs/pbccs/{sample}.chunk{chunk}.ccs.log"
    threads:
        config["threads"]
    wildcard_constraints:
        chunk="[0-9]+"
    script:
        "../scripts/pbccs.py"
