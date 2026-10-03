_polya_flag = "--require-polya" if config["isoseq3"].get("require_polya", True) else ""
_min_polya = config["isoseq3"].get("min_polya_length", "")
_min_polya_flag = f"--min-polya-length {_min_polya}" if _min_polya not in ("", None) else ""


rule isoseq3_refine:
    input:
        bam=refine_input_bam,
        primers=PRIMERS
    output:
        bam="results/isoseq3/{sample}/{sample}.chunk{chunk}.bam",
        pbi="results/isoseq3/{sample}/{sample}.chunk{chunk}.bam.pbi",
        consensus="results/isoseq3/{sample}/{sample}.chunk{chunk}.consensusreadset.xml",
        summary="results/isoseq3/{sample}/{sample}.chunk{chunk}.filter_summary.report.json",
        report="results/isoseq3/{sample}/{sample}.chunk{chunk}.report.csv"
    params:
        polya=_polya_flag,
        min_polya=_min_polya_flag,
        extra=config["isoseq3"].get("extra_args", "")
    conda:
        "../envs/isoseq3.yaml"
    log:
        "logs/isoseq3/{sample}.chunk{chunk}.log"
    threads:
        config["threads"]
    wildcard_constraints:
        chunk="[0-9]+"
    script:
        "../scripts/isoseq3_refine.py"
