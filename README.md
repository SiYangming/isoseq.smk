# Snakemake workflow: `isoseq.smk`

[![Snakemake](https://img.shields.io/badge/snakemake-≥8.0.0-brightgreen.svg)](https://snakemake.github.io)
[![GitHub actions status](https://github.com/SiYangming/isoseq.smk/workflows/Tests/badge.svg?branch=main)](https://github.com/SiYangming/isoseq.smk/actions?query=branch%3Amain+workflow%3ATests)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)

Genome annotation with PacBio Iso-Seq (CCS → lima → refine → FLNC → align → TAMA), matching [SiYangming/isoseq.nf](https://github.com/SiYangming/isoseq.nf).

## Usage

```bash
bash .test/fetch_testdata.sh
bash run_smk.sh --directory .test --cores 2
```

`exec_mode` in `config/config.yaml`: `native` | `conda` | `docker` | `apptainer`.

`entrypoint`: `isoseq` | `lima` | `isoseq3_refine` | `bamtools_convert` | `map`.

`aligner`: `minimap2` | `ultra`.

Test data URLs are the same as `isoseq.nf -profile test` ([nf-core/test-datasets isoseq](https://github.com/nf-core/test-datasets/tree/isoseq)).

## Authors

- Yangming Si

## References

> Köster, J. et al. _Sustainable data analysis with Snakemake_. F1000Research, 2021.
