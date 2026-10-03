rule gstama_polyacleanup:
    input:
        fasta="results/bamtools/{sample}/{sample}.chunk{chunk}.fasta"
    output:
        fasta="results/gstama/{sample}/{sample}.chunk{chunk}_gstama.fa.gz",
        report="results/gstama/{sample}/{sample}.chunk{chunk}_gstama_polya_flnc_report.txt.gz",
        tails="results/gstama/{sample}/{sample}.chunk{chunk}_gstama_tails.fa.gz"
    params:
        gstama_bin=config["gstama"].get("gstama_bin", "tama_flnc_polya_cleanup.py"),
        prefix=lambda wildcards, output: output.fasta.replace(".fa.gz", "")
    log:
        "logs/gstama/{sample}.chunk{chunk}.polyacleanup.log"
    wildcard_constraints:
        chunk="[0-9]+"
    shell:
        """
        mkdir -p "$(dirname {output.fasta})" "$(dirname {log})"
        {params.gstama_bin} -f {input.fasta} -p "{params.prefix}" >> {log} 2>&1
        for f in "{params.prefix}.fa" "{params.prefix}_polya_flnc_report.txt" "{params.prefix}_tails.fa"; do
            [ -f "$f" ] && gzip -f "$f"
        done
        """


rule gstama_collapse:
    input:
        bam=align_bam,
        reference=FASTA
    output:
        bed="results/gstama_collapse/{sample}/{sample}.chunk{chunk}_gstama_collapsed.bed"
    params:
        gstama_collapse_bin=config["gstama"].get("gstama_collapse_bin", "tama_collapse.py"),
        args=config["gstama"].get(
            "collapse_args", "-x no_cap -a 100 -z 100 -sj sj_priority -sjt 20 -lde 5"
        ),
        prefix=lambda wildcards, output: output.bed.replace("_collapsed.bed", "")
    log:
        "logs/gstama_collapse/{sample}.chunk{chunk}.log"
    wildcard_constraints:
        chunk="[0-9]+"
    shell:
        """
        mkdir -p "$(dirname {output.bed})" "$(dirname {log})"
        {params.gstama_collapse_bin} -s {input.bam} -f {input.reference} -p "{params.prefix}" \
            -b BAM {params.args} >> {log} 2>&1
        """


rule gstama_filelist:
    input:
        beds=lambda wc: expand(
            "results/gstama_collapse/{sample}/{sample}.chunk{n}_gstama_collapsed.bed",
            sample=[wc.sample],
            n=CHUNKS,
        )
    output:
        filelist="results/gstama_filelist/{sample}/filelist.tsv"
    params:
        cap=config["gstama"].get("filelist_cap", "capped" if config.get("capped") else "no_cap"),
        sample=lambda wc: wc.sample
    log:
        "logs/gstama_filelist/{sample}.log"
    run:
        import os
        import re

        os.makedirs(os.path.dirname(output.filelist), exist_ok=True)
        sample = params.sample
        beds = [
            p
            for p in input.beds
            if f"/{sample}/" in p.replace("\\", "/")
        ]
        with open(output.filelist, "w") as out_f:
            for bed_path in beds:
                if not os.path.exists(bed_path) or os.path.getsize(bed_path) == 0:
                    continue
                m = re.search(r"chunk(\d+)", os.path.basename(bed_path))
                n = m.group(1) if m else "1"
                order_str = f"{n},{n},{n}"
                out_f.write(f"{bed_path}\t{params.cap}\t{order_str}\t{sample}:chunk{n}\n")


rule gstama_merge:
    input:
        filelist="results/gstama_filelist/{sample}/filelist.tsv"
    output:
        bed="results/gstama_merge/{sample}.bed"
    params:
        gstama_merge_bin=config["gstama"].get("gstama_merge_bin", "tama_merge.py"),
        args=config["gstama"].get("merge_args", "-a 100 -z 100 -m 20 -d merge_dup"),
        prefix=lambda wildcards, output: output.bed.replace(".bed", "")
    log:
        "logs/gstama_merge/{sample}.log"
    shell:
        """
        mkdir -p "$(dirname {output.bed})" "$(dirname {log})"
        if [ ! -s {input.filelist} ]; then
            echo "Filelist is empty, skipping merge" >> {log}
            touch {output.bed}
            exit 0
        fi
        {params.gstama_merge_bin} -f {input.filelist} -p "{params.prefix}" \
            {params.args} >> {log} 2>&1
        """
