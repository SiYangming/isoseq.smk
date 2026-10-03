"""Snakemake wrapper for lima（通用单任务规则配套，与同目录 lima.smk 契约一致）。

语义：reads BAM + 引物 FASTA -> 去引物/按条形码拆分 BAM（BAM 主路径；报告文件由 lima
按输出前缀自动派生，无搬运/条件分支）。Docker/native/conda 三模式分派在 wrapper 内完成。

契约：
  - input.reads：输入 reads BAM（config lima_input_reads，ccs 产物 *.bam）
  - input.primers：引物 FASTA（config lima_input_primers）
  - output.bam：主输出 BAM（config lima_output；.pbi/.lima.report/.lima.summary/.lima.counts
    同前缀派生为 output[1..4]，side-product 见 smk 头注）
  - params.extra：透传 lima 额外参数（config lima.extra_params，默认 ""；Iso-Seq 建议
    "--isoseq --peek-guess"）
  - 线程：-j 透传 snakemake.threads（规则 threads = config threads，默认 8）
  - 环境：exec_mode conda(默认) / docker / native；docker 用镜像内 lima，
    native 用 config lima.lima_bin，conda 走 PATH（lima.yaml 含 lima）
"""

__author__ = "Yangming Si"
__copyright__ = "Copyright 2026, Yangming Si"
__email__ = "siyangming1991@163.com"
__license__ = "MIT"

import os
import sys

from snakemake.shell import shell

import docker_wrapper  # noqa: E402

log = snakemake.log_fmt_shell(stdout=True, stderr=True)

# Docker/native/conda 分派（docker 走镜像内默认名；native 走 config lima.lima_bin；conda 走 PATH）
docker_prefix, tool_bin = docker_wrapper.docker_wrapper_binary(
    snakemake.config,
    "lima",
    "lima_bin",
    "lima",
)

# 确保输出目录存在（Docker 挂载后可访问）
out_file = str(snakemake.output.bam)
out_dir = os.path.dirname(out_file)
if out_dir and not os.path.exists(out_dir):
    os.makedirs(out_dir)

extra = snakemake.params.get("extra", "")

shell(
    f"{docker_prefix}{tool_bin}"
    f" {snakemake.input.reads} {snakemake.input.primers} {out_file}"
    f" {extra}"
    f" -j {snakemake.threads}"
    f"{log}"
)

# --peek-guess writes {prefix}.{pair}.bam instead of {prefix}.bam
if not os.path.isfile(out_file):
    import glob
    import shutil

    stem, _ = os.path.splitext(out_file)
    hits = sorted(
        p
        for p in glob.glob(stem + ".*.bam")
        if not p.endswith(".xml")
    )
    if not hits:
        raise FileNotFoundError(
            f"lima did not write {out_file} or a barcode-named BAM under {stem}.*"
        )
    shutil.move(hits[0], out_file)
    src_pbi = hits[0] + ".pbi"
    dest_pbi = out_file + ".pbi"
    if os.path.isfile(src_pbi) and not os.path.isfile(dest_pbi):
        shutil.move(src_pbi, dest_pbi)
